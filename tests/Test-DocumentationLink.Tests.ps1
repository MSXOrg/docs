#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

Describe 'Test-DocumentationLink footnotes and reference definitions' {
    BeforeAll {
        $script:sourceScript = Join-Path $PSScriptRoot '../.github/scripts/Test-DocumentationLink.ps1'
        $script:pwsh = (Get-Process -Id $PID).Path
        $script:utf8 = [System.Text.UTF8Encoding]::new($false)

        function New-LinkFixture {
            <#
                .SYNOPSIS
                Create a throwaway documentation repository containing one page.

                .DESCRIPTION
                Lay out the directories Test-DocumentationLink.ps1 expects - a copy of
                the script under '.github/scripts' and content under 'src/docs' - so the
                script can be invoked against fixture content instead of the live docs.
                'src/docs/Real.md' always exists as a valid link target; 'Missing.md'
                never does.

                .EXAMPLE
                New-LinkFixture -Content '# Page'
                Returns the fixture root and the path of the script copy to invoke.

                .OUTPUTS
                [pscustomobject]
            #>
            [CmdletBinding(SupportsShouldProcess)]
            param(
                # The Markdown body written to 'src/docs/Page.md'.
                [Parameter(Mandatory)]
                [string] $Content
            )

            $root = Join-Path ([System.IO.Path]::GetTempPath()) "docs-link-$([guid]::NewGuid().ToString('N'))"
            if (-not $PSCmdlet.ShouldProcess($root, 'Create documentation link fixture')) {
                return
            }
            $scripts = New-Item -ItemType Directory -Path (Join-Path $root '.github/scripts')
            $docs = New-Item -ItemType Directory -Path (Join-Path $root 'src/docs')
            Copy-Item -LiteralPath $script:sourceScript -Destination $scripts.FullName

            [System.IO.File]::WriteAllText((Join-Path $docs.FullName 'Real.md'), "# Real`n", $script:utf8)
            [System.IO.File]::WriteAllText((Join-Path $docs.FullName 'Page.md'), $Content, $script:utf8)

            return [pscustomobject]@{
                Root = $root
                ScriptPath = Join-Path $scripts.FullName 'Test-DocumentationLink.ps1'
            }
        }

        function Invoke-LinkFixture {
            <#
                .SYNOPSIS
                Run the fixture's copy of the link checker and capture its result.

                .DESCRIPTION
                Invoke the script in a separate PowerShell process so the assertion is
                made on the real exit code and console output CI sees, not on internal
                state.

                .EXAMPLE
                Invoke-LinkFixture -ScriptPath $fixture.ScriptPath
                Returns the script's exit code and combined output.

                .OUTPUTS
                [pscustomobject]
            #>
            param(
                # Path to the fixture's copy of Test-DocumentationLink.ps1.
                [Parameter(Mandatory)]
                [string] $ScriptPath
            )

            $output = & $script:pwsh -NoProfile -File $ScriptPath 2>&1 | Out-String

            return [pscustomobject]@{
                ExitCode = $LASTEXITCODE
                Output = $output
            }
        }
    }

    AfterEach {
        if ($fixture -and (Test-Path -LiteralPath $fixture.Root)) {
            Remove-Item -LiteralPath $fixture.Root -Recurse -Force
        }
    }

    It 'accepts a page whose footnote definitions are prose' {
        $fixture = New-LinkFixture -Content @'
# Footnotes

A claim that needs support.[^1] Another claim.[^2]

## Notes

[^1]: Statiske bruksordningsregler er mest aktuelt der det ikke er behov for bankkonto.
[^2]: Hauge, K.B. 2017. Rammer for jordskifteretten si regulering av lag og bruksordningar.
'@

        $result = Invoke-LinkFixture -ScriptPath $fixture.ScriptPath

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'All documentation links resolve\.'
    }

    It 'accepts a reference-style definition that points at a real file' {
        $fixture = New-LinkFixture -Content @'
# Reference

See [the real page][real].

[real]: ./Real.md
'@

        $result = Invoke-LinkFixture -ScriptPath $fixture.ScriptPath

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'All documentation links resolve\.'
    }

    It 'reports a reference-style definition that points at a missing file' {
        $fixture = New-LinkFixture -Content @'
# Reference

See [the missing page][missing].

[missing]: ./Missing.md
'@

        $result = Invoke-LinkFixture -ScriptPath $fixture.ScriptPath

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'Broken documentation links \(1\)'
        $result.Output | Should -Match "'\./Missing\.md' - target does not exist"
    }

    It 'reports a broken inline link inside footnote prose' {
        $fixture = New-LinkFixture -Content @'
# Footnote link

A claim that needs support.[^1]

[^1]: See [the missing page](./Missing.md) for the detail.
'@

        $result = Invoke-LinkFixture -ScriptPath $fixture.ScriptPath

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'Broken documentation links \(1\)'
        $result.Output | Should -Match "'\./Missing\.md' - target does not exist"
    }

    It 'accepts a valid inline link inside footnote prose' {
        $fixture = New-LinkFixture -Content @'
# Footnote link

A claim that needs support.[^1]

[^1]: See [the real page](./Real.md) for the detail.
'@

        $result = Invoke-LinkFixture -ScriptPath $fixture.ScriptPath

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'All documentation links resolve\.'
    }

    It 'accepts a footnote reference in running text' {
        $fixture = New-LinkFixture -Content @'
# Inline reference

A claim that needs support.[^1] (A parenthetical that is not a link.)

[^1]: Prose that names Missing.md without linking to it.
'@

        $result = Invoke-LinkFixture -ScriptPath $fixture.ScriptPath

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'All documentation links resolve\.'
    }
}
