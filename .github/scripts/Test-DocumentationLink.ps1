#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Validate that every relative Markdown link and heading anchor in the docs resolves.

.DESCRIPTION
    Walks the documentation content under src/docs and checks every inline
    Markdown link:

    - A relative file target must exist on disk - a link to '../Foo.md' or
      'Bar/index.md' has to resolve to a real file or directory.
    - A heading anchor ('target.md#section', or a same-page '#section') must match
      a heading in the target file. Slugs are computed the same way the site's
      Markdown processor does, including the '_1', '_2' suffixes for duplicate
      headings; an explicit attr_list id ('## Heading { #id }') is recognised as
      the heading's anchor.

    External links (http, https, mailto, tel), absolute paths, links inside fenced
    code blocks, and links inside inline code spans are ignored on purpose.

    The script changes nothing. It exits 0 when every link resolves and exits 1,
    listing each broken link, otherwise - so it can gate a pull request and a push
    to main in CI, alongside linting.

.EXAMPLE
    ./Test-DocumentationLink.ps1
    Validates all documentation links; exits non-zero and lists any that are broken.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Docs = Join-Path $Root 'src/docs'

function ConvertTo-Slug {
    <#
        .SYNOPSIS
        Convert a heading to the anchor slug the site's Markdown processor emits.

        .DESCRIPTION
        Mirror python-markdown's default TOC slugifier: drop non-ASCII characters,
        remove punctuation except word characters, whitespace, and hyphens,
        lowercase the result, then collapse whitespace and hyphen runs into a
        single hyphen.

        .EXAMPLE
        ConvertTo-Slug -Heading 'Prefer .NET for the actual work'
        Returns 'prefer-net-for-the-actual-work'.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    param(
        # The heading text to slugify.
        [Parameter(Mandatory)]
        [string] $Heading
    )
    $ascii = $Heading -replace '[^\x00-\x7F]', ''
    $clean = ($ascii -replace '[^\w\s-]', '').Trim().ToLowerInvariant()
    return ($clean -replace '[\s-]+', '-')
}

function Get-HeadingSlug {
    <#
        .SYNOPSIS
        Get the anchor slugs a Markdown file exposes.

        .DESCRIPTION
        Return each heading's anchor, matching the duplicate-slug suffixing
        ('_1', '_2', ...) the Markdown processor applies to repeated headings. A
        heading may also carry an explicit attr_list id ('## Heading { #id }'),
        which the site renderer uses as the anchor verbatim, overriding the text
        slug; those are recognised so links to '#id' validate. Fenced code blocks
        are skipped.

        .EXAMPLE
        Get-HeadingSlug -Path ./src/docs/index.md
        Returns the anchor slugs and explicit ids defined in index.md.

        .OUTPUTS
        [System.Collections.Generic.List[string]]
    #>
    [CmdletBinding()]
    param(
        # Path to the Markdown file to scan for heading anchors.
        [Parameter(Mandatory)]
        [string] $Path
    )
    $slugs = [System.Collections.Generic.List[string]]::new()
    $seen = @{}
    $inFence = $false
    foreach ($line in [System.IO.File]::ReadAllLines($Path)) {
        if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        if ($line -match '^#{1,6}\s+(.+?)\s*$') {
            $text = $matches[1]
            # An explicit attr_list id ('{ #id }' or '{: #id ... }') wins over
            # the text slug, exactly as python-markdown's attr_list assigns it.
            if ($text -match '\{\s*:?\s*#([-\w]+)[^}]*\}\s*$') {
                $slugs.Add($matches[1])
                continue
            }
            $base = ConvertTo-Slug $text
            if (-not $base) { continue }
            if ($seen.ContainsKey($base)) { $seen[$base]++; $slugs.Add("${base}_$($seen[$base])") }
            else { $seen[$base] = 0; $slugs.Add($base) }
        }
    }
    return $slugs
}

$slugCache = @{}
function Get-CachedSlug {
    <#
        .SYNOPSIS
        Get a file's heading slugs, parsing each file only once.

        .DESCRIPTION
        Memoise Get-HeadingSlug in the script-scoped $slugCache so a file that is
        linked from many places is scanned a single time.

        .EXAMPLE
        Get-CachedSlug -Path ./src/docs/index.md
        Returns index.md's anchor slugs, reading the file only on the first call.

        .OUTPUTS
        [System.Collections.Generic.List[string]]
    #>
    [CmdletBinding()]
    param(
        # Path to the Markdown file whose slugs are wanted.
        [Parameter(Mandatory)]
        [string] $Path
    )
    if (-not $slugCache.ContainsKey($Path)) { $slugCache[$Path] = Get-HeadingSlug $Path }
    return $slugCache[$Path]
}

