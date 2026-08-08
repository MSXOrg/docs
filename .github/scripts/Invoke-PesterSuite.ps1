#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Run every Pester suite in the repository and gate the pull request on the result.

.DESCRIPTION
    Resolves the pinned Pester version, discovers every '*.Tests.ps1' file beneath the
    suite directory, runs them all in one Pester session, and reports the result three
    ways: a grouped console log, per-test error annotations from Pester's GitHub Actions
    CI format, and a Markdown table on the job summary.

    The script exits 1 when a test fails, when a suite fails to run at all, or when
    discovery finds no test file — a run that silently discovers nothing is green and
    worthless, so it is treated as a failure. It exits 0 only when every discovered test
    passed, which is what makes it usable as a merge gate.

    Pester is pinned to an exact version and verified by module GUID. A CI pipeline is an
    end artifact, so it pins to an exact resolved version for reproducibility rather than
    to the range the suites themselves declare; see the Dependencies coding standard.

.EXAMPLE
    ./Invoke-PesterSuite.ps1
    Runs every suite under tests/ and exits non-zero if any test fails.

.EXAMPLE
    ./Invoke-PesterSuite.ps1 -Path ./tests -RequiredVersion 6.0.1
    Runs the suites in an explicit directory with an explicit Pester version.

.INPUTS
    None

    You can't pipe objects to Invoke-PesterSuite.ps1.

.OUTPUTS
    None

    The script reports through the console log, annotations, the job summary, and its
    exit code.

.LINK
    https://msxorg.github.io/docs/Coding-Standards/GitHub-Actions/
#>
[CmdletBinding()]
param(
    # Directory holding the Pester suites. Every '*.Tests.ps1' beneath it is run.
    [Parameter()]
    [string] $Path = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'tests'),

    # Exact Pester version to run with, so a new release cannot turn an untouched pull
    # request red. Keep it inside the range the suites' '#Requires' lines declare.
    [Parameter()]
    [string] $RequiredVersion = '6.0.1',

    # Pester's module GUID — the identity half of the pin, checked after import so a
    # name-squatted module cannot satisfy the version.
    [Parameter()]
    [guid] $ModuleGuid = 'a699dea5-2c73-4616-a270-1f7abb777e71'
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
        Write-WorkflowAnnotation -Type notice -Title 'Test' -Message '45 tests passed'
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
    # A value in a command property needs ':' and ',' encoded too — they delimit the list.
    $encodedTitle = $Title -replace '%', '%25' -replace "`r", '%0D' -replace "`n", '%0A' -replace ':', '%3A' -replace ',', '%2C'
    Write-Output "::${Type} title=${encodedTitle}::${encodedMessage}"
}

function Get-PesterSummaryMarkdown {
    <#
        .SYNOPSIS
        Render a Pester run as the Markdown written to the job summary.

        .DESCRIPTION
        Builds a verdict heading and one table row per suite, so a reader sees which
        suites ran and how many tests each contributed without expanding the raw log.
        Failed tests are listed underneath in a block that stays closed until opened.

        .EXAMPLE
        Get-PesterSummaryMarkdown -Result $result -SuiteRoot ./tests
        Returns the Markdown for the job summary.

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    param(
        # The object returned by Invoke-Pester with PassThru enabled.
        [Parameter(Mandatory)]
        [psobject] $Result,

        # Directory the suite paths are shown relative to.
        [Parameter(Mandatory)]
        [string] $SuiteRoot
    )
    $verdict = if ($Result.Result -eq 'Passed') { '✅' } else { '❌' }
    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("## $verdict Pester — $($Result.PassedCount) passed, $($Result.FailedCount) failed, $($Result.SkippedCount) skipped")
    $lines.Add('')
    $lines.Add("Pester $($Result.Version) ran $($Result.Containers.Count) suite(s) in $($Result.Duration.TotalSeconds.ToString('0.0'))s.")
    $lines.Add('')
    $lines.Add('| Suite | Total | Passed | Failed | Skipped | Duration |')
    $lines.Add('| --- | ---: | ---: | ---: | ---: | ---: |')
    foreach ($container in $Result.Containers) {
        $name = if ($container.Item -is [System.IO.FileInfo]) {
            [IO.Path]::GetRelativePath($SuiteRoot, $container.Item.FullName)
        } else {
            [string] $container.Name
        }
        $lines.Add("| ``$name`` | $($container.TotalCount) | $($container.PassedCount) | $($container.FailedCount) | $($container.SkippedCount) | $($container.Duration.TotalSeconds.ToString('0.0'))s |")
    }
    $lines.Add("| **Total** | **$($Result.TotalCount)** | **$($Result.PassedCount)** | **$($Result.FailedCount)** | **$($Result.SkippedCount)** | **$($Result.Duration.TotalSeconds.ToString('0.0'))s** |")

    if ($Result.FailedCount -gt 0) {
        $lines.Add('')
        $lines.Add("<details><summary>Failed tests ($($Result.FailedCount))</summary>")
        $lines.Add('')
        foreach ($test in $Result.Failed) {
            $lines.Add("- **$($test.ExpandedPath)**")
            $lines.Add('')
            $lines.Add('  ```text')
            foreach ($line in ("$($test.ErrorRecord)" -split '\r?\n')) {
                $lines.Add("  $line")
            }
            $lines.Add('  ```')
            $lines.Add('')
        }
        $lines.Add('</details>')
    }

    return ($lines -join [Environment]::NewLine)
}

