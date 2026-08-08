#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Raise a pinned PowerShell Gallery module version to the newest release inside its allowed range.

.DESCRIPTION
    Reads the version currently pinned in a file, asks the PowerShell Gallery which versions of
    the module exist, picks the highest one inside the allowed range, and rewrites the pin when
    that is newer than what is there.

    The script exists because Dependabot has no PowerShell Gallery ecosystem, so nothing on the
    platform will ever open the pull request that moves such a pin. See the Dependency Updates
    capability for the gap and the pattern that fills it.

    Nothing about how tightly the pin is set changes here - only its movement. The identity half
    of a pin (a module GUID) is deliberately untouched, because identity does not change between
    versions of the same module.

    The pin is found with a regular expression carrying a 'version' capture group, so the script
    does not care whether it lives in a script parameter default, a data file, or a workflow
    input. Only the captured group is rewritten; every other byte of the file, including its line
    endings and byte-order mark, is preserved.

    The pattern MUST match exactly once. A pattern matching nothing, or matching several places,
    is an error rather than a guess - rewriting the wrong pin silently is worse than failing.

    A Gallery that cannot be reached is likewise an error, never a quiet "already up to date".
    A check that reports success when it could not perform the check is the failure mode this
    whole mechanism exists to remove.

.EXAMPLE
    ./Update-GalleryModulePin.ps1 -Name Pester -Path ./.github/scripts/Invoke-PesterSuite.ps1 -MinimumVersion 6.0.0 -MaximumVersion '6.*'
    Raises the Pester pin to the newest 6.x release, leaving the file alone if it is already current.

.EXAMPLE
    ./Update-GalleryModulePin.ps1 -Name Pester -Path ./pins.psd1 -PinPattern "PesterVersion\s*=\s*'(?<version>[^']+)'"
    Rewrites a pin held somewhere else, by pointing the pattern at it.

.INPUTS
    None

    You can't pipe objects to Update-GalleryModulePin.ps1.

.OUTPUTS
    [pscustomobject]

    An object describing the module, the version found in the file, the newest allowed version,
    the level of the change, and whether the file was rewritten. The same values are appended to
    $env:GITHUB_OUTPUT when it is set, so a workflow step can branch on them.

.LINK
    https://msxorg.github.io/docs/Capabilities/dependency-updates/design/
#>
[CmdletBinding(SupportsShouldProcess)]
[OutputType([pscustomobject])]
param(
    # Module id on the Gallery, for example 'Pester'.
    [Parameter(Mandatory)]
    [string] $Name,

    # File holding the pinned version.
    [Parameter(Mandatory)]
    [string] $Path,

    # Regular expression locating the pin, carrying a 'version' capture group around the version
    # itself. The default matches a '$RequiredVersion = '<version>'' parameter default.
    [Parameter()]
    [string] $PinPattern = '\$RequiredVersion\s*=\s*''(?<version>[^'']+)''',

    # Lowest version considered acceptable, inclusive. Omit for no floor.
    [Parameter()]
    [version] $MinimumVersion,

    # Highest version considered acceptable. Accepts a trailing wildcard in the style of a
    # '#Requires -Modules' specification, so '6.*' means "any 6.x, never 7.0.0". Omit for no
    # ceiling - which lets a new major be proposed, so only do that deliberately.
    [Parameter()]
    [string] $MaximumVersion,

    # Root of the Gallery's OData v2 feed. A real parameter rather than a test hook: it is what
    # points the script at an internal mirror, and pointing it at a stub is a side effect of that.
    [Parameter()]
    [string] $GalleryUri = 'https://www.powershellgallery.com/api/v2',

    # Consider prerelease versions too. Off by default - a CI pin should not move onto a preview.
    [Parameter()]
    [switch] $AllowPrerelease
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-WorkflowAnnotation {
    <#
        .SYNOPSIS
        Emit a GitHub Actions annotation that renders above the collapsed log.

        .DESCRIPTION
        Writes a '::notice::', '::warning::', or '::error::' workflow command with the
        dynamic parts percent-encoded, so a value carrying '%', a newline, a colon, or a
        comma cannot corrupt or break out of the single-line command.

        .EXAMPLE
        Write-WorkflowAnnotation -Type notice -Title 'Pin' -Message 'Pester is current at 6.0.1'
        Renders a notice on the run summary and in the Checks view.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    param(
        # Annotation severity, which decides how GitHub renders it.
        [Parameter(Mandatory)]
        [ValidateSet('notice', 'warning', 'error')]
        [string] $Type,

        # Short headline shown in bold on the annotation.
        [Parameter(Mandatory)]
        [string] $Title,

        # The annotation body.
        [Parameter(Mandatory)]
        [string] $Message
    )
    $encodedMessage = $Message -replace '%', '%25' -replace "`r", '%0D' -replace "`n", '%0A'
    # A value in a command property needs ':' and ',' encoded too - they delimit the list.
    $encodedTitle = $Title -replace '%', '%25' -replace "`r", '%0D' -replace "`n", '%0A' -replace ':', '%3A' -replace ',', '%2C'
    Write-Output "::${Type} title=${encodedTitle}::${encodedMessage}"
}

function Get-VersionCeiling {
    <#
        .SYNOPSIS
        Turn a maximum-version specification into a comparable bound.

        .DESCRIPTION
        Accepts either an exact version, which bounds inclusively, or a trailing-wildcard form
        such as '6.*' in the style of a '#Requires -Modules' specification, which bounds
        exclusively at the next value of the last fixed component. '6.*' therefore admits every
        6.x release and excludes 7.0.0.

        .EXAMPLE
        Get-VersionCeiling -MaximumVersion '6.*'
        Returns a bound of 7.0 that is not inclusive.

        .OUTPUTS
        [pscustomobject]
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # The maximum-version specification to interpret.
        [Parameter(Mandatory)]
        [string] $MaximumVersion
    )
    if ($MaximumVersion -match '^(?<prefix>\d+(\.\d+)*)\.\*$') {
        $parts = [System.Collections.Generic.List[string]] ($Matches.prefix -split '\.')
        $parts[$parts.Count - 1] = [string] ([int] $parts[$parts.Count - 1] + 1)
        while ($parts.Count -lt 2) { $parts.Add('0') }
        return [pscustomobject]@{ Bound = [version] ($parts -join '.'); Inclusive = $false }
    }
    return [pscustomobject]@{ Bound = [version] $MaximumVersion; Inclusive = $true }
}

