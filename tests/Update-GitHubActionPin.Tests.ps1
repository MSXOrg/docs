#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseShouldProcessForStateChangingFunctions', '',
    Justification = 'Pester setup helpers must create disposable fixtures and register mocks without WhatIf semantics.'
)]
param()

Describe 'Update-GitHubActionPin' {
    BeforeAll {
        $script:sourceScript = Join-Path $PSScriptRoot '../.github/scripts/Update-GitHubActionPin.ps1'
        . $script:sourceScript

        function New-ActionFixture {
            param(
                [Parameter(Mandatory)]
                [string] $Content,

                [Parameter(Mandatory)]
                [string] $NewLine,

                [Parameter()]
                [switch] $Utf8Bom
            )

            $root = Join-Path ([System.IO.Path]::GetTempPath()) "docs-action-pin-$([guid]::NewGuid().ToString('N'))"
            $workflowDirectory = New-Item -ItemType Directory -Path (Join-Path $root '.github/workflows')
            $path = Join-Path $workflowDirectory.FullName 'workflow.yml'
            $text = [regex]::Replace($Content, '\r\n|\r|\n', $NewLine)
            [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::new($Utf8Bom))

            return [pscustomobject]@{
                Root = $root
                Path = $path
            }
        }

        function Set-GitHubApiMock {
            Mock -CommandName Invoke-RestMethod -MockWith {
                param([string] $Uri)

                if ($Uri -match '/releases/latest$') {
                    return [pscustomobject]@{ tag_name = 'v2.0.0' }
                }
                if ($Uri -match '/git/ref/tags/v2.0.0$') {
                    return [pscustomobject]@{
                        object = [pscustomobject]@{ type = 'tag'; sha = '1111111111111111111111111111111111111111' }
                    }
                }
                if ($Uri -match '/git/tags/1111111111111111111111111111111111111111$') {
                    return [pscustomobject]@{
                        object = [pscustomobject]@{ type = 'commit'; sha = '2222222222222222222222222222222222222222' }
                    }
                }

                throw "Unexpected GitHub API request: $Uri"
            }
        }
    }

    AfterEach {
        if ($fixture -and (Test-Path -LiteralPath $fixture.Root)) {
            Remove-Item -LiteralPath $fixture.Root -Recurse -Force
        }
    }

    It 'updates annotated-tag releases, composite action subpaths, and missing tag comments' {
        $fixture = New-ActionFixture -NewLine "`r`n" -Utf8Bom -Content @'
jobs:
  build:
    steps:
      - uses: actions/checkout@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa # v1
      - uses: octo/example/setup@bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
      - uses: ./local-action
      - uses: docker://alpine:3.20
'@
        Set-GitHubApiMock

        $result = Update-GitHubActionPin -RepositoryPath $fixture.Root -ApiBaseUri 'https://api.example.test'
        $bytes = [System.IO.File]::ReadAllBytes($fixture.Path)
        $content = [System.IO.File]::ReadAllText($fixture.Path)

        $result.Updates | Should -Be 2
        $result.Updated | Should -BeTrue
        $content | Should -Match 'actions/checkout@2222222222222222222222222222222222222222 # v2\.0\.0'
        $content | Should -Match 'octo/example/setup@2222222222222222222222222222222222222222 # v2\.0\.0'
        $content | Should -Match 'uses: \./local-action'
        $content | Should -Match 'uses: docker://alpine:3\.20'
        ($bytes[0..2] -join ',') | Should -Be '239,187,191'
        $content.Replace("`r`n", '') | Should -Not -Match '[\r\n]'
        Should -Invoke -CommandName Invoke-RestMethod -Times 6
    }

    It 'does not write changes when WhatIf is specified' {
        $fixture = New-ActionFixture -NewLine "`n" -Content @'
jobs:
  build:
    steps:
      - uses: actions/checkout@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
'@
        $before = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($fixture.Path))
        Set-GitHubApiMock

        $result = Update-GitHubActionPin -RepositoryPath $fixture.Root -ApiBaseUri 'https://api.example.test' -WhatIf

        $result.Updated | Should -BeFalse
        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($fixture.Path)) | Should -BeExactly $before
    }

    It 'does not rewrite an action pin that already matches the latest release' {
        $fixture = New-ActionFixture -NewLine "`n" -Content @'
jobs:
  build:
    steps:
      - uses: actions/checkout@2222222222222222222222222222222222222222 # v2.0.0
'@
        $before = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($fixture.Path))
        Set-GitHubApiMock

        $result = Update-GitHubActionPin -RepositoryPath $fixture.Root -ApiBaseUri 'https://api.example.test'

        $result | Should -BeNullOrEmpty
        [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($fixture.Path)) | Should -BeExactly $before
    }

    It 'fails explicitly when GitHub returns no latest stable release tag' {
        $fixture = New-ActionFixture -NewLine "`n" -Content @'
jobs:
  build:
    steps:
      - uses: actions/checkout@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
'@
        Mock -CommandName Invoke-RestMethod -MockWith {
            [pscustomobject]@{ tag_name = '' }
        }

        {
            Update-GitHubActionPin -RepositoryPath $fixture.Root -ApiBaseUri 'https://api.example.test'
        } | Should -Throw "*no latest stable release tag for action repository 'actions/checkout'*"
    }
}
