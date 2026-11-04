#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Validate that every cross-repository Markdown link into an MSX organization resolves.

.DESCRIPTION
    The Markdown standard specifies canonical published URLs for cross-repository references.
    'Test-DocumentationLink.ps1' ignores external links.
    This script validates links to repositories whose files can change independently.

    The configured owners define the validation scope.
    The script resolves only 'github.com' and 'raw.githubusercontent.com' links owned by '-Owner'.
    This scope avoids failures from unrelated websites.

    The script resolves these URL shapes:

    - 'https://github.com/OWNER/REPO'                            the repository exists
    - 'https://github.com/OWNER/REPO#anchor'                     an anchor in its README
    - 'https://github.com/OWNER/REPO?tab=readme-ov-file#anchor'  the same, GitHub's own form
    - 'https://github.com/OWNER/REPO/blob/REF/PATH#anchor'       a file, and its anchor
    - 'https://github.com/OWNER/REPO/tree/REF/PATH'              a directory
    - 'https://raw.githubusercontent.com/OWNER/REPO/REF/PATH'    a file

    The script ignores other routes under an in-scope repository, such as '/issues/',
    '/pull/', '/discussions/', '/releases/', '/actions/', '/wiki/', '/compare/', and '/commit/'.
    These routes identify API objects, not repository file paths.

    A HEAD request cannot validate an anchor because the request does not include the URL fragment.
    A response of 200 for '.../file.md#heading' does not prove that the heading exists.
    The script reads the content and derives anchors with GitHub's slug rules.
    'ConvertTo-Slug' in 'Test-DocumentationLink.ps1' uses python-markdown's rules for the published site.
    Those rules differ from GitHub's rules.

    The script resolves links into its own repository against the checkout, not the remote default branch.
    This verifies file moves and link changes in the pull request.

    The script distinguishes resolved, *broken*, and *unresolvable* links.
    A link is *broken* when the repository is readable but the path or anchor does not exist.
    A link is *unresolvable* after a network failure or an exhausted API rate limit.
    A target that is not publicly readable is also *unresolvable*.
    The console log lists broken and unresolvable links under separate headings.

    The check uses anonymous-reader access as its reference.
    In CI, GITHUB_TOKEN increases the rate limit from 60 to 1000 requests an hour.
    That token grants no access to private repositories elsewhere.
    Public documentation needs links that its readers can open.

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
    System.String

    Status and diagnostic log text, not structured link results.
    If GITHUB_ACTIONS has a value, the script also emits workflow annotation strings.
    The exit code reports whether validation succeeds.

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
    # Repository-root-relative Markdown files to validate. Default: every Markdown file
    # outside dot-directories, node_modules, and src/site.
    [Parameter()]
    [string[]] $Path,

    # Repository owners whose links the script resolves.
    # Links to other owners remain outside the validation scope.
    [Parameter()]
    [string[]] $Owner = @('MSXOrg', 'PSModule', 'Storhaug-ting'),

    # GitHub REST API root. GITHUB_API_URL supplies the default when it has a value.
    # Otherwise, the default is https://api.github.com.
    [Parameter()]
    [string] $ApiBaseUri = $(if ($env:GITHUB_API_URL) { $env:GITHUB_API_URL } else { 'https://api.github.com' }),

    # 'owner/repository' for the repository that uses checkout validation.
    # If omitted, the script uses GITHUB_REPOSITORY or the git remote.
    # Its own repository links do not use network requests.
    [Parameter()]
    [string] $SelfRepository = $env:GITHUB_REPOSITORY,

    # Maximum number of attempts for a request before the result is unresolvable.
    # Transient request failures do not establish that the link target is missing.
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
        Convert rendered heading text to a GitHub anchor slug.

        .DESCRIPTION
        The function uses github-slugger's character rules.
        It converts the text to lowercase.
        It retains letters, marks, decimal numbers, letter numbers, connector
        punctuation, hyphens, and spaces.
        It removes other characters and replaces each space with a hyphen.

        The character class uses .NET Unicode categories instead of github-slugger's
        generated table. A recorded comparison covered every code point.
        Results matched for Basic Latin, Latin-1, Latin Extended-A and B, Greek, and Cyrillic.
        They also matched for General Punctuation, currency, letterlike and number forms, and the emoji planes.
        The comparison found differences in 52 code points in the arrows and symbols blocks and 3 in CJK.
        The two Unicode versions classify those characters differently.

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
        The function returns heading anchors and explicit ids from raw HTML elements.
        GitHub uses those ids as anchors.
        The function adds '-1', '-2' suffixes to duplicate heading slugs, as github-slugger does.
        It also reserves each suffixed slug.
        If another heading has that slug, the function assigns a unique suffix.
        It ignores headings inside fenced code blocks.

        The function accepts document text, not a file path.
        Cross-repository content comes from API responses and does not require a local file.

        .EXAMPLE
        Get-MarkdownAnchor -Markdown (Get-Content ./README.md -Raw)
        Returns the anchors README.md exposes.

        .OUTPUTS
        [string]

        Heading and explicit HTML-anchor strings, one item per anchor.
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
        Describe the target of an in-scope cross-repository URL.

        .DESCRIPTION
        The function parses a link target into its repository, git reference, path, and fragment.
        It returns no output when the host or owner is outside the configured scope.
        It also ignores routes such as '/issues/' that identify API objects instead of file paths.

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
        Send one GitHub REST request and report its result.

        .DESCRIPTION
        The function returns the status code and response body, or a request-failure description.
        It retries connection errors and 5xx responses with an increasing delay.
        A transient request failure does not establish that a link target is missing.

        Rate-limit response headers identify an exhausted limit.
        The function does not retry that limit within the run.

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

        # Maximum number of request attempts.
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
        Get a GitHub REST response from the cache or network.

        .DESCRIPTION
        The function stores Invoke-GitHubRequest results by URI.
        Repeated references to the same target reuse one response.
        This limits duplicate requests against the API quota.

        After the quota is exhausted, the function stops network requests.
        It returns the rate-limit failure for each later request.
        The run already has a failure, so more requests cannot produce a passing result.

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

        # Maximum number of request attempts.
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
        Build the contents-API URI for a link target.

        .DESCRIPTION
        The function builds the repository contents endpoint for the target path.
        If the link includes a git reference, the URI uses that reference.
        Otherwise, it uses the repository's default branch.

        A reference without a path identifies the repository root at that reference.
        This includes 'github.com/OWNER/REPO/tree/REF'.
        An invalid branch or tag returns 404, even when the repository exists.

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
    $uri = "$($ApiBaseUri.TrimEnd('/'))/repos/$($Target.Owner)/$($Target.Repository)/contents/$encoded".TrimEnd('/')
    if ($Target.Reference) { $uri += "?ref=$([uri]::EscapeDataString($Target.Reference))" }
    return $uri
}

