#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

Describe 'Initialize-MsxWorkspace context freshness' {
    BeforeAll {
        $script:bootstrap = Join-Path $PSScriptRoot '../bootstrap/Initialize-MsxWorkspace.ps1'
        $script:pwsh = (Get-Process -Id $PID).Path

        function Invoke-Git {
            param(
                [Parameter()]
                [string] $WorkingDirectory,

                [Parameter(Mandatory)]
                [string[]] $Arguments
            )

            $output = if ($WorkingDirectory) {
                & git -C $WorkingDirectory @Arguments 2>&1
            } else {
                & git @Arguments 2>&1
            }
            if ($LASTEXITCODE -ne 0) {
                throw "git $($Arguments -join ' ') failed in '$WorkingDirectory': $($output | Out-String)"
            }
            return $output
        }

        function Add-TestCommit {
            param(
                [Parameter(Mandatory)]
                [string] $Repository,

                [Parameter(Mandatory)]
                [string] $Name
            )

            Add-Content -LiteralPath (Join-Path $Repository 'context.txt') -Value $Name
            Invoke-Git -WorkingDirectory $Repository -Arguments @('add', 'context.txt') | Out-Null
            Invoke-Git -WorkingDirectory $Repository -Arguments @('commit', '--quiet', '-m', $Name) | Out-Null
        }

        function New-ContextFixture {
            $root = Join-Path ([IO.Path]::GetTempPath()) "msx-bootstrap-$([guid]::NewGuid().ToString('N'))"
            $workspace = Join-Path $root 'workspace'
            $remotes = Join-Path $root 'remotes'
            $writers = Join-Path $root 'writers'
            New-Item -ItemType Directory -Path $workspace, $remotes, $writers -Force | Out-Null

            $writerMap = @{}
            foreach ($name in @('docs', 'memory')) {
                $remote = Join-Path $remotes "$name.git"
                $writer = Join-Path $writers $name
                $checkout = Join-Path $workspace $name

                Invoke-Git -Arguments @('init', '--bare', '--quiet', '--initial-branch=main', $remote) | Out-Null
                Invoke-Git -Arguments @('clone', '--quiet', $remote, $writer) | Out-Null
                Invoke-Git -WorkingDirectory $writer -Arguments @('config', 'user.name', 'Fixture Writer') | Out-Null
                Invoke-Git -WorkingDirectory $writer -Arguments @('config', 'user.email', 'fixture@example.invalid') | Out-Null
                Set-Content -LiteralPath (Join-Path $writer 'context.txt') -Value "$name context"
                Invoke-Git -WorkingDirectory $writer -Arguments @('add', 'context.txt') | Out-Null
                Invoke-Git -WorkingDirectory $writer -Arguments @('commit', '--quiet', '-m', "Initialize $name") | Out-Null
                Invoke-Git -WorkingDirectory $writer -Arguments @('push', '--quiet', '--set-upstream', 'origin', 'main') | Out-Null
                Invoke-Git -Arguments @('clone', '--quiet', $remote, $checkout) | Out-Null
                Invoke-Git -WorkingDirectory $checkout -Arguments @('config', 'user.name', 'Fixture Local') | Out-Null
                Invoke-Git -WorkingDirectory $checkout -Arguments @('config', 'user.email', 'fixture-local@example.invalid') | Out-Null
                $writerMap[$name] = $writer
            }

            return [pscustomobject]@{
                Root = $root
                Workspace = $workspace
                Writers = $writerMap
                Docs = Join-Path $workspace 'docs'
            }
        }

        function Invoke-BootstrapFixture {
            param([Parameter(Mandatory)] $Fixture)

            $output = & $script:pwsh -NoProfile -File $script:bootstrap `
                -Root $Fixture.Workspace `
                -UserName 'Fixture User' `
                -UserEmail 'fixture@example.invalid' 2>&1 | Out-String

            return [pscustomobject]@{
                ExitCode = $LASTEXITCODE
                Output = $output
            }
        }
    }

    BeforeEach {
        $fixture = New-ContextFixture
    }

    AfterEach {
        if ($fixture -and (Test-Path -LiteralPath $fixture.Root)) {
            Remove-Item -LiteralPath $fixture.Root -Recurse -Force
        }
    }

    It 'fast-forwards a clean behind checkout to the exact remote head' {
        Add-TestCommit -Repository $fixture.Writers.docs -Name 'Advance docs'
        Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('push', '--quiet') | Out-Null
        $remoteHead = (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Be 0
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $remoteHead
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'origin/main')).Trim() | Should -BeExactly $remoteHead
    }

    It 'rejects a dirty checkout without updating it' {
        Set-Content -LiteralPath (Join-Path $fixture.Docs 'dirty.txt') -Value 'uncommitted'
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'uncommitted changes'
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $before
    }

    It 'rejects a locally ahead checkout without stale fallback' {
        Add-TestCommit -Repository $fixture.Docs -Name 'Local only'
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'not exactly synchronized'
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $before
    }

    It 'rejects diverged history without updating the checkout' {
        Add-TestCommit -Repository $fixture.Docs -Name 'Local divergence'
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()
        Add-TestCommit -Repository $fixture.Writers.docs -Name 'Remote divergence'
        Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('push', '--quiet') | Out-Null

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'Could not fast-forward'
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $before
    }

    It 'rejects a checkout on a non-default branch' {
        Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('switch', '--quiet', '-c', 'topic') | Out-Null

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match "not the default branch 'main'"
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('branch', '--show-current')).Trim() | Should -BeExactly 'topic'
    }

    It 'rejects an unreachable remote without using local context' {
        $missing = Join-Path $fixture.Root 'missing.git'
        Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('remote', 'set-url', 'origin', $missing) | Out-Null
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'git fetch failed'
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $before
    }
}