function Get-UpdateLevel {
    <#
        .SYNOPSIS
        Describe how far a version moved, in the vocabulary the update labels use.

        .DESCRIPTION
        Compares two versions and reports 'major', 'minor', or 'patch' - the level the Dependency
        Updates capability labels an update pull request with, kept deliberately separate from
        this repository's own release-bump labels.

        .EXAMPLE
        Get-UpdateLevel -From 6.0.1 -To 6.1.0
        Returns 'minor'.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The version being replaced.
        [Parameter(Mandatory)]
        [version] $From,

        # The version replacing it.
        [Parameter(Mandatory)]
        [version] $To
    )
    if ($To.Major -ne $From.Major) { return 'major' }
    if ($To.Minor -ne $From.Minor) { return 'minor' }
    return 'patch'
}

function Get-GalleryVersion {
    <#
        .SYNOPSIS
        List the versions of a module published to a PowerShell Gallery feed.

        .DESCRIPTION
        Pages the OData v2 'FindPackagesById()' endpoint until it stops returning entries,
        because the feed caps a page well below the number of releases a long-lived module has.
        Prereleases are excluded by the query itself unless they were asked for.

        A version the feed reports in a form that is not parsable is skipped rather than fatal -
        one malformed entry must not stop the pin from moving - but a feed that cannot be reached
        at all throws, so a broken query can never look like "nothing newer".

        .EXAMPLE
        Get-GalleryVersion -Name Pester -GalleryUri https://www.powershellgallery.com/api/v2
        Returns every published stable version of Pester.

        .OUTPUTS
        [version[]]
    #>
    [CmdletBinding()]
    [OutputType([version[]])]
    param(
        # Module id to look up.
        [Parameter(Mandatory)]
        [string] $Name,

        # Root of the OData v2 feed.
        [Parameter(Mandatory)]
        [string] $GalleryUri,

        # Include prerelease versions in the result.
        [Parameter()]
        [switch] $AllowPrerelease
    )
    $found = [System.Collections.Generic.List[version]]::new()
    $skip = 0
    # The feed pages; a page short of this many entries is the last one. The cap is a guard
    # against an endpoint that never returns an empty page, not an expected outcome.
    $maxRequests = 50
    for ($request = 0; $request -lt $maxRequests; $request++) {
        $query = "FindPackagesById()?id='$Name'&`$select=Version&`$skip=$skip"
        if (-not $AllowPrerelease) {
            $query += "&`$filter=IsPrerelease eq false"
        }
        $uri = "$($GalleryUri.TrimEnd('/'))/$query"
        Write-Verbose "Querying $uri"
        $response = Invoke-RestMethod -Uri $uri -Headers @{ Accept = 'application/atom+xml' } -MaximumRetryCount 3 -RetryIntervalSec 5
        $entries = @($response | Where-Object { $_ -and $_.PSObject.Properties.Name -contains 'properties' })
        if ($entries.Count -eq 0) { break }
        foreach ($entry in $entries) {
            $parsed = [version]::new()
            if ([version]::TryParse($entry.properties.Version, [ref] $parsed)) {
                $found.Add($parsed)
            } else {
                Write-Verbose "Skipping unparsable version '$($entry.properties.Version)'."
            }
        }
        $skip += $entries.Count
    }
    return $found.ToArray()
}

