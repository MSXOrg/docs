#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

$ErrorActionPreference = 'Stop'

$releaseDocuments = @(
    @{ Document = 'Capabilities\release-management\design.md' }
    @{ Document = 'Capabilities\release-management\spec.md' }
    @{ Document = 'Capabilities\vscode-extension-framework\design.md' }
    @{ Document = 'Ways-of-Working\Automation-Labels.md' }
    @{ Document = 'Ways-of-Working\PR-Format.md' }
)

Describe 'Release settings documentation' {
    BeforeAll {
        $repositoryRoot = Split-Path -Path $PSScriptRoot -Parent
        $script:documentationRoot = Join-Path -Path $repositoryRoot -ChildPath 'src\docs'
    }

    It '<Document> uses the canonical repository release settings filename' -ForEach $releaseDocuments {
        $path = Join-Path -Path $documentationRoot -ChildPath $Document
        $content = Get-Content -LiteralPath $path -Raw

        $content -cmatch '\.github/release\.settings\.yml\b' |
            Should -BeTrue -Because 'the release settings stay in the .github directory'
        $content -notmatch '\brelease\.config\.yml\b' |
            Should -BeTrue -Because 'active guidance no longer uses the previous filename'
    }
}
