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
    param([string]$Heading)
    # Mirror the site's Markdown TOC slugifier (python-markdown default): drop
    # non-ASCII, remove punctuation except word characters / whitespace / hyphen,
    # lowercase, then collapse whitespace and hyphen runs into a single hyphen.
    $ascii = -join ([char[]] $Heading | Where-Object { [int] $_ -lt 128 })
    $clean = ($ascii -replace '[^\w\s-]', '').Trim().ToLowerInvariant()
    return ($clean -replace '[\s-]+', '-')
}

function Get-HeadingSlug {
    param([string]$Path)
    # The anchor slugs a page exposes, matching the duplicate-slug suffixing
    # ('_1', '_2', ...) the Markdown processor applies to repeated headings. A
    # heading may also carry an explicit attr_list id ('## Heading { #id }'),
    # which the site renderer uses as the anchor verbatim, overriding the text
    # slug; recognise those so links to '#id' validate.
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

# Parse each target file's anchors once.
$slugCache = @{}
function Get-CachedSlug {
    param([string]$Path)
    if (-not $slugCache.ContainsKey($Path)) { $slugCache[$Path] = Get-HeadingSlug $Path }
    return $slugCache[$Path]
}

function Test-LinkTarget {
    # Validate a single relative link target (inline or reference-style), adding
    # a message to $Broken when the file or its heading anchor does not resolve.
    param(
        [string]$Target,
        [System.IO.FileInfo]$File,
        [string]$Rel,
        [int]$LineNo,
        [System.Collections.Generic.List[string]]$Broken
    )
    $t = ($Target.Trim() -replace '\s+"[^"]*"$', '') -replace '^<', '' -replace '>$', ''
    if (-not $t) { return }
    if ($t -match '^(https?:|mailto:|tel:|//)') { return }
    $path, $frag = $t -split '#', 2
    if (-not $path) {
        if ($frag -and ($frag -notin (Get-CachedSlug $File.FullName))) {
            $Broken.Add("${Rel}:${LineNo}: '#$frag' - no heading with that anchor on this page")
        }
        return
    }
    if ($path.StartsWith('/')) { return } # absolute site path - not resolvable here
    $resolved = [System.IO.Path]::GetFullPath((Join-Path $File.DirectoryName $path))
    if (-not (Test-Path -LiteralPath $resolved)) {
        $Broken.Add("${Rel}:${LineNo}: '$Target' - target does not exist")
        return
    }
    if ($frag -and $resolved.EndsWith('.md') -and ($frag -notin (Get-CachedSlug $resolved))) {
        $Broken.Add("${Rel}:${LineNo}: '$Target' - no heading '#$frag' in the target file")
    }
}

# Inline links '[text](target)' and reference-style definitions '[label]: target'.
$linkPattern = '\[[^\]]*\]\(([^)]+)\)'
$refDefPattern = '^\s*\[[^\]]+\]:\s+(\S+)'
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
            Test-LinkTarget -Target $m.Groups[1].Value -File $file -Rel $rel -LineNo $lineNo -Broken $broken
        }
        # Reference-style link definitions ('[label]: target') carry a relative
        # target too; validate it the same way so those links do not slip past CI.
        if ($scrubbed -match $refDefPattern) {
            Test-LinkTarget -Target $matches[1] -File $file -Rel $rel -LineNo $lineNo -Broken $broken
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
