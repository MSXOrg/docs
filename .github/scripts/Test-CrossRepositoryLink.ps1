#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Validate that every cross-repository Markdown link into an MSX organization resolves.

.DESCRIPTION
    The Markdown standard tells authors to use a canonical published URL for a
    cross-repository reference, and 'Test-DocumentationLink.ps1' ignores external
    links on purpose. This is the other half: the links that point at a repository
    somewhere else, which moves on its own schedule without anyone here being told.

    Scope is decided by ownership rather than by scheme. Checking every external URL
    on the internet is slow, flaky, and hostage to other people's outages; links into
    the organizations MSX controls are a bounded set and are where the breakage comes
    from - the target moved because we moved it. Only 'github.com' and
    'raw.githubusercontent.com' links owned by '-Owner' are resolved.

    These URL shapes are resolved:

    - 'https://github.com/OWNER/REPO'                            the repository exists
    - 'https://github.com/OWNER/REPO#anchor'                     an anchor in its README
    - 'https://github.com/OWNER/REPO?tab=readme-ov-file#anchor'  the same, GitHub's own form
    - 'https://github.com/OWNER/REPO/blob/REF/PATH#anchor'       a file, and its anchor
    - 'https://github.com/OWNER/REPO/tree/REF/PATH'              a directory
    - 'https://raw.githubusercontent.com/OWNER/REPO/REF/PATH'    a file

    Everything else under an in-scope repository - '/issues/', '/pull/',
    '/discussions/', '/releases/', '/actions/', '/wiki/', '/compare/', '/commit/' - is
    ignored. Those are API objects rather than paths, and they do not move when a
    repository is restructured.

    An anchor cannot be checked with a HEAD request: the fragment is never sent to the
    server, so '.../file.md#heading' answers 200 whether or not that heading exists.
    The content is fetched and its headings are slugged with GitHub's rules - not with
    the 'ConvertTo-Slug' in 'Test-DocumentationLink.ps1', which mirrors python-markdown
    for the published site. A cross-repository link resolves against GitHub's rendering,
    so reusing the site slugger here would check the wrong algorithm and quietly agree
    with itself.

    A link into the repository the script runs in is resolved against the checkout
    rather than over the network. Resolved against the default branch it would confirm
    the state a pull request is about to invalidate: a change that moves the file would
    pass here and break the moment it merged.

    Three outcomes, not two. A link is *broken* when the target repository is readable
    and the path or the anchor is not there. A link is *unresolvable* when the check
    could not answer at all - a network failure, an exhausted API rate limit, or a
    target no anonymous reader can reach. Both are reported, under separate headings,
    so a red run says which of the two happened.

    The oracle is deliberately what an anonymous reader sees. GITHUB_TOKEN, when
    present, is used only to lift the rate limit from 60 to 1000 requests an hour; it
    grants no access to a private repository elsewhere. That is the right bar for a
    public documentation site: a page here linking into a repository a reader cannot
    open is broken for that reader.

    It also exits 1 when it resolved no cross-repository link at all. Every link
    resolving is trivially true when none were found, so an empty run is reported as a
    failure rather than a pass.

    The script changes nothing. It exits 0 when every in-scope link resolves and exits
    1 otherwise, so it can gate a pull request in CI.

.EXAMPLE
    ./Test-CrossRepositoryLink.ps1
    Validates every cross-repository link in the repository's Markdown.

.EXAMPLE
    ./Test-CrossRepositoryLink.ps1 -Path src/docs/Coding-Standards/Markdown.md
    Validates a single file.

.EXAMPLE
    ./Test-CrossRepositoryLink.ps1 -Owner MSXOrg, PSModule, Storhaug-ting, Contoso
    Adds another organization to the set whose links are resolved.

.INPUTS
    None

    You can't pipe objects to Test-CrossRepositoryLink.ps1.

.OUTPUTS
    None

    The script reports through the console log, a workflow annotation, and its exit code.

.NOTES
    'ConvertTo-GitHubSlug' and 'Get-RenderedHeadingText' are taken from
    'scripts/Test-MarkdownLink.ps1' in Storhaug-ting/Kilden, where the character class
    was compared against github-slugger across every code point. Keeping one
    implementation of GitHub's slug rules, rather than writing a third, is deliberate.

