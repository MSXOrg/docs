#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

Describe 'Initialize-MsxWorkspace context freshness' {
    BeforeAll {
        $script:bootstrap = Join-Path $PSScriptRoot '../bootstrap/Initialize-MsxWorkspace.ps1'
        $script:agentTemplate = Join-Path $PSScriptRoot '../bootstrap/AGENTS.template.md'
        $script:bootstrapReadme = Join-Path $PSScriptRoot '../bootstrap/README.md'
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
            [CmdletBinding(SupportsShouldProcess)]
            param()

            $root = Join-Path ([IO.Path]::GetTempPath()) "msx-bootstrap-$([guid]::NewGuid().ToString('N'))"
            if (-not $PSCmdlet.ShouldProcess($root, 'Create context fixture')) {
                return
            }
            $workspace = Join-Path $root 'workspace'
            $remotes = Join-Path $root 'remotes'
            $writers = Join-Path $root 'writers'
            New-Item -ItemType Directory -Path $workspace, $remotes, $writers -Force | Out-Null

            $writerMap = @{}
            $remoteMap = @{}
            foreach ($name in @('docs', 'memory')) {
                $remote = Join-Path $remotes "$name.git"
                $writer = Join-Path $writers $name
                $checkout = Join-Path $workspace $name

                Invoke-Git -Arguments @('init', '--bare', '--quiet', '--initial-branch=main', $remote) | Out-Null
                Invoke-Git -Arguments @('clone', '--quiet', $remote, $writer) | Out-Null
                Invoke-Git -WorkingDirectory $writer -Arguments @('config', 'user.name', 'Fixture Writer') | Out-Null
                Invoke-Git -WorkingDirectory $writer -Arguments @('config', 'user.email', 'fixture@example.invalid') | Out-Null
                Set-Content -LiteralPath (Join-Path $writer 'context.txt') -Value "$name context"
                if ($name -eq 'docs') {
                    $bootstrapDirectory = Join-Path $writer 'bootstrap'
                    New-Item -ItemType Directory -Path $bootstrapDirectory | Out-Null
                    Copy-Item -LiteralPath $script:bootstrap -Destination $bootstrapDirectory
                }
                Invoke-Git -WorkingDirectory $writer -Arguments @('add', 'context.txt') | Out-Null
                if ($name -eq 'docs') {
                    Invoke-Git -WorkingDirectory $writer -Arguments @('add', 'bootstrap/Initialize-MsxWorkspace.ps1') | Out-Null
                }
                Invoke-Git -WorkingDirectory $writer -Arguments @('commit', '--quiet', '-m', "Initialize $name") | Out-Null
                Invoke-Git -WorkingDirectory $writer -Arguments @('push', '--quiet', '--set-upstream', 'origin', 'main') | Out-Null
                Invoke-Git -Arguments @('clone', '--quiet', $remote, $checkout) | Out-Null
                Invoke-Git -WorkingDirectory $checkout -Arguments @('config', 'user.name', 'Fixture Local') | Out-Null
                Invoke-Git -WorkingDirectory $checkout -Arguments @('config', 'user.email', 'fixture-local@example.invalid') | Out-Null
                $writerMap[$name] = $writer
                $remoteMap[$name] = $remote
            }

            return [pscustomobject]@{
                Root = $root
                Workspace = $workspace
                Writers = $writerMap
                Remotes = $remoteMap
                Docs = Join-Path $workspace 'docs'
                Memory = Join-Path $workspace 'memory'
            }
        }

        function Invoke-BootstrapFixture {
            param([Parameter(Mandatory)] $Fixture)

            $runner = Join-Path $Fixture.Root 'invoke-bootstrap.ps1'
            $bootstrap = $script:bootstrap.Replace("'", "''")
            $workspace = $Fixture.Workspace.Replace("'", "''")
            $docsRemote = $Fixture.Remotes.docs.Replace("'", "''")
            $memoryRemote = $Fixture.Remotes.memory.Replace("'", "''")
            @"
`$repositories = @(
    @{ Name = 'Fixture/docs'; Path = 'docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Fixture/memory'; Path = 'memory'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$workspace' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner
            $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

            return [pscustomobject]@{
                ExitCode = $LASTEXITCODE
                Output = $output
            }
        }

        function Invoke-BootstrapSeed {
            param(
                [Parameter(Mandatory)]
                $Fixture,

                [Parameter(Mandatory)]
                [string] $MarkdownPath,

                [Parameter(Mandatory)]
                [string] $Workspace
            )

            $markdown = Get-Content -LiteralPath $MarkdownPath -Raw
            $match = [regex]::Match($markdown, '(?s)```powershell\r?\n(.*?)\r?\n```')
            if (-not $match.Success) {
                throw "No PowerShell seed block found in '$MarkdownPath'."
            }
            $runner = Join-Path $Fixture.Root "seed-$([IO.Path]::GetFileNameWithoutExtension($MarkdownPath)).ps1"
            Set-Content -LiteralPath $runner -Value $match.Groups[1].Value
            $previousRoot = $env:MSX_CONTEXT_ROOT
            $previousMsxDocs = $env:MSXORG_DOCS_URL
            $previousMsxMemory = $env:MSXORG_MEMORY_URL
            $previousPsmoduleDocs = $env:PSMODULE_DOCS_URL
            $previousPsmoduleMemory = $env:PSMODULE_MEMORY_URL
            try {
                $env:MSX_CONTEXT_ROOT = $Workspace
                $env:MSXORG_DOCS_URL = $Fixture.Remotes.docs
                $env:MSXORG_MEMORY_URL = $Fixture.Remotes.memory
                $env:PSMODULE_DOCS_URL = $Fixture.Remotes.docs
                $env:PSMODULE_MEMORY_URL = $Fixture.Remotes.memory
                $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String
                return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
            } finally {
                $env:MSX_CONTEXT_ROOT = $previousRoot
                $env:MSXORG_DOCS_URL = $previousMsxDocs
                $env:MSXORG_MEMORY_URL = $previousMsxMemory
                $env:PSMODULE_DOCS_URL = $previousPsmoduleDocs
                $env:PSMODULE_MEMORY_URL = $previousPsmoduleMemory
            }
        }
    }

    BeforeEach {
        $fixture = New-ContextFixture
        $fixture | Should -Not -BeNullOrEmpty
    }

    AfterEach {
        if ($fixture -and (Test-Path -LiteralPath $fixture.Root)) {
            Remove-Item -LiteralPath $fixture.Root -Recurse -Force
        }
    }

    It 'fast-forwards a clean behind checkout to the exact remote head' {
        Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('branch', 'local-topic') | Out-Null
        Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('tag', 'local-tag') | Out-Null
        $topicHead = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'local-topic')).Trim()
        $tagHead = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'local-tag')).Trim()
        Add-TestCommit -Repository $fixture.Writers.docs -Name 'Advance docs'
        Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('push', '--quiet') | Out-Null
        Add-TestCommit -Repository $fixture.Writers.memory -Name 'Advance memory'
        Invoke-Git -WorkingDirectory $fixture.Writers.memory -Arguments @('push', '--quiet') | Out-Null
        $docsHead = (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()
        $memoryHead = (Invoke-Git -WorkingDirectory $fixture.Writers.memory -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Be 0 -Because $result.Output
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $docsHead
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'origin/main')).Trim() | Should -BeExactly $docsHead
        (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $memoryHead
        (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'origin/main')).Trim() | Should -BeExactly $memoryHead
        Test-Path -LiteralPath (Join-Path $fixture.Docs '.git') -PathType Leaf | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.git') -PathType Container | Should -BeTrue
        (Invoke-Git -Arguments @("--git-dir=$(Join-Path $fixture.Workspace 'docs.git')", 'rev-parse', '--is-bare-repository')).Trim() |
            Should -BeExactly 'true'
        (Invoke-Git -Arguments @("--git-dir=$(Join-Path $fixture.Workspace 'docs.git')", 'rev-parse', 'local-topic')).Trim() |
            Should -BeExactly $topicHead
        (Invoke-Git -Arguments @("--git-dir=$(Join-Path $fixture.Workspace 'docs.git')", 'rev-parse', 'local-tag')).Trim() |
            Should -BeExactly $tagHead
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.simple-clone-backup') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $fixture.Memory '.git') -PathType Container | Should -BeTrue
        (Invoke-BootstrapFixture -Fixture $fixture).ExitCode | Should -Be 0
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
        $fixture.Remotes.docs = $missing
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'git fetch failed'
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $before
    }

    It 'rejects a non-canonical origin before fetching context' {
        Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @(
            'remote',
            'set-url',
            'origin',
            $fixture.Remotes.memory
        ) | Out-Null
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'not canonical'
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $before
    }

    It 'rejects a non-canonical bare docs origin before mutation' {
        (Invoke-BootstrapFixture -Fixture $fixture).ExitCode | Should -Be 0
        $backing = Join-Path $fixture.Workspace 'docs.git'
        Invoke-Git -Arguments @(
            "--git-dir=$backing",
            'remote',
            'set-url',
            'origin',
            $fixture.Remotes.memory
        ) | Out-Null
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'not canonical'
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $before
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('status', '--porcelain')) |
            Should -BeNullOrEmpty
    }

    It 'rejects a non-canonical memory origin before docs migration' {
        Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @(
            'remote',
            'set-url',
            'origin',
            $fixture.Remotes.docs
        ) | Out-Null
        $docsBefore = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()
        $memoryBefore = (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'not canonical'
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.git') | Should -BeFalse
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $docsBefore
        (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $memoryBefore
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('status', '--porcelain')) |
            Should -BeNullOrEmpty
        (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('status', '--porcelain')) |
            Should -BeNullOrEmpty
    }

    It 'rejects a memory worktree before docs migration' {
        Remove-Item -LiteralPath $fixture.Memory -Recurse -Force
        $memoryBacking = Join-Path $fixture.Root 'memory-backing.git'
        Invoke-Git -Arguments @('clone', '--bare', '--quiet', $fixture.Remotes.memory, $memoryBacking) | Out-Null
        Invoke-Git -Arguments @(
            "--git-dir=$memoryBacking",
            'worktree',
            'add',
            '--quiet',
            $fixture.Memory,
            'main'
        ) | Out-Null
        $docsBefore = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()
        $memoryBefore = (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'memory requires a simple checkout'
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.git') | Should -BeFalse
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $docsBefore
        (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $memoryBefore
    }

    It 'installs additional context through explicit repository coordinates' {
        $runner = Join-Path $fixture.Root 'invoke-repository-bootstrap.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$repositories = @(
    @{ Name = 'MSXOrg/docs'; Path = 'docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'MSXOrg/memory'; Path = 'memory'; Url = '$memoryRemote'; Kind = 'memory' }
    @{ Name = 'Project/process'; Path = './projects/Project/process/'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Project/memory'; Path = './projects/Project/memory/'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$workspace' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Be 0 -Because $output
        $additionalDocs = Join-Path $fixture.Workspace 'projects/Project/process'
        $additionalMemory = Join-Path $fixture.Workspace 'projects/Project/memory'
        Test-Path -LiteralPath (Join-Path $additionalDocs '.git') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $additionalMemory '.git') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'projects/Project/process.git') | Should -BeTrue
        (Invoke-Git -Arguments @(
            "--git-dir=$(Join-Path $fixture.Workspace 'projects/Project/process.git')",
            'rev-parse',
            '--is-bare-repository'
        )).Trim() | Should -BeExactly 'true'
        (Invoke-Git -WorkingDirectory $additionalDocs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()
        (Invoke-Git -WorkingDirectory $additionalMemory -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.memory -Arguments @('rev-parse', 'HEAD')).Trim()
    }

    It 'treats configured repository paths literally during preflight' {
        $literalRoot = Join-Path $fixture.Root 'literal-path-workspace[1]'
        [void] [IO.Directory]::CreateDirectory((Join-Path $fixture.Root 'literal-path-workspace1'))
        New-Item -ItemType Directory -Path (Join-Path $literalRoot 'context1/docs/.git') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $literalRoot 'context1/memory/.git') -Force | Out-Null
        $runner = Join-Path $fixture.Root 'invoke-literal-path-bootstrap.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$repositories = @(
    @{ Name = 'Literal/docs'; Path = 'context[1]/docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Literal/memory'; Path = 'context[1]/memory'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$literalRoot' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Be 0 -Because $output
        Test-Path -LiteralPath (Join-Path $literalRoot 'context[1]/docs/.git') -PathType Leaf |
            Should -BeTrue
        Test-Path -LiteralPath (Join-Path $literalRoot 'context[1]/memory/.git') -PathType Container |
            Should -BeTrue
        Test-Path -LiteralPath (Join-Path $literalRoot 'context1/docs/.git') -PathType Container |
            Should -BeTrue
        Test-Path -LiteralPath (Join-Path $literalRoot 'context1/memory/.git') -PathType Container |
            Should -BeTrue
    }

    It 'rejects duplicate repository paths after normalization' {
        $runner = Join-Path $fixture.Root 'invoke-duplicate-bootstrap.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$repositories = @(
    @{ Name = 'One/docs'; Path = 'same'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Two/memory'; Path = './same/'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$workspace' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Not -Be 0
        $output | Should -Match 'Repository paths overlap'
    }

    It 'rejects duplicate repository names before mutation' -ForEach @(
        @{ SecondPath = '' }
        @{ SecondPath = 'docs' }
    ) {
        $beforeDocs = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()
        $beforeMemory = (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'HEAD')).Trim()
        $runner = Join-Path $fixture.Root "invoke-duplicate-name-$($SecondPath -replace '[^A-Za-z0-9]', '-').ps1"
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$repositories = @(
    @{ Name = 'Duplicate'; Path = 'docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Duplicate'; Path = '$SecondPath'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$workspace' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Not -Be 0
        $output | Should -Match 'unique names'
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.git') | Should -BeFalse
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $beforeDocs
        (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $beforeMemory
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('status', '--porcelain')) |
            Should -BeNullOrEmpty
        (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('status', '--porcelain')) |
            Should -BeNullOrEmpty
    }

    It 'rejects repository paths overlapping canonical context storage' -ForEach @(
        @{ UnsafePath = 'docs' }
        @{ UnsafePath = 'docs.git' }
        @{ UnsafePath = 'memory' }
        @{ UnsafePath = 'docs/child' }
        @{ UnsafePath = 'docs.git/child' }
        @{ UnsafePath = 'memory/child' }
        @{ UnsafePath = 'docs.simple-clone-backup' }
        @{ UnsafePath = 'docs.simple-clone-backup/child' }
    ) {
        $beforeDocs = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()
        $beforeMemory = (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'HEAD')).Trim()
        $safeName = $UnsafePath -replace '[^A-Za-z0-9-]', '-'
        $runner = Join-Path $fixture.Root "invoke-overlap-$safeName.ps1"
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$repositories = @(
    @{ Name = 'MSXOrg/docs'; Path = 'docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'MSXOrg/memory'; Path = 'memory'; Url = '$memoryRemote'; Kind = 'memory' }
    @{ Name = 'Unsafe/docs'; Path = '$UnsafePath/docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Unsafe/memory'; Path = '$UnsafePath/memory'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$workspace' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Not -Be 0
        $output | Should -Match 'Repository paths overlap'
        $unsafeRoot = Join-Path $fixture.Workspace $UnsafePath
        foreach ($child in @('docs', 'docs.git', 'memory', 'docs.simple-clone-backup')) {
            Test-Path -LiteralPath (Join-Path $unsafeRoot $child) | Should -BeFalse
        }
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $beforeDocs
        (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $beforeMemory
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('status', '--porcelain')) |
            Should -BeNullOrEmpty
        (Invoke-Git -WorkingDirectory $fixture.Memory -Arguments @('status', '--porcelain')) |
            Should -BeNullOrEmpty
    }

    It 'rejects overlapping non-empty repository paths before mutation' {
        $runner = Join-Path $fixture.Root 'invoke-overlapping-roots.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$repositories = @(
    @{ Name = 'Parent'; Path = 'projects/Parent'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Child'; Path = 'projects/Parent/Child'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$workspace' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Not -Be 0
        $output | Should -Match 'Repository paths overlap'
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'projects') | Should -BeFalse
    }

    It 'reuses a canonical docs worktree with a legacy bare backing path' {
        Remove-Item -LiteralPath $fixture.Docs -Recurse -Force
        $legacyBacking = Join-Path $fixture.Root 'legacy-docs-backing.git'
        Invoke-Git -Arguments @('clone', '--bare', '--quiet', $fixture.Remotes.docs, $legacyBacking) | Out-Null
        Invoke-Git -Arguments @(
            "--git-dir=$legacyBacking",
            'config',
            '--add',
            'remote.origin.fetch',
            '+refs/heads/*:refs/remotes/origin/*'
        ) | Out-Null
        Invoke-Git -Arguments @("--git-dir=$legacyBacking", 'fetch', '--quiet', 'origin') | Out-Null
        Invoke-Git -Arguments @("--git-dir=$legacyBacking", 'worktree', 'add', '--quiet', $fixture.Docs, 'main') | Out-Null

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Be 0 -Because $result.Output
        $commonDir = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @(
                'rev-parse',
                '--path-format=absolute',
                '--git-common-dir'
            )).Trim()
        [IO.Path]::GetFullPath($commonDir) | Should -BeExactly ([IO.Path]::GetFullPath($legacyBacking))
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.git') | Should -BeFalse
    }

    It 'installs missing docs as bare backing plus main worktree and memory as a simple clone' {
        $emptyRoot = Join-Path $fixture.Root 'empty-workspace'
        $runner = Join-Path $fixture.Root 'invoke-empty-bootstrap.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$repositories = @(
    @{ Name = 'Fixture/docs'; Path = 'docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Fixture/memory'; Path = 'memory'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$emptyRoot' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Be 0 -Because $output
        $docs = Join-Path $emptyRoot 'docs'
        $backing = Join-Path $emptyRoot 'docs.git'
        $memory = Join-Path $emptyRoot 'memory'
        Test-Path -LiteralPath (Join-Path $docs '.git') -PathType Leaf | Should -BeTrue
        (Invoke-Git -Arguments @("--git-dir=$backing", 'rev-parse', '--is-bare-repository')).Trim() |
            Should -BeExactly 'true'
        (Invoke-Git -WorkingDirectory $docs -Arguments @('branch', '--show-current')).Trim() | Should -BeExactly 'main'
        (Invoke-Git -WorkingDirectory $docs -Arguments @('status', '--porcelain')) | Should -BeNullOrEmpty
        (Invoke-Git -WorkingDirectory $docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()
        Test-Path -LiteralPath (Join-Path $memory '.git') -PathType Container |
            Should -BeTrue -Because $output
        (Invoke-Git -WorkingDirectory $memory -Arguments @('branch', '--show-current')).Trim() |
            Should -BeExactly 'main'
        (Invoke-Git -WorkingDirectory $memory -Arguments @('status', '--porcelain')) |
            Should -BeNullOrEmpty
        (Invoke-Git -WorkingDirectory $memory -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.memory -Arguments @('rev-parse', 'HEAD')).Trim()
        foreach ($repository in @($docs, $memory)) {
            (Invoke-Git -WorkingDirectory $repository -Arguments @('config', '--local', 'user.name')).Trim() |
                Should -BeExactly 'Fixture User'
            (Invoke-Git -WorkingDirectory $repository -Arguments @('config', '--local', 'user.email')).Trim() |
                Should -BeExactly 'fixture@example.invalid'
        }
        $emptyFixture = [pscustomobject]@{
            Root = $fixture.Root
            Workspace = $emptyRoot
            Remotes = $fixture.Remotes
        }
        (Invoke-BootstrapFixture -Fixture $emptyFixture).ExitCode | Should -Be 0
        (Invoke-Git -WorkingDirectory $docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()
        (Invoke-Git -WorkingDirectory $memory -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.memory -Arguments @('rev-parse', 'HEAD')).Trim()
    }

    It 'fast-forwards an existing bare backing before creating its missing main worktree' {
        $emptyRoot = Join-Path $fixture.Root 'backing-only-workspace'
        New-Item -ItemType Directory -Path $emptyRoot | Out-Null
        $backing = Join-Path $emptyRoot 'docs.git'
        Invoke-Git -Arguments @('clone', '--bare', '--quiet', $fixture.Remotes.docs, $backing) | Out-Null
        Add-TestCommit -Repository $fixture.Writers.docs -Name 'Advance after bare clone'
        Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('push', '--quiet') | Out-Null
        $remoteHead = (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()
        $runner = Join-Path $fixture.Root 'invoke-backing-only-bootstrap.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$repositories = @(
    @{ Name = 'Fixture/docs'; Path = 'docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Fixture/memory'; Path = 'memory'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$emptyRoot' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Be 0 -Because $output
        $docs = Join-Path $emptyRoot 'docs'
        (Invoke-Git -WorkingDirectory $docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $remoteHead
        (Invoke-Git -Arguments @("--git-dir=$backing", 'rev-parse', 'main')).Trim() | Should -BeExactly $remoteHead
    }

    It 'rolls back a post-move migration failure without changing the simple clone' {
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()
        $runner = Join-Path $fixture.Root 'invoke-failed-migration.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$env:MSX_BOOTSTRAP_TEST_FAIL_AFTER_DOCS_MOVE = '1'
`$repositories = @(
    @{ Name = 'Fixture/docs'; Path = 'docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Fixture/memory'; Path = 'memory'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$workspace' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Not -Be 0
        $output | Should -Match 'Migration activation failed'
        Test-Path -LiteralPath (Join-Path $fixture.Docs '.git') -PathType Container | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.git') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.simple-clone-backup') | Should -BeFalse
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $before
    }

    It 'removes prepared backing when moving the simple clone fails' {
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()
        $runner = Join-Path $fixture.Root 'invoke-failed-move.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$env:MSX_BOOTSTRAP_TEST_FAIL_DOCS_MOVE = '1'
`$repositories = @(
    @{ Name = 'Fixture/docs'; Path = 'docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'Fixture/memory'; Path = 'memory'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$workspace' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Not -Be 0
        $output | Should -Match 'Migration activation failed'
        Test-Path -LiteralPath (Join-Path $fixture.Docs '.git') -PathType Container | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.git') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'docs.simple-clone-backup') | Should -BeFalse
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly $before
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('status', '--porcelain')) |
            Should -BeNullOrEmpty
    }

    It 'installs canonical topology from the agent template seed block' {
        $Name = 'agent template'
        $MarkdownPath = '../bootstrap/AGENTS.template.md'
        $workspace = Join-Path $fixture.Root "seed-$($Name.Replace(' ', '-'))"
        $seedPath = Join-Path $PSScriptRoot $MarkdownPath

        $result = Invoke-BootstrapSeed -Fixture $fixture -MarkdownPath $seedPath -Workspace $workspace

        $result.ExitCode | Should -Be 0 -Because $result.Output
        $docs = Join-Path $workspace '.msxorg/docs'
        $backing = Join-Path $workspace '.msxorg/docs.git'
        $memory = Join-Path $workspace '.msxorg/memory'
        $psmoduleDocs = Join-Path $workspace '.psmodule/process-psmodule'
        $psmoduleMemory = Join-Path $workspace '.psmodule/memory'
        Test-Path -LiteralPath (Join-Path $docs '.git') -PathType Leaf | Should -BeTrue
        (Invoke-Git -Arguments @("--git-dir=$backing", 'rev-parse', '--is-bare-repository')).Trim() |
            Should -BeExactly 'true'
        (Invoke-Git -WorkingDirectory $docs -Arguments @('branch', '--show-current')).Trim() | Should -BeExactly 'main'
        (Invoke-Git -WorkingDirectory $docs -Arguments @('status', '--porcelain')) | Should -BeNullOrEmpty
        (Invoke-Git -WorkingDirectory $docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()
        Test-Path -LiteralPath (Join-Path $memory '.git') -PathType Container |
            Should -BeTrue -Because $result.Output
        Test-Path -LiteralPath (Join-Path $psmoduleDocs '.git') -PathType Leaf |
            Should -BeTrue -Because $result.Output
        Test-Path -LiteralPath (Join-Path $psmoduleMemory '.git') -PathType Container |
            Should -BeTrue -Because $result.Output
        (Invoke-Git -WorkingDirectory $docs -Arguments @('config', '--local', 'user.name')).Trim() |
            Should -BeExactly 'Marius Storhaug'
        (Invoke-BootstrapSeed -Fixture $fixture -MarkdownPath $seedPath -Workspace $workspace).ExitCode |
            Should -Be 0
    }

    It 'refreshes a stale bare backing before the seed creates its canonical worktree' {
        $workspace = Join-Path $fixture.Root 'seed-stale-backing'
        New-Item -ItemType Directory -Path (Join-Path $workspace '.msxorg') -Force | Out-Null
        $backing = Join-Path $workspace '.msxorg/docs.git'
        Invoke-Git -Arguments @('clone', '--bare', '--quiet', $fixture.Remotes.docs, $backing) | Out-Null
        Add-TestCommit -Repository $fixture.Writers.docs -Name 'Advance before seed'
        Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('push', '--quiet') | Out-Null
        $remoteHead = (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapSeed -Fixture $fixture -MarkdownPath $script:agentTemplate -Workspace $workspace

        $result.ExitCode | Should -Be 0 -Because $result.Output
        $docs = Join-Path $workspace '.msxorg/docs'
        (Invoke-Git -Arguments @("--git-dir=$backing", 'rev-parse', 'main')).Trim() | Should -BeExactly $remoteHead
        (Invoke-Git -WorkingDirectory $docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $remoteHead
    }

    It 'declares the canonical repositories at their preferred local paths' {
        $bootstrapText = Get-Content -LiteralPath $script:bootstrap -Raw

        $expectedRepositories = @(
            @{
                Name = 'MSXOrg/docs'
                Path = '.msxorg/docs'
                Url = 'https://github.com/MSXOrg/docs.git'
            }
            @{
                Name = 'MSXOrg/memory'
                Path = '.msxorg/memory'
                Url = 'https://github.com/MSXOrg/memory.git'
            }
            @{
                Name = 'PSModule/Process-PSModule'
                Path = '.psmodule/process-psmodule'
                Url = 'https://github.com/PSModule/Process-PSModule.git'
            }
            @{
                Name = 'PSModule/memory'
                Path = '.psmodule/memory'
                Url = 'https://github.com/PSModule/memory.git'
            }
        )

        foreach ($repository in $expectedRepositories) {
            $bootstrapText | Should -Match ([regex]::Escape("Name = '$($repository.Name)'"))
            $bootstrapText | Should -Match ([regex]::Escape("Path = '$($repository.Path)'"))
            $bootstrapText | Should -Match ([regex]::Escape("Url = '$($repository.Url)'"))
        }
        $bootstrapText | Should -Not -Match 'github\.com/PSModule/docs'
        $bootstrapText | Should -Not -Match "Join-Path `$HOME '\.msx'"
    }

    It 'keeps every router example repository-addressable and access-method neutral' {
        $directive = 'Read nearest first, prefer documentation over memory, and always use the newest version.'
        $routerPaths = @(
            (Join-Path $PSScriptRoot '../AGENTS.md')
            (Join-Path $PSScriptRoot '../bootstrap/AGENTS.template.md')
            (Join-Path $PSScriptRoot '../src/docs/Capabilities/agentic-development/design.md')
        )

        foreach ($routerPath in $routerPaths) {
            $router = Get-Content -LiteralPath $routerPath -Raw
            $router | Should -Match ([regex]::Escape($directive))
            $router | Should -Match 'MSXOrg/docs'
            $router | Should -Match 'MSXOrg/memory'
            $router | Should -Match '~/.msxorg/docs'
            $router | Should -Match '~/.msxorg/memory'
        }

        $design = Get-Content -LiteralPath $routerPaths[2] -Raw
        $design | Should -Match 'PSModule/Process-PSModule'
        $design | Should -Match 'PSModule/memory'
        $design | Should -Match '~/.psmodule/process-psmodule'
        $design | Should -Match '~/.psmodule/memory'
        $design | Should -Match 'https://msxorg\.github\.io/docs/'
        $design | Should -Match 'https://psmodule\.io/docs/Modules/Process-PSModule/'
        $design | Should -Match '(?i)private.+MSXOrg/memory|MSXOrg/memory.+private'
        $design | Should -Match '(?i)private.+PSModule/memory|PSModule/memory.+private'
        $design | Should -Match '(?i)CLI.+web.+published.+local clone'
    }

    It 'ignores former layout content and creates fresh canonical clones with diagnostics' {
        $homeRoot = Join-Path $fixture.Root 'migration-home'
        $legacyPaths = @(
            '.msx/docs'
            '.msx/memory'
            '.msx/projects/PSModule/docs'
            '.msx/projects/PSModule/memory'
        )
        foreach ($legacyPath in $legacyPaths) {
            $path = Join-Path $homeRoot $legacyPath
            New-Item -ItemType Directory -Path $path -Force | Out-Null
            Set-Content -LiteralPath (Join-Path $path 'stale.txt') -Value 'must not be trusted'
        }

        $runner = Join-Path $fixture.Root 'invoke-layout-migration.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $root = $homeRoot.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$repositories = @(
    @{ Name = 'MSXOrg/docs'; Path = '.msxorg/docs'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'MSXOrg/memory'; Path = '.msxorg/memory'; Url = '$memoryRemote'; Kind = 'memory' }
    @{ Name = 'PSModule/Process-PSModule'; Path = '.psmodule/process-psmodule'; Url = '$docsRemote'; Kind = 'docs' }
    @{ Name = 'PSModule/memory'; Path = '.psmodule/memory'; Url = '$memoryRemote'; Kind = 'memory' }
)
& '$bootstrap' -Root '$root' -Repository `$repositories -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Be 0 -Because $output
        $output | Should -Match 'Former context path'
        $output | Should -Match 'will not be used'
        foreach ($legacyPath in $legacyPaths) {
            Test-Path -LiteralPath (Join-Path $homeRoot "$legacyPath/stale.txt") | Should -BeTrue
        }
        foreach ($canonicalPath in @(
                '.msxorg/docs'
                '.msxorg/memory'
                '.psmodule/process-psmodule'
                '.psmodule/memory'
            )) {
            $path = Join-Path $homeRoot $canonicalPath
            Test-Path -LiteralPath (Join-Path $path 'stale.txt') | Should -BeFalse
            Test-Path -LiteralPath (Join-Path $path '.git') | Should -BeTrue
        }
    }
}