$pinFile = (Resolve-Path -LiteralPath $Path).ProviderPath

Write-Output "::group::Read the pinned $Name version from $pinFile"
# Read and write the whole file as text so line endings survive untouched, and keep the byte-order
# mark exactly as found - rewriting one version must not restyle the file around it.
$originalBytes = [System.IO.File]::ReadAllBytes($pinFile)
$hasBom = $originalBytes.Length -ge 3 -and $originalBytes[0] -eq 0xEF -and $originalBytes[1] -eq 0xBB -and $originalBytes[2] -eq 0xBF
$content = [System.IO.File]::ReadAllText($pinFile)

$matched = [regex]::Matches($content, $PinPattern)
if ($matched.Count -eq 0) {
    throw "The pin pattern '$PinPattern' matched nothing in $pinFile. The pin has moved or been reshaped; update the pattern rather than letting the check pass silently."
}
if ($matched.Count -gt 1) {
    throw "The pin pattern '$PinPattern' matched $($matched.Count) places in $pinFile. Narrow it so exactly one pin is rewritten."
}
$versionGroup = $matched[0].Groups['version']
if (-not $versionGroup.Success) {
    throw "The pin pattern '$PinPattern' has no 'version' capture group, so there is nothing to rewrite."
}
$currentVersion = [version] $versionGroup.Value
Write-Output "$Name is pinned to $currentVersion."
Write-Output '::endgroup::'

Write-Output "::group::Ask the Gallery which versions of $Name exist"
$published = Get-GalleryVersion -Name $Name -GalleryUri $GalleryUri -AllowPrerelease:$AllowPrerelease
if ($published.Count -eq 0) {
    throw "The Gallery at $GalleryUri reported no versions of $Name at all. Treating that as 'nothing newer' would hide a broken query, so it is a failure."
}
Write-Output "The Gallery reports $($published.Count) published version(s)."

$ceiling = if ($PSBoundParameters.ContainsKey('MaximumVersion')) { Get-VersionCeiling -MaximumVersion $MaximumVersion } else { $null }
$allowed = @($published | Where-Object {
        (-not $MinimumVersion -or $_ -ge $MinimumVersion) -and
        (-not $ceiling -or ($ceiling.Inclusive ? ($_ -le $ceiling.Bound) : ($_ -lt $ceiling.Bound)))
    })
if ($allowed.Count -eq 0) {
    throw "No published version of $Name falls inside the allowed range. The range and the Gallery disagree; one of them is wrong."
}
$latest = ($allowed | Sort-Object -Descending)[0]
Write-Output "The newest allowed version is $latest."
Write-Output '::endgroup::'

$updated = $latest -gt $currentVersion
$level = if ($updated) { Get-UpdateLevel -From $currentVersion -To $latest } else { 'none' }

if ($updated) {
    $rewritten = $content.Substring(0, $versionGroup.Index) + $latest.ToString() + $content.Substring($versionGroup.Index + $versionGroup.Length)
    if ($PSCmdlet.ShouldProcess($pinFile, "Raise the $Name pin from $currentVersion to $latest")) {
        [System.IO.File]::WriteAllText($pinFile, $rewritten, [System.Text.UTF8Encoding]::new($hasBom))
        Write-WorkflowAnnotation -Type notice -Title 'Dependency' -Message "$Name moves from $currentVersion to $latest ($level)."
    }
} else {
    Write-WorkflowAnnotation -Type notice -Title 'Dependency' -Message "$Name is current at $currentVersion; nothing to do."
}

if ($env:GITHUB_OUTPUT) {
    @(
        "module=$Name"
        "updated=$($updated.ToString().ToLowerInvariant())"
        "current=$currentVersion"
        "latest=$latest"
        "level=$level"
    ) | Out-File -LiteralPath $env:GITHUB_OUTPUT -Encoding utf8 -Append
}

[pscustomobject]@{
    Module         = $Name
    Path           = $pinFile
    CurrentVersion = $currentVersion
    LatestVersion  = $latest
    Level          = $level
    Updated        = $updated
}