.LINK
    https://msxorg.github.io/docs/Coding-Standards/Markdown/

.LINK
    https://github.com/Flet/github-slugger
#>
[CmdletBinding()]
param(
    # Markdown files to validate, relative to the repository root. Defaults to every
    # Markdown file in the repository outside a dot-directory and the build output.
    [Parameter()]
    [string[]] $Path,

    # Repository owners whose links are resolved. Everything else is left alone: the
    # bounded set we control is where a moved target originates.
    [Parameter()]
    [string[]] $Owner = @('MSXOrg', 'PSModule', 'Storhaug-ting'),

    # Base URI of the GitHub REST API. Follows GITHUB_API_URL so the script works
    # unchanged on GitHub Enterprise Server.
    [Parameter()]
    [string] $ApiBaseUri = $(if ($env:GITHUB_API_URL) { $env:GITHUB_API_URL } else { 'https://api.github.com' }),

    # 'owner/repository' of the repository being checked, whose links resolve against
    # the checkout instead of the network. Discovered from the environment or the git
    # remote when not given.
    [Parameter()]
    [string] $SelfRepository = $env:GITHUB_REPOSITORY,

    # How many times a failing request is attempted before the link is called
    # unresolvable. A transient failure must not read as a broken link.
    [Parameter()]
    [ValidateRange(1, 10)]
    [int] $MaximumAttempt = 3
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

function ConvertTo-GitHubSlug {
    <#
        .SYNOPSIS
        Convert heading text to the anchor GitHub gives it.

        .DESCRIPTION
        Mirror github-slugger, the library GitHub uses: lowercase the text, drop every
        character that is not a letter, mark, decimal or letter number, or connector
        punctuation - keeping hyphens and spaces - then turn spaces into hyphens.

        The character class is .NET's Unicode categories rather than the generated
        table github-slugger ships. The two were compared across every code point and
        agree exactly over Basic Latin, Latin-1, Latin Extended-A and B, Greek,
        Cyrillic, General Punctuation, currency, letterlike and number forms, and the
        emoji planes. They disagree on 52 code points in the arrows and symbols blocks
        and 3 in CJK, where the two Unicode versions classify a character differently.

        .EXAMPLE
        ConvertTo-GitHubSlug -Text 'Prefer .NET for the actual work'
        Returns 'prefer-net-for-the-actual-work'.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The rendered heading text to convert.
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Text
    )
    return ($Text.ToLowerInvariant() -replace '[^\p{L}\p{M}\p{Nd}\p{Nl}\p{Pc}\- ]', '') -replace ' ', '-'
}

function Get-RenderedHeadingText {
    <#
        .SYNOPSIS
        Get the text a heading renders to, before it is turned into an anchor.

        .DESCRIPTION
        GitHub builds the anchor from the rendered heading, so the Markdown that only
        affects presentation is resolved first: a link keeps its text and loses its
        target, inline code keeps its content and loses its backticks, HTML tags and
        emphasis markers are dropped, and a trailing closing '#' run is removed.

        .EXAMPLE
        Get-RenderedHeadingText -Heading 'See the [guide](x.md) for `npm ci`'
        Returns 'See the guide for npm ci'.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The raw heading text, without its leading '#' characters.
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Heading
    )
    $text = $Heading -replace '!?\[([^\]]*)\]\([^)]*\)', '$1'
    $text = $text -replace '<[^>]*>', ''
    $text = $text -replace '[`*_~]', ''
    return ($text -replace '\s+#+\s*$', '').Trim()
}

