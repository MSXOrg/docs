#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

Describe 'Test-CrossRepositoryLink' {
    BeforeAll {
        $script:sourceScript = Join-Path $PSScriptRoot '../.github/scripts/Test-CrossRepositoryLink.ps1'
        $script:pwsh = (Get-Process -Id $PID).Path
        $script:utf8 = [System.Text.UTF8Encoding]::new($false)

        # The stub API runs in-process, in its own runspace, so a test never touches
        # github.com. It answers the two endpoints the script calls and nothing else.
        $script:serve = {
            param($Listener, $Store)

            function Write-StubResponse {
                param($Context, [int] $Status, [string] $Body, [switch] $RateLimited)
                $Context.Response.StatusCode = $Status
                $Context.Response.ContentType = 'application/json'
                if ($RateLimited) {
                    $Context.Response.Headers.Add('x-ratelimit-remaining', '0')
                    $Context.Response.Headers.Add('x-ratelimit-reset', '1700000000')
                }
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($Body)
                $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
                $Context.Response.Close()
            }

            while ($Listener.IsListening) {
                try {
                    $context = $Listener.GetContext()
                } catch {
                    break
                }
                try {
                    $requestPath = $context.Request.Url.AbsolutePath
                    Add-Content -LiteralPath (Join-Path $Store '_requests.log') -Value "$requestPath$($context.Request.Url.Query)"

                    $statusFile = Join-Path $Store '_status.txt'
                    if (Test-Path -LiteralPath $statusFile) {
                        $forced = [int]((Get-Content -LiteralPath $statusFile -Raw).Trim())
                        Write-StubResponse -Context $context -Status $forced -Body '{"message":"forced"}' -RateLimited:($forced -eq 403)
                        continue
                    }

                    if ($requestPath -match '^/repos/([^/]+)/([^/]+)/contents(?:/(.*))?$') {
                        $repositoryStore = Join-Path $Store "$($matches[1])/$($matches[2])"
                        $itemPath = if ($matches.Count -gt 3 -and $matches[3]) { [uri]::UnescapeDataString($matches[3]) } else { '' }
                        $reference = if ($context.Request.Url.Query -match 'ref=([^&]+)') { $matches[1] } else { 'main' }
                        if (-not (Test-Path -LiteralPath $repositoryStore)) {
                            Write-StubResponse -Context $context -Status 404 -Body '{"message":"Not Found"}'
                            continue
                        }
                        $item = if ($itemPath) { Join-Path $repositoryStore $reference $itemPath } else { Join-Path $repositoryStore $reference }
                        if (Test-Path -LiteralPath $item -PathType Leaf) {
                            $encoded = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($item))
                            $payload = [pscustomobject]@{ type = 'file'; encoding = 'base64'; content = $encoded } | ConvertTo-Json -Compress
                            Write-StubResponse -Context $context -Status 200 -Body $payload
                        } elseif (Test-Path -LiteralPath $item -PathType Container) {
                            Write-StubResponse -Context $context -Status 200 -Body '[]'
                        } else {
                            Write-StubResponse -Context $context -Status 404 -Body '{"message":"Not Found"}'
                        }
                        continue
                    }

                    if ($requestPath -match '^/repos/([^/]+)/([^/]+)/?$') {
                        $repositoryStore = Join-Path $Store "$($matches[1])/$($matches[2])"
                        if (Test-Path -LiteralPath $repositoryStore) {
                            Write-StubResponse -Context $context -Status 200 -Body "{`"full_name`":`"$($matches[1])/$($matches[2])`"}"
                        } else {
                            Write-StubResponse -Context $context -Status 404 -Body '{"message":"Not Found"}'
                        }
                        continue
                    }

                    Write-StubResponse -Context $context -Status 404 -Body '{"message":"Not Found"}'
                } catch {
                    # A stub that dies takes the whole suite with it; keep serving.
                    Write-Verbose "Stub API request failed: $($_.Exception.Message)"
                }
            }
        }

        function New-CrossLinkFixture {
            <#
                .SYNOPSIS
                Create a throwaway repository and a stub GitHub API to resolve against.

                .DESCRIPTION
                Lay out what Test-CrossRepositoryLink.ps1 expects - a copy of the script
                under '.github/scripts' and content under 'src/docs' - beside a store the
                stub API serves target repositories from. 'src/docs/Real.md' always exists
                as a local target for links into this repository itself.

                .EXAMPLE
                New-CrossLinkFixture -Content '# Page' -Target @{ 'PSModule/Demo/main/docs/Guide.md' = '# Guide' }
                Returns the fixture paths and the stub API's base URI.

                .OUTPUTS
                [pscustomobject]
            #>
            [CmdletBinding(SupportsShouldProcess)]
            param(
                # The Markdown body written to 'src/docs/Page.md'.
                [Parameter(Mandatory)]
                [string] $Content,

                # Target files the stub API serves, keyed by '<owner>/<repo>/<ref>/<path>'.
                [Parameter()]
                [hashtable] $Target = @{},

                # HTTP status the stub returns for every request, instead of resolving it.
                [Parameter()]
                [int] $ForcedStatus
            )

            $base = Join-Path ([System.IO.Path]::GetTempPath()) "xrepo-link-$([guid]::NewGuid().ToString('N'))"
            if (-not $PSCmdlet.ShouldProcess($base, 'Create cross-repository link fixture')) {
                return
            }
            $scripts = New-Item -ItemType Directory -Path (Join-Path $base 'repo/.github/scripts')
            $docs = New-Item -ItemType Directory -Path (Join-Path $base 'repo/src/docs')
            $store = New-Item -ItemType Directory -Path (Join-Path $base 'api')
            Copy-Item -LiteralPath $script:sourceScript -Destination $scripts.FullName

            [System.IO.File]::WriteAllText((Join-Path $docs.FullName 'Real.md'), "# Real`n", $script:utf8)
            [System.IO.File]::WriteAllText((Join-Path $docs.FullName 'Page.md'), $Content, $script:utf8)

            foreach ($key in $Target.Keys) {
                $item = Join-Path $store.FullName $key
                $null = New-Item -ItemType Directory -Path (Split-Path -Parent $item) -Force
                [System.IO.File]::WriteAllText($item, $Target[$key], $script:utf8)
            }
            if ($PSBoundParameters.ContainsKey('ForcedStatus')) {
                [System.IO.File]::WriteAllText((Join-Path $store.FullName '_status.txt'), "$ForcedStatus", $script:utf8)
            }

            $probe = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
            $probe.Start()
            $port = $probe.LocalEndpoint.Port
            $probe.Stop()

            $listener = [System.Net.HttpListener]::new()
            $listener.Prefixes.Add("http://localhost:$port/")
            $listener.Start()

            $runspace = [runspacefactory]::CreateRunspace()
            $runspace.Open()
            $shell = [powershell]::Create()
            $shell.Runspace = $runspace
            $null = $shell.AddScript($script:serve).AddArgument($listener).AddArgument($store.FullName)
            $null = $shell.BeginInvoke()

            return [pscustomobject]@{
                Base = $base
                ScriptPath = Join-Path $scripts.FullName 'Test-CrossRepositoryLink.ps1'
                Store = $store.FullName
                RequestLog = Join-Path $store.FullName '_requests.log'
                ApiBaseUri = "http://localhost:$port"
                Listener = $listener
                Shell = $shell
                Runspace = $runspace
            }
        }

        function Invoke-CrossLinkFixture {
            <#
                .SYNOPSIS
                Run the fixture's copy of the cross-repository link check.

                .DESCRIPTION
                Invoke the script in a separate PowerShell process so the assertion is made
                on the real exit code and console output CI sees, not on internal state.

                .EXAMPLE
                Invoke-CrossLinkFixture -Fixture $fixture
                Returns the script's exit code and combined output.

                .OUTPUTS
                [pscustomobject]
            #>
            [CmdletBinding()]
            param(
                # The fixture returned by New-CrossLinkFixture.
                [Parameter(Mandatory)]
                [psobject] $Fixture
            )

            $output = & $script:pwsh -NoProfile -File $Fixture.ScriptPath -ApiBaseUri $Fixture.ApiBaseUri -SelfRepository 'MSXOrg/docs' 2>&1 | Out-String

            return [pscustomobject]@{
                ExitCode = $LASTEXITCODE
                Output = $output
            }
        }

        function Stop-CrossLinkFixture {
            <#
                .SYNOPSIS
                Shut down a fixture's stub API and delete its files.

                .DESCRIPTION
                Stop the listener, dispose the runspace serving it, and remove the temporary
                tree, so a suite leaves neither a listening port nor a directory behind.

                .EXAMPLE
                Stop-CrossLinkFixture -Fixture $fixture
                Releases the port and deletes the fixture.

                .OUTPUTS
                None
            #>
            [CmdletBinding(SupportsShouldProcess)]
            param(
                # The fixture returned by New-CrossLinkFixture.
                [Parameter(Mandatory)]
                [psobject] $Fixture
            )
            if (-not $PSCmdlet.ShouldProcess($Fixture.Base, 'Remove cross-repository link fixture')) {
                return
            }
            $Fixture.Listener.Stop()
            $Fixture.Listener.Close()
            $Fixture.Shell.Dispose()
            $Fixture.Runspace.Dispose()
            if (Test-Path -LiteralPath $Fixture.Base) {
                Remove-Item -LiteralPath $Fixture.Base -Recurse -Force
            }
        }
    }

    AfterEach {
        if ($fixture) {
            Stop-CrossLinkFixture -Fixture $fixture
            $fixture = $null
        }
    }

    Context 'Broken targets' {
        It 'fails and names the link when the target file does not exist' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [guide](https://github.com/PSModule/Demo/blob/main/docs/Missing.md).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'Broken cross-repository links'
            $result.Output | Should -Match 'docs/Missing\.md'
            $result.Output | Should -Match 'does not exist'
            $result.Output | Should -Match 'src/docs/Page\.md:3'
        }

        It 'fails and names the anchor when no heading in the target produces it' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [guide](https://github.com/PSModule/Demo/blob/main/docs/Guide.md#missing-anchor).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n`n## Real section`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'Broken cross-repository links'
            $result.Output | Should -Match 'missing-anchor'
            $result.Output | Should -Match 'no heading'
        }

        It 'fails when a link into this repository points at a file the checkout does not have' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [helper](https://github.com/MSXOrg/docs/blob/main/src/docs/Gone.md).
'@

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'does not exist'
            (Test-Path -LiteralPath $fixture.RequestLog) | Should -BeFalse
        }
        It 'fails when a link names a branch the target repository does not have' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [branch](https://github.com/PSModule/Demo/tree/no-such-branch).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'Broken cross-repository links'
            $result.Output | Should -Match 'no branch, tag, or commit named'
            $result.Output | Should -Match 'no-such-branch'
        }
    }

    Context 'Resolving targets' {
        It 'passes when the target file and its anchor both exist' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [guide](https://github.com/PSModule/Demo/blob/main/docs/Guide.md#real-section).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n`n## Real section`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 0
            $result.Output | Should -Match 'Every one of them resolves'
        }

        It 'resolves a link to a branch the target repository does have' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [branch](https://github.com/PSModule/Demo/tree/main).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 0
            $result.Output | Should -Match 'Every one of them resolves'
        }

        It 'resolves a link into this repository against the checkout instead of the network' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See [Real](https://github.com/MSXOrg/docs/blob/main/src/docs/Real.md#real).
'@

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 0
            (Test-Path -LiteralPath $fixture.RequestLog) | Should -BeFalse
        }

        It 'resolves an anchor on a repository landing page against its README' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [tests](https://github.com/PSModule/Demo?tab=readme-ov-file#module-tests).
'@ -Target @{ 'PSModule/Demo/main/README.md' = "# Demo`n`n## Module tests`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 0
            $result.Output | Should -Match 'Every one of them resolves'
        }

        It 'fetches a target linked from several places exactly once' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [first section](https://github.com/PSModule/Demo/blob/main/docs/Guide.md#one) and the
[second section](https://github.com/PSModule/Demo/blob/main/docs/Guide.md#two).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n`n## One`n`n## Two`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 0
            @(Get-Content -LiteralPath $fixture.RequestLog | Where-Object { $_ -match 'contents' }).Count | Should -Be 1
        }
    }

    Context 'Anchors follow GitHub slug rules, not the site slug rules' {
        It "accepts GitHub's slug for a heading the site would slug differently" {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [section](https://github.com/PSModule/Demo/blob/main/docs/Guide.md#hello--world).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n`n## Hello $([char]0x2014) world`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 0
        }

        It "rejects the site's slug for that same heading" {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [section](https://github.com/PSModule/Demo/blob/main/docs/Guide.md#hello-world).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n`n## Hello $([char]0x2014) world`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'no heading'
        }

        It "suffixes a repeated heading the way GitHub does, not the way the site does" {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [second](https://github.com/PSModule/Demo/blob/main/docs/Guide.md#duplicate-1).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n`n## Duplicate`n`n## Duplicate`n" }

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 0
        }
    }

    Context 'A run that resolved nothing' {
        It 'fails when no cross-repository link was found at all' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See [Real](Real.md).
'@

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'nothing was validated'
            $result.Output | Should -Match 'A check that checked nothing is a failure, not a pass'
        }

        It 'ignores a link to an owner outside the configured scope' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See [super-linter](https://github.com/super-linter/super-linter/blob/main/Nope.md).
'@

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'nothing was validated'
        }

        It 'ignores a link to an issue, which is not a file that moves' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See [issue 142](https://github.com/MSXOrg/docs/issues/142).
'@

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'nothing was validated'
        }
    }

    Context 'A link the check could not resolve is not a broken link' {
        It 'reports an exhausted rate limit as its own failure' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [guide](https://github.com/PSModule/Demo/blob/main/docs/Guide.md).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n" } -ForcedStatus 403

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'could not be resolved'
            $result.Output | Should -Match 'rate limit'
            $result.Output | Should -Not -Match 'Broken cross-repository links'
        }

        It 'stops asking once the quota is gone' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [guide](https://github.com/PSModule/Demo/blob/main/docs/Guide.md) and the
[other guide](https://github.com/PSModule/Demo/blob/main/docs/Other.md).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n" } -ForcedStatus 403

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            @(Get-Content -LiteralPath $fixture.RequestLog).Count | Should -Be 1
        }

        It 'reports a failing request as its own failure' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [guide](https://github.com/PSModule/Demo/blob/main/docs/Guide.md).
'@ -Target @{ 'PSModule/Demo/main/docs/Guide.md' = "# Guide`n" } -ForcedStatus 500

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'could not be resolved'
            $result.Output | Should -Match 'attempt'
            $result.Output | Should -Not -Match 'Broken cross-repository links'
        }

        It 'reports a target repository a reader cannot read as its own failure' {
            $fixture = New-CrossLinkFixture -Content @'
# Page

See the [guide](https://github.com/PSModule/Private/blob/main/docs/Guide.md).
'@

            $result = Invoke-CrossLinkFixture -Fixture $fixture

            $result.ExitCode | Should -Be 1
            $result.Output | Should -Match 'could not be resolved'
            $result.Output | Should -Match 'not publicly readable'
            $result.Output | Should -Not -Match 'Broken cross-repository links'
        }
    }
}

Describe 'ConvertTo-GitHubSlug' {
    BeforeAll {
        # Load the function without running the script: a script that did work merely by
        # being dot-sourced would violate the Scripts standard, and parsing keeps the test
        # honest about that.
        $scriptPath = (Resolve-Path (Join-Path $PSScriptRoot '../.github/scripts/Test-CrossRepositoryLink.ps1')).ProviderPath
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref] $null, [ref] $null)
        $definition = $ast.Find({
                param($node)
                $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'ConvertTo-GitHubSlug'
            }, $true)
        . ([scriptblock]::Create($definition.Extent.Text))
    }

    # The expected values are a recorded fixture, not a second derivation: each one was
    # produced by running github-slugger 2.0.0 - the library GitHub's own anchors come
    # from - over the heading on the left. The cases are written inline because '-ForEach'
    # is expanded at discovery, before any 'BeforeAll' has run. Regenerate with:
    #   npm install github-slugger
    #   node -e "import('github-slugger').then(m=>{const s=new m.default();console.log(s.slug('Hello, world!'))})"
    It "slugs '<Heading>' as '<Slug>'" -ForEach @(
        @{ Heading = 'Hello, world!'; Slug = 'hello-world' }
        @{ Heading = 'Prefer .NET for the actual work'; Slug = 'prefer-net-for-the-actual-work' }
        @{ Heading = "Don't mock what you don't own"; Slug = 'dont-mock-what-you-dont-own' }
        @{ Heading = "Hello $([char]0x2014) world"; Slug = 'hello--world' }
        @{ Heading = "Gr$([char]0x00FC)nanlage"; Slug = "gr$([char]0x00FC)nanlage" }
        @{ Heading = 'CI/CD pipeline'; Slug = 'cicd-pipeline' }
        @{ Heading = "Bruksordning for veg - $([char]0x00A7) 3-8"; Slug = 'bruksordning-for-veg----3-8' }
        @{ Heading = 'A heading with  double  spaces'; Slug = 'a-heading-with--double--spaces' }
        @{ Heading = 'snake_case and kebab-case'; Slug = 'snake_case-and-kebab-case' }
        @{ Heading = '100% coverage?'; Slug = '100-coverage' }
        @{ Heading = "$([char]0x041F)$([char]0x0440)$([char]0x0438)$([char]0x0432)$([char]0x0435)$([char]0x0442) non-latin $([char]0x4F60)$([char]0x597D)"; Slug = "$([char]0x043F)$([char]0x0440)$([char]0x0438)$([char]0x0432)$([char]0x0435)$([char]0x0442)-non-latin-$([char]0x4F60)$([char]0x597D)" }
        @{ Heading = 'env vars & secrets'; Slug = 'env-vars--secrets' }
        @{ Heading = 'parens (like this)'; Slug = 'parens-like-this' }
        @{ Heading = "emoji $([char]::ConvertFromUtf32(0x1F680)) heading"; Slug = 'emoji--heading' }
    ) {
        ConvertTo-GitHubSlug -Text $Heading | Should -BeExactly $Slug
    }
}
