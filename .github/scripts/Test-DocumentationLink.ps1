#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Validate relative Markdown links and heading anchors in the documentation.

.DESCRIPTION
    The script reads Markdown files beneath src/docs.
    It validates inline link targets and reference-style link definitions:

    - A relative target such as '../Foo.md' or 'Bar/index.md' must identify an
      existing file or directory.
    - A heading anchor ('target.md#section', or a same-page '#section') must match
      an anchor in the target Markdown file. The site processor's slug rules add
      '_1', '_2' suffixes to duplicate headings.
      An explicit attr_list id ('## Heading {#id}') supplies the anchor directly.

    The script ignores external links (http, https, mailto, tel) and absolute site paths.
    It also ignores links inside fenced code blocks and inline code spans.
    Footnote definitions ('[^1]: ...') do not become link targets.
    The script still validates inline links in footnote text.

    The script does not change files.
    It exits 0 when every supported link resolves.
    If a target is missing or an anchor does not match, it lists the link and exits 1.
    If it finds no Markdown files, it exits 1.
    A Markdown file with no links does not cause a failure.

.EXAMPLE
    ./Test-DocumentationLink.ps1
    Validates all documentation links; exits non-zero and lists any that are broken.
.OUTPUTS
    System.String

    Link-validation status and diagnostic text, not structured link results.
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
        The function uses python-markdown's default TOC slug rules.
        It removes non-ASCII characters, then punctuation other than word characters,
        whitespace, and hyphens.
        It converts the text to lowercase and replaces each whitespace or hyphen
        sequence with one hyphen.

        .EXAMPLE
        ConvertTo-Slug -Heading 'Prefer .NET for the actual work'
        Returns 'prefer-net-for-the-actual-work'.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    param(
        # Heading text to convert to an anchor slug.
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
        The function returns heading anchors and explicit attr_list ids.
        The Markdown processor adds '_1', '_2', ... to duplicate heading slugs.
        An explicit attr_list id ('## Heading {#id}') replaces the text slug.
        The function ignores headings inside fenced code blocks.

        .EXAMPLE
        Get-HeadingSlug -Path ./src/docs/index.md
        Returns the anchor slugs and explicit ids defined in index.md.

        .OUTPUTS
        System.String

        Heading-anchor strings, one item per anchor.
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
            # An explicit attr_list id ('{#id}' or '{: #id ... }') wins over
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
        Get a file's heading slugs and cache the result.

        .DESCRIPTION
        The function stores Get-HeadingSlug results in the script-scoped $slugCache.
        It reads each file only on the first request.

        .EXAMPLE
        Get-CachedSlug -Path ./src/docs/index.md
        Returns index.md's anchor slugs, reading the file only on the first call.

        .OUTPUTS
        System.String

        Cached heading-anchor strings, one item per anchor.
    #>
    [CmdletBinding()]
    param(
        # Path to the Markdown file that contains the heading anchors.
        [Parameter(Mandatory)]
        [string] $Path
    )
    if (-not $slugCache.ContainsKey($Path)) { $slugCache[$Path] = Get-HeadingSlug $Path }
    return $slugCache[$Path]
}

function Get-LinkTargetIssue {
    <#
        .SYNOPSIS
        Get a message for an invalid relative Markdown link target.

        .DESCRIPTION
        The function validates one inline or reference-style link target.
        It ignores external links, absolute site paths, and empty targets.
        A relative target must identify an existing file or directory.

        For a Markdown target, a '#fragment' must match a heading anchor.
        A target that contains only a fragment refers to the same page.
        Anchor comparisons are case-sensitive.
        The function returns a message for an invalid target, or no output for a valid target.

        .EXAMPLE
        Get-LinkTargetIssue -Target '../reference/bar.md#setup' -File $file -Rel 'docs/foo.md' -LineNo 12
        Returns a message when bar.md or its '#setup' anchor is missing, otherwise nothing.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    param(
        # Link destination with an optional '#fragment'.
        [Parameter(Mandatory)]
        [string] $Target,

        # The Markdown file that contains the link. Relative paths start from its directory.
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
# spaces) or a bare non-whitespace token. A label starting with '^' is a footnote
# definition ('[^1]: some prose'), whose body is prose rather than a destination,
# so it is excluded - otherwise the footnote's first word is validated as a
# relative path and every footnote on the page is reported as a broken link. An
# inline link inside that prose is still caught by $linkPattern.
$linkPattern = '\[[^\]]*\]\(([^()]*(?:\([^()]*\)[^()]*)*)\)'
$refDefPattern = '^\s*\[(?!\^)[^\]]+\]:\s+(<[^>]+>|\S+)'
$broken = [System.Collections.Generic.List[string]]::new()
$scanned = 0

foreach ($file in (Get-ChildItem -LiteralPath $Docs -Recurse -File -Filter *.md | Sort-Object FullName)) {
    $scanned++
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

if ($scanned -eq 0) {
    Write-Output "No Markdown files were found under $Docs - nothing was validated."
    Write-Output 'A check that checked nothing is a failure, not a pass.'
    exit 1
}
if ($broken.Count -eq 0) {
    Write-Output "All documentation links resolve ($scanned file(s) scanned)."
    exit 0
}
Write-Output "Broken documentation links ($($broken.Count)):"
$broken | Sort-Object | ForEach-Object { Write-Output "  - $_" }
exit 1