function Get-MarkdownAnchor {
    <#
        .SYNOPSIS
        Get the anchors a Markdown document exposes.

        .DESCRIPTION
        Return every anchor in the document: one per heading, plus any explicit id on a
        raw HTML element, which GitHub honours as an anchor of its own. A repeated
        heading gets the '-1', '-2' suffix github-slugger appends, and the suffixed form
        is claimed too, so a heading colliding with an already generated suffix still
        gets a unique anchor. Fenced code blocks are skipped.

        Takes the document text rather than a path, because a cross-repository target
        arrives as an API response and never touches disk.

        .EXAMPLE
        Get-MarkdownAnchor -Markdown (Get-Content ./README.md -Raw)
        Returns the anchors README.md exposes.

        .OUTPUTS
        [System.Collections.Generic.HashSet[string]]
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.HashSet[string]])]
    param(
        # The Markdown document to scan.
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Markdown
    )
    $anchors = [System.Collections.Generic.HashSet[string]]::new()
    $occurrences = @{}
    $fence = $null
    foreach ($line in ($Markdown -split '\r?\n')) {
        if ($line -match '^\s{0,3}(`{3,}|~{3,})') {
            if ($null -eq $fence) {
                $fence = $matches[1]
            } elseif ($line -match "^\s{0,3}$([regex]::Escape($fence[0])){$($fence.Length),}\s*$") {
                $fence = $null
            }
            continue
        }
        if ($fence) { continue }
        foreach ($element in [regex]::Matches($line, '<[a-z][^>]*\sid\s*=\s*"([^"]+)"')) {
            $null = $anchors.Add($element.Groups[1].Value)
        }
        if ($line -notmatch '^\s{0,3}#{1,6}(\s+.*)?$') { continue }
        $slug = ConvertTo-GitHubSlug -Text (Get-RenderedHeadingText -Heading ($line -replace '^\s{0,3}#{1,6}\s*', ''))
        $unique = $slug
        while ($occurrences.ContainsKey($unique)) {
            $occurrences[$slug]++
            $unique = "$slug-$($occurrences[$slug])"
        }
        $occurrences[$unique] = 0
        $null = $anchors.Add($unique)
    }
    return $anchors
}

function Get-CrossRepositoryTarget {
    <#
        .SYNOPSIS
        Describe what an in-scope cross-repository URL points at.

        .DESCRIPTION
        Parse a link target into the repository, git reference, path, and fragment it
        addresses, or return nothing when the URL is not an in-scope file reference -
        a different host, an owner outside the configured set, or a route such as
        '/issues/' that names an API object rather than a path.

        .EXAMPLE
        Get-CrossRepositoryTarget -Url 'https://github.com/PSModule/Demo/blob/main/README.md#usage' -Owner PSModule
        Returns a descriptor for README.md at 'main' with the fragment 'usage'.

        .OUTPUTS
        [pscustomobject]
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # The raw link target as written in the Markdown.
        [Parameter(Mandatory)]
        [string] $Url,

        # Repository owners that are in scope.
        [Parameter(Mandatory)]
        [string[]] $Owner
    )
    [uri] $parsed = $null
    if (-not [uri]::TryCreate($Url, [System.UriKind]::Absolute, [ref] $parsed)) { return }
    if ($parsed.Scheme -notin 'http', 'https') { return }

    $hostName = $parsed.Host.ToLowerInvariant() -replace '^www\.', ''
    if ($hostName -notin 'github.com', 'raw.githubusercontent.com') { return }

    $segments = @($parsed.AbsolutePath.Trim('/') -split '/' | Where-Object { $_ } | ForEach-Object { [uri]::UnescapeDataString($_) })
    if ($segments.Count -lt 2) { return }
    if ($segments[0] -notin $Owner) { return }

    $fragment = if ($parsed.Fragment) { [uri]::UnescapeDataString($parsed.Fragment.TrimStart('#')) } else { '' }
    $target = [pscustomobject]@{
        Owner = $segments[0]
        Repository = $segments[1]
        Reference = ''
        ItemPath = ''
        Fragment = $fragment
    }

    if ($hostName -eq 'raw.githubusercontent.com') {
        if ($segments.Count -lt 4) { return }
        $target.Reference = $segments[2]
        $target.ItemPath = ($segments[3..($segments.Count - 1)] -join '/')
        return $target
    }

    if ($segments.Count -eq 2) {
        # A repository landing page renders its README, so an anchor on it is an
        # anchor in that file. Without a fragment only the repository is checked.
        if ($fragment) { $target.ItemPath = 'README.md' }
        return $target
    }

    if ($segments[2] -notin 'blob', 'tree', 'raw') { return }
    if ($segments.Count -lt 4) { return }
    $target.Reference = $segments[3]
    if ($segments.Count -gt 4) { $target.ItemPath = ($segments[4..($segments.Count - 1)] -join '/') }
    return $target
}

