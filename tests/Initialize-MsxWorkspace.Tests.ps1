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
`$projects = @(
    @{
        Name = 'Fixture'
        Path = ''
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
)
& '$bootstrap' -Root '$workspace' -Project `$projects -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
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
            $previousRoot = $env:MSX_WORKSPACE_ROOT
            $previousDocs = $env:MSX_DOCS_URL
            $previousMemory = $env:MSX_MEMORY_URL
            try {
                $env:MSX_WORKSPACE_ROOT = $Workspace
                $env:MSX_DOCS_URL = $Fixture.Remotes.docs
                $env:MSX_MEMORY_URL = $Fixture.Remotes.memory
                $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String
                return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
            } finally {
                $env:MSX_WORKSPACE_ROOT = $previousRoot
                $env:MSX_DOCS_URL = $previousDocs
                $env:MSX_MEMORY_URL = $previousMemory
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
        $before = (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapFixture -Fixture $fixture

        $result.ExitCode | Should -Not -Be 0
        $result.Output | Should -Match 'git fetch failed'
        (Invoke-Git -WorkingDirectory $fixture.Docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $before
    }

    It 'installs additional project context through plug-in coordinates' {
        $runner = Join-Path $fixture.Root 'invoke-project-bootstrap.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$projects = @(
    @{
        Name = 'MSXOrg'
        Path = ''
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
    @{
        Name = 'Project'
        Path = './projects/Project/'
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
)
& '$bootstrap' -Root '$workspace' -Project `$projects -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Be 0 -Because $output
        $projectDocs = Join-Path $fixture.Workspace 'projects/Project/docs'
        $projectMemory = Join-Path $fixture.Workspace 'projects/Project/memory'
        Test-Path -LiteralPath (Join-Path $projectDocs '.git') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $projectMemory '.git') | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $fixture.Workspace 'projects/Project/docs.git') | Should -BeTrue
        (Invoke-Git -Arguments @(
            "--git-dir=$(Join-Path $fixture.Workspace 'projects/Project/docs.git')",
            'rev-parse',
            '--is-bare-repository'
        )).Trim() | Should -BeExactly 'true'
        (Invoke-Git -WorkingDirectory $projectDocs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()
        (Invoke-Git -WorkingDirectory $projectMemory -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.memory -Arguments @('rev-parse', 'HEAD')).Trim()
    }

    It 'rejects duplicate project paths after normalization' {
        $runner = Join-Path $fixture.Root 'invoke-duplicate-bootstrap.ps1'
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$projects = @(
    @{
        Name = 'One'
        Path = ''
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
    @{
        Name = 'Two'
        Path = '.'
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
)
& '$bootstrap' -Root '$workspace' -Project `$projects -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Not -Be 0
        $output | Should -Match 'workspace paths overlap'
    }

    It 'rejects project paths nested inside canonical docs storage' -ForEach @(
        @{ UnsafePath = 'docs' }
        @{ UnsafePath = 'docs.git' }
    ) {
        $runner = Join-Path $fixture.Root "invoke-overlap-$($UnsafePath.Replace('.', '-')).ps1"
        $bootstrap = $script:bootstrap.Replace("'", "''")
        $workspace = $fixture.Workspace.Replace("'", "''")
        $docsRemote = $fixture.Remotes.docs.Replace("'", "''")
        $memoryRemote = $fixture.Remotes.memory.Replace("'", "''")
        @"
`$projects = @(
    @{
        Name = 'MSXOrg'
        Path = ''
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
    @{
        Name = 'Unsafe'
        Path = '$UnsafePath'
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
)
& '$bootstrap' -Root '$workspace' -Project `$projects -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
exit `$LASTEXITCODE
"@ | Set-Content -LiteralPath $runner

        $output = & $script:pwsh -NoProfile -File $runner 2>&1 | Out-String

        $LASTEXITCODE | Should -Not -Be 0
        $output | Should -Match 'workspace paths overlap'
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
`$projects = @(
    @{
        Name = 'Fixture'
        Path = ''
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
)
& '$bootstrap' -Root '$emptyRoot' -Project `$projects -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
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
        $emptyFixture = [pscustomobject]@{
            Root = $fixture.Root
            Workspace = $emptyRoot
            Remotes = $fixture.Remotes
        }
        (Invoke-BootstrapFixture -Fixture $emptyFixture).ExitCode | Should -Be 0
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
`$projects = @(
    @{
        Name = 'Fixture'
        Path = ''
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
)
& '$bootstrap' -Root '$emptyRoot' -Project `$projects -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
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
`$projects = @(
    @{
        Name = 'Fixture'
        Path = ''
        DocsUrl = '$docsRemote'
        MemoryUrl = '$memoryRemote'
    }
)
& '$bootstrap' -Root '$workspace' -Project `$projects -UserName 'Fixture User' -UserEmail 'fixture@example.invalid'
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

    It 'installs canonical topology from the <Name> seed block' -ForEach @(
        @{ Name = 'agent template'; MarkdownPath = '../bootstrap/AGENTS.template.md' }
        @{ Name = 'bootstrap README'; MarkdownPath = '../bootstrap/README.md' }
    ) {
        $workspace = Join-Path $fixture.Root "seed-$($Name.Replace(' ', '-'))"
        $seedPath = Join-Path $PSScriptRoot $MarkdownPath

        $result = Invoke-BootstrapSeed -Fixture $fixture -MarkdownPath $seedPath -Workspace $workspace

        $result.ExitCode | Should -Be 0 -Because $result.Output
        $docs = Join-Path $workspace 'docs'
        $backing = Join-Path $workspace 'docs.git'
        $memory = Join-Path $workspace 'memory'
        Test-Path -LiteralPath (Join-Path $docs '.git') -PathType Leaf | Should -BeTrue
        (Invoke-Git -Arguments @("--git-dir=$backing", 'rev-parse', '--is-bare-repository')).Trim() |
            Should -BeExactly 'true'
        (Invoke-Git -WorkingDirectory $docs -Arguments @('branch', '--show-current')).Trim() | Should -BeExactly 'main'
        (Invoke-Git -WorkingDirectory $docs -Arguments @('status', '--porcelain')) | Should -BeNullOrEmpty
        (Invoke-Git -WorkingDirectory $docs -Arguments @('rev-parse', 'HEAD')).Trim() |
            Should -BeExactly (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()
        Test-Path -LiteralPath (Join-Path $memory '.git') -PathType Container |
            Should -BeTrue -Because $result.Output
        (Invoke-Git -WorkingDirectory $docs -Arguments @('config', '--local', 'user.name')).Trim() |
            Should -BeExactly 'Marius Storhaug'
        (Invoke-BootstrapSeed -Fixture $fixture -MarkdownPath $seedPath -Workspace $workspace).ExitCode |
            Should -Be 0
    }

    It 'refreshes a stale bare backing before the seed creates its canonical worktree' {
        $workspace = Join-Path $fixture.Root 'seed-stale-backing'
        New-Item -ItemType Directory -Path $workspace | Out-Null
        $backing = Join-Path $workspace 'docs.git'
        Invoke-Git -Arguments @('clone', '--bare', '--quiet', $fixture.Remotes.docs, $backing) | Out-Null
        Add-TestCommit -Repository $fixture.Writers.docs -Name 'Advance before seed'
        Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('push', '--quiet') | Out-Null
        $remoteHead = (Invoke-Git -WorkingDirectory $fixture.Writers.docs -Arguments @('rev-parse', 'HEAD')).Trim()

        $result = Invoke-BootstrapSeed -Fixture $fixture -MarkdownPath $script:agentTemplate -Workspace $workspace

        $result.ExitCode | Should -Be 0 -Because $result.Output
        $docs = Join-Path $workspace 'docs'
        (Invoke-Git -Arguments @("--git-dir=$backing", 'rev-parse', 'main')).Trim() | Should -BeExactly $remoteHead
        (Invoke-Git -WorkingDirectory $docs -Arguments @('rev-parse', 'HEAD')).Trim() | Should -BeExactly $remoteHead
    }
}
