#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

<#
    Executable proof for src/docs/Coding-Standards/PowerShell/Requires-Modules.md.

    It demonstrates how a `#Requires -Modules` version specification actually resolves — including
    that `MaximumVersion = 'N.*'` is a valid wildcard ceiling, that the ceiling excludes a higher
    major, and that `GUID` is an optional identity pin. Each case writes a tiny script carrying one
    `#Requires` line and runs it in a child PowerShell; the line is enforced by the engine, so the
    child prints `SATISFIED` only when the requirement resolves.

    Run:  Invoke-Pester -Path ./tests/Requires-Modules.Tests.ps1
    Uses the installed Pester as the sample module, so it is independent of the exact 6.x version.
#>

Describe '#Requires -Modules version specification' {
    BeforeAll {
        $pester = Get-Module -ListAvailable Pester | Sort-Object Version -Descending | Select-Object -First 1
        $script:major = $pester.Version.Major
        $script:exact = $pester.Version.ToString()
        $script:guid = $pester.Guid.Guid
        $script:pwsh = (Get-Process -Id $PID).Path

        function Test-RequiresSatisfied {
            param([Parameter(Mandatory)][string] $Spec)
            $file = Join-Path ([IO.Path]::GetTempPath()) ("requires_" + [guid]::NewGuid().ToString('N') + '.ps1')
            "#Requires -Modules $Spec`r`nWrite-Output 'SATISFIED'" | Set-Content -LiteralPath $file -Encoding utf8
            try {
                $output = & $script:pwsh -NoProfile -File $file 2>&1 | Out-String
            } finally {
                Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
            }
            [bool]($output -match 'SATISFIED')
        }
    }

    Context 'Version range — floor plus wildcard ceiling' {
        It 'Major lock (ModuleVersion N.0.0 + MaximumVersion N.*) resolves to the installed N.x' {
            Test-RequiresSatisfied "@{ ModuleName = 'Pester'; ModuleVersion = '$major.0.0'; MaximumVersion = '$major.*' }" | Should -BeTrue
        }
        It 'The wildcard ceiling is enforced — a ceiling below the floor is unsatisfiable' {
            Test-RequiresSatisfied "@{ ModuleName = 'Pester'; ModuleVersion = '$major.0.0'; MaximumVersion = '$($major - 1).*' }" | Should -BeFalse
        }
        It 'A minimum only (ModuleVersion, no ceiling) resolves — and would allow a higher major' {
            Test-RequiresSatisfied "@{ ModuleName = 'Pester'; ModuleVersion = '$major.0.0' }" | Should -BeTrue
        }
    }

    Context 'Exact version' {
        It 'An installed exact RequiredVersion resolves' {
            Test-RequiresSatisfied "@{ ModuleName = 'Pester'; RequiredVersion = '$exact' }" | Should -BeTrue
        }
        It 'A missing exact RequiredVersion does not resolve (exact pins are fragile)' {
            Test-RequiresSatisfied "@{ ModuleName = 'Pester'; RequiredVersion = '0.0.1' }" | Should -BeFalse
        }
    }

    Context 'GUID — module identity, orthogonal to version' {
        It 'The correct GUID with a matching range resolves' {
            Test-RequiresSatisfied "@{ ModuleName = 'Pester'; ModuleVersion = '$major.0.0'; MaximumVersion = '$major.*'; GUID = '$guid' }" | Should -BeTrue
        }
        It 'A wrong GUID blocks an otherwise-matching module' {
            Test-RequiresSatisfied "@{ ModuleName = 'Pester'; ModuleVersion = '$major.0.0'; MaximumVersion = '$major.*'; GUID = '00000000-0000-0000-0000-000000000000' }" | Should -BeFalse
        }
        It 'Omitting the GUID still resolves — the GUID is optional' {
            Test-RequiresSatisfied "@{ ModuleName = 'Pester'; ModuleVersion = '$major.0.0'; MaximumVersion = '$major.*' }" | Should -BeTrue
        }
    }
}
