#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Synchronize SHA-pinned GitHub Actions with their latest stable releases.

.DESCRIPTION
    Recursively scans a target repository's .github directory for YAML files and updates
    action references in the form 'uses: owner/repository[/subpath]@<40-character SHA>'.
    Each reference is resolved to the repository's latest stable GitHub release, then to
    the immutable commit SHA behind that release tag. Lightweight and annotated tags are
    both supported.

    The script changes only external SHA-pinned action references. Local actions
    ('./path') and Docker actions ('docker://image') do not match the supported reference
    shape and are left unchanged. A trailing comment is treated as the release tag and is
    replaced; the latest tag comment is added when it is absent.

    GitHub API requests use GITHUB_TOKEN or GH_TOKEN when either is present. The token is
    sent only in the Authorization request header and is never written to output. No
    external PowerShell modules are required.

.EXAMPLE
    ./Update-GitHubActionPin.ps1 -RepositoryPath ../service -WhatIf

    Shows the changes needed to synchronize SHA-pinned actions in ../service without
    changing its YAML files.

.EXAMPLE
    ./Update-GitHubActionPin.ps1 -RepositoryPath ../service -Verbose

    Updates each SHA pin in ../service to the latest stable release and reports the
    release lookups and changed files.

.INPUTS
    None. This script does not accept pipeline input.

.OUTPUTS
    [pscustomobject] with Path, Updates, and Updated properties for every YAML file that
    contains a supported action reference.
#>
[OutputType([pscustomobject])]
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    # Repository whose .github YAML files are scanned. Defaults to the current directory.
    [Parameter()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
    [string] $RepositoryPath = (Get-Location).Path,

    # GitHub REST API root. GITHUB_API_URL allows the same script to run on GitHub Enterprise.
    [Parameter()]
    [uri] $ApiBaseUri = $(if ($env:GITHUB_API_URL) { $env:GITHUB_API_URL } else { 'https://api.github.com' })
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-GitHubRequestHeader {
    <#
    .SYNOPSIS
    Build headers for an authenticated GitHub REST API request when a token is available.
    #>
    [OutputType([hashtable])]
    [CmdletBinding()]
    param()

    $headers = @{
        Accept = 'application/vnd.github+json'
        'User-Agent' = 'MSXOrg-GitHubActionPinUpdater'
        'X-GitHub-Api-Version' = '2022-11-28'
    }

    $token = if ($env:GITHUB_TOKEN) { $env:GITHUB_TOKEN } else { $env:GH_TOKEN }
    if ($token) {
        $null = $headers.Authorization = "Bearer $token"
    }

    return $headers
}

function Invoke-GitHubApiRequest {
    <#
    .SYNOPSIS
    Request one GitHub REST API resource.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [uri] $Uri,

        [Parameter(Mandatory)]
        [hashtable] $Headers
    )

    Write-Verbose "Querying GitHub API: $Uri"
    return Invoke-RestMethod -Method Get -Uri $Uri -Headers $Headers
}

function Get-GitHubReleaseCommit {
    <#
    .SYNOPSIS
    Resolve an action repository's latest stable release tag to a commit SHA.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^[^/]+/[^/]+$')]
        [string] $Repository,

        [Parameter(Mandatory)]
        [uri] $ApiBaseUri,

        [Parameter(Mandatory)]
        [hashtable] $Headers
    )

    $apiBase = $ApiBaseUri.AbsoluteUri.TrimEnd('/')
    $releaseUri = "$apiBase/repos/$Repository/releases/latest"
    $release = Invoke-GitHubApiRequest -Uri $releaseUri -Headers $Headers
    $tag = [string] $release.tag_name
    if ([string]::IsNullOrWhiteSpace($tag)) {
        throw "GitHub returned no latest stable release tag for action repository '$Repository'."
    }

    $escapedTag = [uri]::EscapeDataString($tag)
    $referenceUri = "$apiBase/repos/$Repository/git/ref/tags/$escapedTag"
    $reference = Invoke-GitHubApiRequest -Uri $referenceUri -Headers $Headers
    $target = $reference.object
    $seenTags = @{}

    while ($target.type -eq 'tag') {
        $tagSha = [string] $target.sha
        if ($tagSha -notmatch '^[0-9a-fA-F]{40}$') {
            throw "GitHub returned an invalid annotated-tag SHA for '$Repository@$tag'."
        }
        if ($seenTags.ContainsKey($tagSha)) {
            throw "GitHub returned a circular annotated-tag chain for '$Repository@$tag'."
        }
        $null = $seenTags[$tagSha] = $true

        $tagUri = "$apiBase/repos/$Repository/git/tags/$tagSha"
        $annotatedTag = Invoke-GitHubApiRequest -Uri $tagUri -Headers $Headers
        $target = $annotatedTag.object
    }

    if ($target.type -ne 'commit' -or ([string] $target.sha) -notmatch '^[0-9a-fA-F]{40}$') {
        throw "GitHub could not resolve latest stable release '$Repository@$tag' to a commit SHA."
    }

    return [pscustomobject]@{
        Tag = $tag
        Sha = ([string] $target.sha).ToLowerInvariant()
    }
}