function Invoke-GitHubRequest {
    <#
        .SYNOPSIS
        Send one GitHub REST request and classify how it went.

        .DESCRIPTION
        Return the status code and body, or a failure description when the check could
        not get an answer. A transient failure - a connection error or a 5xx - is
        retried with a growing delay before it is given up on, so a blip does not read
        as a broken link. An exhausted rate limit is recognised from the response
        headers and not retried, because waiting will not help within a run.

        .EXAMPLE
        Invoke-GitHubRequest -Uri 'https://api.github.com/repos/PSModule/Demo' -MaximumAttempt 3
        Returns the status code and body, or the reason no answer was obtained.

        .OUTPUTS
        [pscustomobject]
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # Absolute URI to request.
        [Parameter(Mandatory)]
        [string] $Uri,

        # How many times to attempt the request before giving up.
        [Parameter(Mandatory)]
        [int] $MaximumAttempt
    )
    $headers = @{
        Accept = 'application/vnd.github+json'
        'X-GitHub-Api-Version' = '2022-11-28'
        'User-Agent' = 'MSXOrg-docs-cross-repository-link-check'
    }
    # Only for rate-limit headroom. It unlocks no repository a reader could not open,
    # which is exactly the visibility this check is supposed to measure.
    if ($env:GITHUB_TOKEN) { $headers['Authorization'] = "Bearer $env:GITHUB_TOKEN" }

    $lastProblem = 'no attempt was made'
    for ($attempt = 1; $attempt -le $MaximumAttempt; $attempt++) {
        try {
            $response = Invoke-WebRequest -Uri $Uri -Headers $headers -SkipHttpErrorCheck -MaximumRedirection 5 -TimeoutSec 30
        } catch {
            $lastProblem = $_.Exception.Message
            if ($attempt -lt $MaximumAttempt) {
                Start-Sleep -Seconds $attempt
                continue
            }
            return [pscustomobject]@{ StatusCode = 0; Content = ''; Failure = "the request failed after $MaximumAttempt attempt(s): $lastProblem" }
        }

        $status = [int] $response.StatusCode
        if ($status -in 403, 429) {
            $remaining = if ($response.Headers.ContainsKey('x-ratelimit-remaining')) { @($response.Headers['x-ratelimit-remaining'])[0] } else { '' }
            if ($remaining -eq '0') {
                $resetAt = 'an unknown time'
                if ($response.Headers.ContainsKey('x-ratelimit-reset')) {
                    $resetAt = [System.DateTimeOffset]::FromUnixTimeSeconds([long] @($response.Headers['x-ratelimit-reset'])[0]).ToString('u')
                }
                # Every later request would answer 403 too, so stop asking: the run is
                # already going to fail, and hammering a closed quota only slows it down.
                $script:rateLimitReached = if ($env:GITHUB_TOKEN) {
                    "the GitHub API rate limit is exhausted, resetting at $resetAt"
                } else {
                    "the GitHub API rate limit is exhausted, resetting at $resetAt - no GITHUB_TOKEN was set, so the anonymous limit of 60 requests an hour applied"
                }
                return [pscustomobject]@{ StatusCode = $status; Content = ''; Failure = $script:rateLimitReached }
            }
            return [pscustomobject]@{ StatusCode = $status; Content = ''; Failure = "the request was refused with HTTP $status after $attempt attempt(s)" }
        }
        if ($status -ge 500) {
            $lastProblem = "HTTP $status"
            if ($attempt -lt $MaximumAttempt) {
                Start-Sleep -Seconds $attempt
                continue
            }
            return [pscustomobject]@{ StatusCode = $status; Content = ''; Failure = "the request failed after $MaximumAttempt attempt(s): $lastProblem" }
        }
        if ($status -eq 401) {
            return [pscustomobject]@{ StatusCode = $status; Content = ''; Failure = 'the credentials the check runs with were rejected' }
        }
        return [pscustomobject]@{ StatusCode = $status; Content = [string] $response.Content; Failure = $null }
    }
    return [pscustomobject]@{ StatusCode = 0; Content = ''; Failure = "the request failed after $MaximumAttempt attempt(s): $lastProblem" }
}