Write-Output "::group::Resolve Pester $RequiredVersion"
$available = @(Get-Module -ListAvailable -Name Pester |
        Where-Object { $_.Version.ToString() -eq $RequiredVersion -and $_.Guid -eq $ModuleGuid })
if ($available.Count -eq 0) {
    Write-Output "Pester $RequiredVersion is not installed; installing it for the current user."
    Install-Module -Name Pester -RequiredVersion $RequiredVersion -Repository PSGallery -Scope CurrentUser -Force -SkipPublisherCheck
} else {
    Write-Output "Pester $RequiredVersion is already installed."
}
Import-Module -Name Pester -RequiredVersion $RequiredVersion -Force
$pester = Get-Module -Name Pester
if ($pester.Guid -ne $ModuleGuid) {
    Write-WorkflowAnnotation -Type error -Title 'Test' -Message "The imported Pester module has GUID $($pester.Guid), expected $ModuleGuid."
    exit 1
}
Write-Output "Imported Pester $($pester.Version) ($($pester.Guid)) from $($pester.ModuleBase)."
Write-Output '::endgroup::'

$suiteRoot = (Resolve-Path -LiteralPath $Path).ProviderPath
$suite = @(Get-ChildItem -LiteralPath $suiteRoot -Filter '*.Tests.ps1' -File -Recurse | Sort-Object -Property FullName)
if ($suite.Count -eq 0) {
    Write-WorkflowAnnotation -Type error -Title 'Test' -Message "No '*.Tests.ps1' file found under $suiteRoot — the run would have been green without testing anything."
    exit 1
}
Write-Output "Discovered $($suite.Count) suite(s) under ${suiteRoot}:"
$suite | ForEach-Object { Write-Output "  - $([IO.Path]::GetRelativePath($suiteRoot, $_.FullName))" }

$configuration = New-PesterConfiguration
$configuration.Run.Path = $suite.FullName
$configuration.Run.PassThru = $true
$configuration.Output.Verbosity = 'Detailed'
$configuration.Output.CIFormat = 'GithubActions'

Write-Output "::group::Run $($suite.Count) Pester suite(s)"
$result = Invoke-Pester -Configuration $configuration
Write-Output '::endgroup::'

if ($env:GITHUB_STEP_SUMMARY) {
    Get-PesterSummaryMarkdown -Result $result -SuiteRoot $suiteRoot |
        Out-File -LiteralPath $env:GITHUB_STEP_SUMMARY -Encoding utf8 -Append
}

$failedSuite = $result.FailedContainersCount
if ($result.TotalCount -eq 0) {
    Write-WorkflowAnnotation -Type error -Title 'Test' -Message "The $($suite.Count) discovered suite(s) contained no test — the run proved nothing."
    exit 1
}
if ($result.Result -eq 'Passed' -and $failedSuite -eq 0) {
    Write-WorkflowAnnotation -Type notice -Title 'Test' -Message "$($result.PassedCount) test(s) passed in $($suite.Count) suite(s) ($($result.Duration.TotalSeconds.ToString('0.0'))s)."
    exit 0
}
Write-WorkflowAnnotation -Type error -Title 'Test' -Message "$($result.FailedCount) of $($result.TotalCount) test(s) failed, and $failedSuite suite(s) failed to run."
exit 1