function Get-DocumentText {
    <#
        .SYNOPSIS
        Get the text of a file from a contents-API response.

        .DESCRIPTION
        The function decodes the base64 content in a contents-API response.
        Files above the inline size limit supply a download URL instead of inline content.
        The function uses that URL to get the file text.
        This avoids treating a download response as an empty document with no anchors.
        If content is unavailable, the function returns an empty string.

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

        # Maximum number of attempts for a follow-up request.
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
        Resolve a link into this repository against the checkout.

        .DESCRIPTION
        The function resolves links into this repository against the working tree.
        It does not use the default branch's remote API state.
        This includes file moves and link changes from the pull request.

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

        # Repository root for the target's relative path.
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
        Resolve a link into another repository through the GitHub REST API.

        .DESCRIPTION
        For a file or directory target, the function uses the contents endpoint.
        For Markdown targets with an anchor, it also compares the anchor with the document's anchors.
        A git reference without a path identifies the repository root at that reference.
        This includes 'github.com/OWNER/REPO/tree/REF'.
        An invalid branch or tag does not pass merely because the repository exists.

        A 404 response can mean a missing file or an unreadable repository.
        The function then requests the repository itself to distinguish those cases.
        It reports an unreadable repository as unresolvable, not broken.

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

        # Maximum number of request attempts.
        [Parameter(Mandatory)]
        [int] $MaximumAttempt
    )
    $repository = "$($Target.Owner)/$($Target.Repository)"
    $repositoryUri = "$($ApiBaseUri.TrimEnd('/'))/repos/$repository"

    if (-not $Target.ItemPath -and -not $Target.Reference) {
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
        if (-not $Target.ItemPath) {
            return [pscustomobject]@{ Outcome = 'Broken'; Reason = "$repository has no branch, tag, or commit named '$($Target.Reference)'" }
        }
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
        Emit a GitHub Actions annotation.

        .DESCRIPTION
        The function writes a '::notice::' or '::error::' workflow command.
        It percent-encodes '%' and line breaks in the title and message.
        It also encodes ':' and ',' in the title to preserve the command properties.

        .EXAMPLE
        Write-WorkflowAnnotation -Type notice -Title 'Cross-repository links' -Message '21 link(s) resolve'
        Renders a notice on the run summary and in the Checks view.

        .OUTPUTS
        [string]

        An annotation string when GITHUB_ACTIONS has a value.
        No item when GITHUB_ACTIONS has no value.
    #>
    [CmdletBinding()]
    param(
        # Annotation severity, which controls how GitHub displays it.
        [Parameter(Mandatory)]
        [ValidateSet('notice', 'warning', 'error')]
        [string] $Type,

        # Short title that GitHub shows in bold on the annotation.
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