$script:responseCache = @{}
$script:rateLimitReached = $null
function Get-CachedGitHubRequest {
    <#
        .SYNOPSIS
        Send a GitHub REST request, sending each distinct URI only once.

        .DESCRIPTION
        Memoise Invoke-GitHubRequest, so a target linked from ten pages costs one
        request rather than ten. Documentation repeats its links, and the rate limit
        is the scarce resource here.

        Once the quota is gone it stops asking altogether. Every later request would
        answer 403 the same way, and the run is already going to fail; continuing to
        ask only makes it slower and the reason harder to read.

        .EXAMPLE
        Get-CachedGitHubRequest -Uri 'https://api.github.com/repos/PSModule/Demo' -MaximumAttempt 3
        Returns the response, reaching the network only on the first call.

        .OUTPUTS
        [pscustomobject]
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # Absolute URI to request.
        [Parameter(Mandatory)]
        [string] $Uri,

        # How many times to attempt the request before giving up.
        [Parameter(Mandatory)]
        [int] $MaximumAttempt
    )
    if ($script:rateLimitReached) {
        return [pscustomobject]@{ StatusCode = 0; Content = ''; Failure = $script:rateLimitReached }
    }
    if (-not $script:responseCache.ContainsKey($Uri)) {
        $script:responseCache[$Uri] = Invoke-GitHubRequest -Uri $Uri -MaximumAttempt $MaximumAttempt
    }
    return $script:responseCache[$Uri]
}

function Get-ContentUri {
    <#
        .SYNOPSIS
        Build the contents-API URI for a target.

        .DESCRIPTION
        Compose the repository contents endpoint for the target's path, pinned to the
        target's git reference when the link carried one. A link without a reference
        resolves against the repository's default branch, which is what a reader
        following it gets.

        .EXAMPLE
        Get-ContentUri -Target $target -ApiBaseUri 'https://api.github.com'
        Returns the endpoint that answers whether the target's path exists.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The target descriptor from Get-CrossRepositoryTarget.
        [Parameter(Mandatory)]
        [pscustomobject] $Target,

        # Base URI of the GitHub REST API.
        [Parameter(Mandatory)]
        [string] $ApiBaseUri
    )
    $encoded = ($Target.ItemPath -split '/' | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
    $uri = "$($ApiBaseUri.TrimEnd('/'))/repos/$($Target.Owner)/$($Target.Repository)/contents/$encoded"
    if ($Target.Reference) { $uri += "?ref=$([uri]::EscapeDataString($Target.Reference))" }
    return $uri
}

function Get-DocumentText {
    <#
        .SYNOPSIS
        Get the text of a file from a contents-API response.

        .DESCRIPTION
        Decode the base64 body the contents endpoint inlines. A file above the inline
        size limit arrives with an empty body and a download URL instead, so that is
        followed rather than treated as an empty document - an empty document exposes
        no anchors, and every anchor into it would be reported broken.

        .EXAMPLE
        Get-DocumentText -Payload $payload -MaximumAttempt 3
        Returns the file's text.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The parsed contents-API response for a file.
        [Parameter(Mandatory)]
        [psobject] $Payload,

        # How many times to attempt a follow-up request before giving up.
        [Parameter(Mandatory)]
        [int] $MaximumAttempt
    )
    $names = $Payload.PSObject.Properties.Name
    if (($names -contains 'content') -and $Payload.content) {
        return [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(($Payload.content -replace '\s', '')))
    }
    if (($names -contains 'download_url') -and $Payload.download_url) {
        $download = Get-CachedGitHubRequest -Uri $Payload.download_url -MaximumAttempt $MaximumAttempt
        if (-not $download.Failure -and $download.StatusCode -eq 200) { return $download.Content }
    }
    return ''
}

