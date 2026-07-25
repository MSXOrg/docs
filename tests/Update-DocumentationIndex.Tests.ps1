#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

$lineEndings = @(
    @{ Name = 'LF'; NewLine = "`n" }
    @{ Name = 'CRLF'; NewLine = "`r`n" }
)

Describe 'Update-DocumentationIndex line endings' {
    BeforeAll {
        $script:sourceScript = Join-Path $PSScriptRoot '../.github/scripts/Update-DocumentationIndex.ps1'
        $script:pwsh = (Get-Process -Id $PID).Path
        $script:utf8 = [System.Text.UTF8Encoding]::new($false)
        function Set-FixtureText {
            param(
                [Parameter(Mandatory)]
                [string] $Path,

                [Parameter(Mandatory)]
                [string] $Content,

                [Parameter(Mandatory)]
                [string] $NewLine
            )

            $text = [regex]::Replace($Content, '\r\n|\r|\n', $NewLine)
            [System.IO.File]::WriteAllText($Path, $text, $script:utf8)
        }

        function New-IndexFixture {
            param(
                [Parameter(Mandatory)]
                [string] $NewLine,

                [Parameter()]
                [switch] $Stale
            )

            $root = Join-Path ([System.IO.Path]::GetTempPath()) "docs-index-$([guid]::NewGuid().ToString('N'))"
            $scripts = New-Item -ItemType Directory -Path (Join-Path $root '.github/scripts')
            $docs = New-Item -ItemType Directory -Path (Join-Path $root 'src/docs/Section')
            Copy-Item -LiteralPath $script:sourceScript -Destination $scripts.FullName

            $config = @'
nav = [
  "Section/index.md",
  "Section/Guide.md",
]
'@
            Set-FixtureText -Path (Join-Path $root 'src/zensical.toml') -Content $config -NewLine $NewLine

            $page = @'
---
title: Guide
description: The generated description.
---

# Guide
'@
            Set-FixtureText -Path (Join-Path $docs.FullName 'Guide.md') -Content $page -NewLine $NewLine

            $description = if ($Stale) { 'An outdated description.' } else { 'The generated description.' }
            $index = @"
---
title: Section
description: Fixture section.
---

# Section

<!-- INDEX:START -->

| Page | Description |
| --- | --- |
| [Guide](Guide.md) | $description |

<!-- INDEX:END -->
"@
            $indexPath = Join-Path $docs.FullName 'index.md'
            Set-FixtureText -Path $indexPath -Content $index -NewLine $NewLine

            return [pscustomobject]@{
                Root = $root
                IndexPath = $indexPath
                ScriptPath = Join-Path $scripts.FullName 'Update-DocumentationIndex.ps1'
            }
        }

        function Invoke-IndexFixture {
            param(
                [Parameter(Mandatory)]
                [string] $ScriptPath,

                [Parameter()]
                [switch] $Check
            )

            $arguments = @('-NoProfile', '-File', $ScriptPath)
            if ($Check) {
                $arguments += '-Check'
            }
            $output = & $script:pwsh @arguments 2>&1 | Out-String

            return [pscustomobject]@{
                ExitCode = $LASTEXITCODE
                Output = $output
            }
        }

        function Assert-OnlyLineEnding {
            param(
                [Parameter(Mandatory)]
                [string] $Path,

                [Parameter(Mandatory)]
                [string] $NewLine
            )

            $text = [System.IO.File]::ReadAllText($Path)
            $withoutExpected = $text.Replace($NewLine, '')
            $withoutExpected | Should -Not -Match '[\r\n]'
        }
    }

    AfterEach {
        if ($fixture -and (Test-Path -LiteralPath $fixture.Root)) {
            Remove-Item -LiteralPath $fixture.Root -Recurse -Force
        }
    }

    It 'accepts an unchanged <Name> index without rewriting it' -ForEach $lineEndings {
        $fixture = New-IndexFixture -NewLine $NewLine
        $before = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($fixture.IndexPath))

        $result = Invoke-IndexFixture -ScriptPath $fixture.ScriptPath -Check

        $result.ExitCode | Should -Be 0
        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($fixture.IndexPath)) | Should -BeExactly $before
    }

    It 'rejects real table-content drift in a <Name> index' -ForEach $lineEndings {
        $fixture = New-IndexFixture -NewLine $NewLine -Stale

        $result = Invoke-IndexFixture -ScriptPath $fixture.ScriptPath -Check

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'Documentation index tables are out of date'
    }

    It 'repairs drift while preserving only <Name> line endings' -ForEach $lineEndings {
        $fixture = New-IndexFixture -NewLine $NewLine -Stale

        $update = Invoke-IndexFixture -ScriptPath $fixture.ScriptPath
        $check = Invoke-IndexFixture -ScriptPath $fixture.ScriptPath -Check

        $update.ExitCode | Should -Be 0
        $check.ExitCode | Should -Be 0
        [System.IO.File]::ReadAllText($fixture.IndexPath) | Should -Match 'The generated description\.'
        Assert-OnlyLineEnding -Path $fixture.IndexPath -NewLine $NewLine
    }
}