function Get-GitHubActionReplacement {
    <#
    .SYNOPSIS
    Build an updated uses: line from one supported action reference match.
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Text.RegularExpressions.Match] $Match,

        [Parameter(Mandatory)]
        [hashtable] $ReleaseCache,

        [Parameter(Mandatory)]
        [uri] $ApiBaseUri,

        [Parameter(Mandatory)]
        [hashtable] $Headers
    )

    $repository = "$($Match.Groups['owner'].Value)/$($Match.Groups['repository'].Value)"
    $cacheKey = $repository.ToLowerInvariant()
    if (-not $ReleaseCache.ContainsKey($cacheKey)) {
        $null = $ReleaseCache[$cacheKey] = Get-GitHubReleaseCommit -Repository $repository -ApiBaseUri $ApiBaseUri -Headers $Headers
    }

    $release = $ReleaseCache[$cacheKey]
    $action = $Match.Groups['action'].Value
    return "$($Match.Groups['prefix'].Value)$action@$($release.Sha) # $($release.Tag)"
}

function Update-GitHubActionPin {
    <#
    .SYNOPSIS
    Update SHA-pinned actions beneath a repository's .github directory.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container })]
        [string] $RepositoryPath,

        [Parameter(Mandatory)]
        [uri] $ApiBaseUri
    )

    $githubDirectory = Join-Path (Resolve-Path -LiteralPath $RepositoryPath).ProviderPath '.github'
    if (-not (Test-Path -LiteralPath $githubDirectory -PathType Container)) {
        throw "Target repository '$RepositoryPath' has no .github directory to scan."
    }

    $headers = Get-GitHubRequestHeader
    $releaseCache = @{}
    $referencePattern = [regex]::new(
        '(?m)(?<prefix>^[ \t]*(?:-[ \t]*)?uses:[ \t]*)(?<action>(?<owner>[\w.-]+)/(?<repository>[\w.-]+)(?:/[^\s@#]+)*)@[0-9a-fA-F]{40}(?:[ \t]*(?:#[^\r\n]*)?)(?=\r?$)'
    )
    $yamlFiles = @(Get-ChildItem -LiteralPath $githubDirectory -Recurse -File |
            Where-Object { $_.Extension -in @('.yml', '.yaml') } |
            Sort-Object -Property FullName)

    if ($yamlFiles.Count -eq 0) {
        Write-Verbose "No YAML files found beneath $githubDirectory."
        return
    }

    foreach ($file in $yamlFiles) {
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $hasUtf8Bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
        $offset = if ($hasUtf8Bom) { 3 } else { 0 }
        $content = [System.Text.Encoding]::UTF8.GetString($bytes, $offset, $bytes.Length - $offset)
        $referenceMatches = $referencePattern.Matches($content)
        if ($referenceMatches.Count -eq 0) {
            continue
        }

        $updatedContent = [System.Text.StringBuilder]::new()
        $position = 0
        $updates = 0
        foreach ($match in $referenceMatches) {
            $replacement = Get-GitHubActionReplacement -Match $match -ReleaseCache $releaseCache -ApiBaseUri $ApiBaseUri -Headers $headers
            $null = $updatedContent.Append($content, $position, $match.Index - $position)
            $null = $updatedContent.Append($replacement)
            $position = $match.Index + $match.Length
            $updates++
        }
        $null = $updatedContent.Append($content, $position, $content.Length - $position)

        $updated = $false
        if ($PSCmdlet.ShouldProcess($file.FullName, "Update $updates GitHub Action SHA pin(s)")) {
            $encoding = [System.Text.UTF8Encoding]::new($hasUtf8Bom)
            [System.IO.File]::WriteAllText($file.FullName, $updatedContent.ToString(), $encoding)
            $updated = $true
            Write-Verbose "Updated $updates action reference(s) in $($file.FullName)."
        }

        [pscustomobject]@{
            Path = $file.FullName
            Updates = $updates
            Updated = $updated
        }
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    Update-GitHubActionPin -RepositoryPath $RepositoryPath -ApiBaseUri $ApiBaseUri
}