function Get-LocalTargetOutcome {
    <#
        .SYNOPSIS
        Resolve a link into the repository being checked against the checkout.

        .DESCRIPTION
        A link back into this repository is answered from the working tree rather than
        from the default branch over the API. Resolved remotely it would confirm the
        state the change is about to invalidate: a pull request that moves the file
        would pass, and the link would break as it merged.

        .EXAMPLE
        Get-LocalTargetOutcome -Target $target -Root /repo
        Returns whether the path and anchor exist in the checkout.

        .OUTPUTS
        [pscustomobject]
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # The target descriptor from Get-CrossRepositoryTarget.
        [Parameter(Mandatory)]
        [pscustomobject] $Target,

        # Repository root the target's path is resolved against.
        [Parameter(Mandatory)]
        [string] $Root
    )
    if (-not $Target.ItemPath) {
        return [pscustomobject]@{ Outcome = 'Resolved'; Reason = '' }
    }
    $resolved = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($Root, ($Target.ItemPath -replace '/', [System.IO.Path]::DirectorySeparatorChar)))
    if ([System.IO.Directory]::Exists($resolved)) {
        if (-not $Target.Fragment) { return [pscustomobject]@{ Outcome = 'Resolved'; Reason = '' } }
        return [pscustomobject]@{ Outcome = 'Broken'; Reason = "the anchor '#$($Target.Fragment)' points into a directory" }
    }
    if (-not [System.IO.File]::Exists($resolved)) {
        return [pscustomobject]@{ Outcome = 'Broken'; Reason = "the target does not exist in this repository's checkout" }
    }
    if (-not $Target.Fragment) { return [pscustomobject]@{ Outcome = 'Resolved'; Reason = '' } }
    if (-not $Target.ItemPath.EndsWith('.md', [System.StringComparison]::OrdinalIgnoreCase)) {
        return [pscustomobject]@{ Outcome = 'Broken'; Reason = "the anchor '#$($Target.Fragment)' points into a file that is not Markdown" }
    }
    $anchors = Get-MarkdownAnchor -Markdown ([System.IO.File]::ReadAllText($resolved))
    if ($Target.Fragment -cnotin $anchors) {
        return [pscustomobject]@{ Outcome = 'Broken'; Reason = "no heading in the target file produces the anchor '#$($Target.Fragment)'" }
    }
    return [pscustomobject]@{ Outcome = 'Resolved'; Reason = '' }
}

function Get-RemoteTargetOutcome {
    <#
        .SYNOPSIS
        Resolve a link into another repository against that repository.

        .DESCRIPTION
        Ask the contents endpoint whether the path exists and, for Markdown with an
        anchor, whether a heading produces it. A 404 is not conclusive on its own -
        it answers the same for a deleted file and for a repository no anonymous
        reader can open - so the repository itself is probed before the link is called
        broken, and an unreadable repository is reported as unresolvable instead.

        .EXAMPLE
        Get-RemoteTargetOutcome -Target $target -ApiBaseUri 'https://api.github.com' -MaximumAttempt 3
        Returns whether the path and anchor exist in the target repository.

        .OUTPUTS
        [pscustomobject]
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # The target descriptor from Get-CrossRepositoryTarget.
        [Parameter(Mandatory)]
        [pscustomobject] $Target,

        # Base URI of the GitHub REST API.
        [Parameter(Mandatory)]
        [string] $ApiBaseUri,

        # How many times to attempt a request before giving up.
        [Parameter(Mandatory)]
        [int] $MaximumAttempt
    )
    $repository = "$($Target.Owner)/$($Target.Repository)"
    $repositoryUri = "$($ApiBaseUri.TrimEnd('/'))/repos/$repository"

    if (-not $Target.ItemPath) {
        $probe = Get-CachedGitHubRequest -Uri $repositoryUri -MaximumAttempt $MaximumAttempt
        if ($probe.Failure) { return [pscustomobject]@{ Outcome = 'Unresolvable'; Reason = $probe.Failure } }
        if ($probe.StatusCode -eq 200) { return [pscustomobject]@{ Outcome = 'Resolved'; Reason = '' } }
        return [pscustomobject]@{ Outcome = 'Unresolvable'; Reason = "$repository is not publicly readable, so a reader cannot follow this link either" }
    }

    $response = Get-CachedGitHubRequest -Uri (Get-ContentUri -Target $Target -ApiBaseUri $ApiBaseUri) -MaximumAttempt $MaximumAttempt
    if ($response.Failure) { return [pscustomobject]@{ Outcome = 'Unresolvable'; Reason = $response.Failure } }

    if ($response.StatusCode -eq 404) {
        $probe = Get-CachedGitHubRequest -Uri $repositoryUri -MaximumAttempt $MaximumAttempt
        if ($probe.Failure) { return [pscustomobject]@{ Outcome = 'Unresolvable'; Reason = $probe.Failure } }
        if ($probe.StatusCode -ne 200) {
            return [pscustomobject]@{ Outcome = 'Unresolvable'; Reason = "$repository is not publicly readable, so a reader cannot follow this link either" }
        }
        $at = if ($Target.Reference) { " at '$($Target.Reference)'" } else { ' on the default branch' }
        return [pscustomobject]@{ Outcome = 'Broken'; Reason = "the target does not exist in $repository$at" }
    }
    if ($response.StatusCode -ne 200) {
        return [pscustomobject]@{ Outcome = 'Unresolvable'; Reason = "the request answered HTTP $($response.StatusCode)" }
    }

    # An array is a directory listing; an object is a single file.
    if ($response.Content.TrimStart().StartsWith('[')) {
        if (-not $Target.Fragment) { return [pscustomobject]@{ Outcome = 'Resolved'; Reason = '' } }
        return [pscustomobject]@{ Outcome = 'Broken'; Reason = "the anchor '#$($Target.Fragment)' points into a directory" }
    }
    if (-not $Target.Fragment) { return [pscustomobject]@{ Outcome = 'Resolved'; Reason = '' } }
    if (-not $Target.ItemPath.EndsWith('.md', [System.StringComparison]::OrdinalIgnoreCase)) {
        return [pscustomobject]@{ Outcome = 'Broken'; Reason = "the anchor '#$($Target.Fragment)' points into a file that is not Markdown" }
    }

    $document = Get-DocumentText -Payload ($response.Content | ConvertFrom-Json) -MaximumAttempt $MaximumAttempt
    if (-not $document) {
        return [pscustomobject]@{ Outcome = 'Unresolvable'; Reason = 'the target file was fetched but arrived empty, so its anchors are unknown' }
    }
    if ($Target.Fragment -cnotin (Get-MarkdownAnchor -Markdown $document)) {
        return [pscustomobject]@{ Outcome = 'Broken'; Reason = "no heading in the target file produces the anchor '#$($Target.Fragment)'" }
    }
    return [pscustomobject]@{ Outcome = 'Resolved'; Reason = '' }
}

