#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

Describe 'Initialize-MsxWorkspace documentation bootstrap' {
    BeforeAll {
        $script:bootstrap = (Resolve-Path (Join-Path $PSScriptRoot '../bootstrap/Initialize-MsxWorkspace.ps1')).Path
        $script:pwsh = (Get-Process -Id $PID).Path

        function Invoke-Bootstrap {
            param([Parameter(Mandatory)] [string] $ProjectText)

            $runner = Join-Path $fixtureRoot 'run.ps1'
            @"
`$projects = $ProjectText
& '$bootstrap' -Root '$workspace' -Project `$projects -UserName 'Fixture' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content $runner
            & $script:pwsh -NoProfile -File $runner 2>&1
        }
    }

    BeforeEach {
        $fixtureRoot = Join-Path ([IO.Path]::GetTempPath()) "msx-bootstrap-$([guid]::NewGuid().ToString('N'))"
        $remote = Join-Path $fixtureRoot 'docs.git'
        $writer = Join-Path $fixtureRoot 'writer'
        $workspace = Join-Path $fixtureRoot 'workspace'
        New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null
        & git init --bare --quiet --initial-branch=main $remote
        & git clone --quiet $remote $writer
        & git -C $writer config user.name 'Fixture Writer'
        & git -C $writer config user.email 'fixture@example.invalid'
        New-Item -ItemType Directory -Path (Join-Path $writer 'bootstrap') | Out-Null
        Copy-Item $script:bootstrap (Join-Path $writer 'bootstrap/Initialize-MsxWorkspace.ps1')
        Set-Content (Join-Path $writer 'context.txt') 'docs context'
        & git -C $writer add .
        & git -C $writer commit --quiet -m 'Initialize docs'
        & git -C $writer push --quiet --set-upstream origin main
        $script:remote = $remote
        $script:workspace = $workspace
    }

    AfterEach {
        if (Test-Path $fixtureRoot) {
            Remove-Item $fixtureRoot -Recurse -Force
        }
    }

    It 'creates a bare backing repository and documentation worktree' {
        Invoke-Bootstrap -ProjectText "@(@{ Name = 'Fixture'; Path = ''; DocsUrl = '$remote' })" | Out-Null

        $LASTEXITCODE | Should -Be 0
        Test-Path (Join-Path $workspace 'docs.git') | Should -BeTrue
        Test-Path (Join-Path $workspace 'docs/.git') | Should -BeTrue
        Test-Path (Join-Path $workspace 'docs/context.txt') | Should -BeTrue
        Test-Path (Join-Path $workspace 'memory') | Should -BeFalse
    }

    It 'rejects a project definition that omits documentation coordinates' {
        Invoke-Bootstrap -ProjectText "@(@{ Name = 'Fixture'; Path = '' })" | Out-Null
        $LASTEXITCODE | Should -Not -Be 0
    }
}