function Get-LinkTargetIssue {
    <#
        .SYNOPSIS
        Get the problem with a single relative Markdown link target, if any.

        .DESCRIPTION
        Validate one inline or reference-style link target: external links,
        absolute site paths, and empty targets are ignored; a relative file must
        exist; and a '#fragment' must match a heading anchor (case-sensitively)
        either in the target file or on the same page. Return a human-readable
        message when the target does not resolve, or nothing when it is valid.

        .EXAMPLE
        Get-LinkTargetIssue -Target '../reference/bar.md#setup' -File $file -Rel 'docs/foo.md' -LineNo 12
        Returns a message when bar.md or its '#setup' anchor is missing, otherwise nothing.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    param(
        # The raw link target - a destination and an optional '#fragment'.
        [Parameter(Mandatory)]
        [string] $Target,

        # The Markdown file the link appears in, used to resolve relative paths.
        [Parameter(Mandatory)]
        [System.IO.FileInfo] $File,

        # The file's repository-relative path, for the reported message.
        [Parameter(Mandatory)]
        [string] $Rel,

        # The 1-based line number the link is on, for the reported message.
        [Parameter(Mandatory)]
        [int] $LineNo
    )
    $t = ($Target.Trim() -replace '\s+("[^"]*"|''[^'']*''|\([^)]*\))$', '') -replace '^<', '' -replace '>$', ''
    if (-not $t) { return }
    if ($t -match '^(https?:|mailto:|tel:|//)') { return }
    $path, $frag = $t -split '#', 2
    if (-not $path) {
        if ($frag -and ($frag -cnotin (Get-CachedSlug $File.FullName))) {
            "${Rel}:${LineNo}: '#$frag' - no heading with that anchor on this page"
        }
        return
    }
    if ($path.StartsWith('/')) { return } # absolute site path - not resolvable here
    $resolved = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($File.DirectoryName, $path))
    if (-not ([System.IO.File]::Exists($resolved) -or [System.IO.Directory]::Exists($resolved))) {
        "${Rel}:${LineNo}: '$t' - target does not exist"
        return
    }
    if ($frag -and $resolved.EndsWith('.md', [System.StringComparison]::OrdinalIgnoreCase) -and ($frag -cnotin (Get-CachedSlug $resolved))) {
        "${Rel}:${LineNo}: '$t' - no heading '#$frag' in the target file"
    }
}

# Inline links '[text](target)' and reference-style definitions '[label]: target'.
# The inline target may carry an optional title ("...", '...', or (...)); the
# nested-paren alternative keeps a parenthesised title from being truncated. The
# definition destination is either an angle-bracketed path (which may contain
# spaces) or a bare non-whitespace token.
$linkPattern = '\[[^\]]*\]\(([^()]*(?:\([^()]*\)[^()]*)*)\)'
$refDefPattern = '^\s*\[[^\]]+\]:\s+(<[^>]+>|\S+)'
$broken = [System.Collections.Generic.List[string]]::new()

foreach ($file in (Get-ChildItem -LiteralPath $Docs -Recurse -File -Filter *.md | Sort-Object FullName)) {
    $rel = ($file.FullName.Substring($Root.Length).TrimStart('\', '/')) -replace '\\', '/'
    $lines = [System.IO.File]::ReadAllLines($file.FullName)
    $inFence = $false
    for ($n = 0; $n -lt $lines.Count; $n++) {
        $line = $lines[$n]
        if ($line -match '^\s*```') { $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        # Remove inline code spans so links shown as examples are not validated.
        $scrubbed = $line -replace '`[^`]*`', ''
        $lineNo = $n + 1
        foreach ($m in [regex]::Matches($scrubbed, $linkPattern)) {
            $issue = Get-LinkTargetIssue -Target $m.Groups[1].Value -File $file -Rel $rel -LineNo $lineNo
            if ($issue) { $broken.Add($issue) }
        }
        # Reference-style link definitions ('[label]: target') carry a relative
        # target too; validate it the same way so those links do not slip past CI.
        if ($scrubbed -match $refDefPattern) {
            $issue = Get-LinkTargetIssue -Target $matches[1] -File $file -Rel $rel -LineNo $lineNo
            if ($issue) { $broken.Add($issue) }
        }
    }
}

if ($broken.Count -eq 0) {
    Write-Output 'All documentation links resolve.'
    exit 0
}
Write-Output "Broken documentation links ($($broken.Count)):"
$broken | Sort-Object | ForEach-Object { Write-Output "  - $_" }
exit 1
