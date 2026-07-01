#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Update each section index.md with a table generated from page front matter.

.DESCRIPTION
    Every documentation page declares 'title' and 'description' in YAML front
    matter. Each index.md that contains the INDEX markers gets an auto-generated
    table of the documents at its level - subsections for the root, pages for a
    section - ordered to match the navigation in zensical.toml.

    Run with no arguments to update the index files in place. Run with -Check to
    verify they are up to date, changing nothing and exiting non-zero on drift.

    Glue across the ecosystem is PowerShell. PowerShell has no built-in TOML
    parser, so the navigation order is derived by reading the ordered "*.md"
    path strings from the nav array in zensical.toml - the only place .md paths
    appear in that file.

.EXAMPLE
    ./Update-DocumentationIndex.ps1
    Updates every section index.md in place from the current front matter.

.EXAMPLE
    ./Update-DocumentationIndex.ps1 -Check
    Verifies the indexes are current without writing; exits non-zero on drift.
    This is the mode the CI build job runs.
#>
[CmdletBinding()]
param(
    # Verify the indexes are up to date without writing; exit non-zero on drift.
    [Parameter()]
    [switch] $Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Docs = Join-Path $Root 'src/docs'
$Config = Join-Path $Root 'src/zensical.toml'
$Start = '<!-- INDEX:START -->'
$End = '<!-- INDEX:END -->'
$Utf8 = [System.Text.UTF8Encoding]::new($false)

function Read-FrontMatter {
    param([string]$Path)
    $meta = @{}
    $text = [System.IO.File]::ReadAllText($Path)
    if (-not $text.StartsWith('---')) { return $meta }
    $closing = $text.IndexOf("`n---", 3)
    if ($closing -lt 0) { return $meta }
    foreach ($line in $text.Substring(3, $closing - 3) -split "`n") {
        $stripped = $line.Trim()
        if (-not $stripped -or $stripped.StartsWith('#') -or ($line -notmatch ':')) { continue }
        $idx = $line.IndexOf(':')
        $key = $line.Substring(0, $idx).Trim()
        $value = $line.Substring($idx + 1).Trim().Trim('"').Trim("'")
        if ($key -and $value) { $meta[$key] = $value }
    }
    return $meta
}

function Get-NavOrder {
    $text = [System.IO.File]::ReadAllText($Config)
    # Target the 'nav = [' key precisely (multiline, at the start of a line) so we
    # never match other keys or values that merely contain 'nav', such as the
    # 'navigation.*' theme features later in the file.
    $match = [regex]::Match($text, '(?m)^\s*nav\s*=\s*\[')
    if (-not $match.Success) {
        throw "Could not find a 'nav = [' array in $Config."
    }
    $open = $match.Index + $match.Length - 1
    $depth = 0
    $end = -1
    for ($p = $open; $p -lt $text.Length; $p++) {
        if ($text[$p] -eq '[') { $depth++ }
        elseif ($text[$p] -eq ']') { $depth--; if ($depth -eq 0) { $end = $p; break } }
    }
    if ($end -lt 0) {
        throw "The 'nav' array in $Config is missing a closing ']'."
    }
    $navText = $text.Substring($open, $end - $open + 1)
    $order = @{}
    $i = 0
    foreach ($m in [regex]::Matches($navText, '"([^"]+\.md)"')) {
        $path = $m.Groups[1].Value
        if (-not $order.ContainsKey($path)) { $order[$path] = $i; $i++ }
    }
    return $order
}

function Get-RelKey {
    param([string]$FullPath)
    return ($FullPath.Substring($Docs.Length).TrimStart('\', '/')) -replace '\\', '/'
}

function Get-IndexTable {
    param([string]$IndexPath, [hashtable]$Order)
    $dir = Split-Path -Parent $IndexPath
    $subdirs = @(Get-ChildItem -LiteralPath $dir -Directory |
            Where-Object { Test-Path (Join-Path $_.FullName 'index.md') } | Sort-Object Name)
    $files = @(Get-ChildItem -LiteralPath $dir -File -Filter *.md |
            Where-Object { $_.Name -ne 'index.md' } | Sort-Object Name)

    $rows = [System.Collections.Generic.List[object]]::new()
    foreach ($child in $subdirs) {
        $target = Join-Path $child.FullName 'index.md'
        $meta = Read-FrontMatter $target
        $key = Get-RelKey $target
        $rows.Add([pscustomobject]@{
                Order = if ($Order.ContainsKey($key)) { $Order[$key] } else { 10000 }
                Title = if ($meta.ContainsKey('title')) { $meta['title'] } else { $child.Name }
                Link  = "$($child.Name)/index.md"
                Desc  = if ($meta.ContainsKey('description')) { $meta['description'] } else { '' }
            })
    }
    foreach ($child in $files) {
        $meta = Read-FrontMatter $child.FullName
        $key = Get-RelKey $child.FullName
        $rows.Add([pscustomobject]@{
                Order = if ($Order.ContainsKey($key)) { $Order[$key] } else { 10000 }
                Title = if ($meta.ContainsKey('title')) { $meta['title'] } else { [System.IO.Path]::GetFileNameWithoutExtension($child.Name) }
                Link  = $child.Name
                Desc  = if ($meta.ContainsKey('description')) { $meta['description'] } else { '' }
            })
    }

    $sorted = $rows | Sort-Object Order, { $_.Title.ToLower() }
    $header = if ($subdirs.Count -and -not $files.Count) { 'Section' } else { 'Page' }
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("| $header | Description |")
    $lines.Add('| --- | --- |')
    foreach ($r in $sorted) { $lines.Add("| [$($r.Title)]($($r.Link)) | $($r.Desc) |") }
    return ($lines -join "`n")
}

function Get-Rendered {
    param([string]$IndexPath, [hashtable]$Order)
    $text = [System.IO.File]::ReadAllText($IndexPath)
    if (($text -notlike "*$Start*") -or ($text -notlike "*$End*")) { return $null }
    $head = $text.Substring(0, $text.IndexOf($Start) + $Start.Length)
    $tail = $text.Substring($text.IndexOf($End))
    return "$head`n`n$(Get-IndexTable $IndexPath $Order)`n`n$tail"
}

$order = Get-NavOrder
$stale = [System.Collections.Generic.List[string]]::new()
foreach ($index in (Get-ChildItem -LiteralPath $Docs -Recurse -File -Filter index.md | Sort-Object FullName)) {
    $rendered = Get-Rendered $index.FullName $order
    if ($null -eq $rendered) { continue }
    if ($rendered -eq [System.IO.File]::ReadAllText($index.FullName)) { continue }
    $stale.Add((($index.FullName.Substring($Root.Length).TrimStart('\', '/')) -replace '\\', '/'))
    if (-not $Check) { [System.IO.File]::WriteAllText($index.FullName, $rendered, $Utf8) }
}

if ($stale.Count -eq 0) { exit 0 }
if ($Check) {
    Write-Output 'Documentation index tables are out of date:'
    $stale | ForEach-Object { Write-Output "  - $_" }
    Write-Output 'Run: pwsh .github/scripts/Update-DocumentationIndex.ps1'
    exit 1
}
Write-Output 'Updated index tables:'
$stale | ForEach-Object { Write-Output "  - $_" }
exit 0