function Write-WorkflowAnnotation {
    <#
        .SYNOPSIS
        Emit a GitHub Actions annotation that renders above the collapsed log.

        .DESCRIPTION
        Write a '::notice::' or '::error::' workflow command with the dynamic parts
        percent-encoded, so a value carrying '%', a newline, a colon, or a comma cannot
        corrupt or break out of the single-line command. Outside Actions it writes
        nothing, so a local run is not littered with workflow commands.

        .EXAMPLE
        Write-WorkflowAnnotation -Type notice -Title 'Cross-repository links' -Message '21 link(s) resolve'
        Renders a notice on the run summary and in the Checks view.

        .OUTPUTS
        None
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
    if (-not $env:GITHUB_ACTIONS) { return }
    $encodedMessage = $Message -replace '%', '%25' -replace "`r", '%0D' -replace "`n", '%0A'
    $encodedTitle = $Title -replace '%', '%25' -replace "`r", '%0D' -replace "`n", '%0A' -replace ':', '%3A' -replace ',', '%2C'
    Write-Output "::${Type} title=${encodedTitle}::${encodedMessage}"
}

if (-not $SelfRepository) {
    # A copy of this script in another repository needs no edit: the repository it is
    # running in comes from the environment, or from the remote it was cloned from.
    try {
        $remote = & git -C $Root remote get-url origin 2>$null
        if ($LASTEXITCODE -eq 0 -and $remote -match '[:/]([^/:]+)/([^/]+?)(\.git)?$') {
            $SelfRepository = "$($matches[1])/$($matches[2])"
        }
    } catch {
        Write-Verbose "Could not resolve the current repository from git: $($_.Exception.Message)"
    }
}

# Inline links '[text](target)', reference-style definitions '[label]: target', and
# autolinks '<https://...>'. The inline target may carry a title ("...", '...', or
# (...)); the nested-paren alternative keeps a parenthesised title from truncating it.
# A label starting with '^' is a footnote definition, whose body is prose rather than
# a destination.
$inlineLinkPattern = '\[[^\]]*\]\(([^()]*(?:\([^()]*\)[^()]*)*)\)'
$referenceDefinitionPattern = '^\s{0,3}\[(?!\^)[^\]]+\]:\s+(<[^>]+>|\S+)'
$autolinkPattern = '<(https?://[^>\s]+)>'

$files = @(if ($Path) {
        $Path | ForEach-Object { Get-Item -LiteralPath ([System.IO.Path]::Combine($Root, $_)) }
    } else {
        # The exclusion is tested against the path below the root, not the full path: a
        # clone can itself sit under a dotted directory, and matching on the full path
        # would then exclude every file in the repository and report a vacuous pass.
        Get-ChildItem -LiteralPath $Root -Recurse -File -Filter *.md |
            Where-Object {
                $relative = $_.FullName.Substring($Root.Length)
                $relative -notmatch '[\\/](\.[^\\/]+|node_modules)[\\/]' -and $relative -notmatch '^[\\/]src[\\/]site[\\/]'
            } |
            Sort-Object FullName
    })

$broken = [System.Collections.Generic.List[string]]::new()
$unresolvable = [System.Collections.Generic.List[string]]::new()
$checked = 0

foreach ($file in $files) {
    $display = $file.FullName.Substring($Root.Length).TrimStart('\', '/').Replace('\', '/')
    $lines = [System.IO.File]::ReadAllLines($file.FullName)
    $fence = $null
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        if ($line -match '^\s{0,3}(`{3,}|~{3,})') {
            if ($null -eq $fence) {
                $fence = $matches[1]
            } elseif ($line -match "^\s{0,3}$([regex]::Escape($fence[0])){$($fence.Length),}\s*$") {
                $fence = $null
            }
            continue
        }
        if ($fence) { continue }

        # Inline code spans hold examples, not links that have to resolve.
        $scrubbed = $line -replace '`[^`]*`', ''
        $lineNumber = $index + 1
        $targets = @([regex]::Matches($scrubbed, $inlineLinkPattern) | ForEach-Object { $_.Groups[1].Value })
        $targets += @([regex]::Matches($scrubbed, $autolinkPattern) | ForEach-Object { $_.Groups[1].Value })
        if ($scrubbed -match $referenceDefinitionPattern) { $targets += $matches[1] }

        foreach ($raw in $targets) {
            $url = ($raw.Trim() -replace '\s+("[^"]*"|''[^'']*''|\([^)]*\))$', '') -replace '^<', '' -replace '>$', ''
            $target = Get-CrossRepositoryTarget -Url $url -Owner $Owner
            if (-not $target) { continue }

            $checked++
            $outcome = if ("$($target.Owner)/$($target.Repository)" -eq $SelfRepository) {
                Get-LocalTargetOutcome -Target $target -Root $Root
            } else {
                Get-RemoteTargetOutcome -Target $target -ApiBaseUri $ApiBaseUri -MaximumAttempt $MaximumAttempt
            }

            switch ($outcome.Outcome) {
                'Broken' { $broken.Add("${display}:${lineNumber}: '$url' - $($outcome.Reason)") }
                'Unresolvable' { $unresolvable.Add("${display}:${lineNumber}: '$url' - $($outcome.Reason)") }
            }
        }
    }
}

if ($checked -eq 0) {
    Write-Output "No cross-repository link into $($Owner -join ', ') was found in $($files.Count) file(s) under $Root - nothing was validated."
    Write-Output 'A check that checked nothing is a failure, not a pass.'
    Write-WorkflowAnnotation -Type error -Title 'Cross-repository links' -Message "No link was found in $($files.Count) file(s), so this run proved nothing."
    exit 1
}

$summary = "$checked cross-repository link(s) checked in $($files.Count) file(s)."
if ($broken.Count -eq 0 -and $unresolvable.Count -eq 0) {
    Write-Output "$summary Every one of them resolves."
    Write-WorkflowAnnotation -Type notice -Title 'Cross-repository links' -Message "$checked link(s) resolve."
    exit 0
}

Write-Output $summary
if ($broken.Count -gt 0) {
    Write-Output ''
    Write-Output "Broken cross-repository links ($($broken.Count)) - the target repository was read and the target was not there:"
    $broken | Sort-Object | ForEach-Object { Write-Output "  - $_" }
}
if ($unresolvable.Count -gt 0) {
    Write-Output ''
    Write-Output "Cross-repository links that could not be resolved ($($unresolvable.Count)) - the check got no answer, which is not the same as a broken link:"
    $unresolvable | Sort-Object | ForEach-Object { Write-Output "  - $_" }
}
Write-WorkflowAnnotation -Type error -Title 'Cross-repository links' -Message "$($broken.Count) link(s) point at something that is not there; $($unresolvable.Count) could not be checked at all."
exit 1
