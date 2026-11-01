#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

Describe 'PR Format authoring contract' {
    BeforeAll {
        $ErrorActionPreference = 'Stop'
        $repositoryRoot = Split-Path -Path $PSScriptRoot -Parent
        $documentationRoot = [IO.Path]::Combine($repositoryRoot, 'src', 'docs', 'Ways-of-Working')
        $script:format = [IO.File]::ReadAllText([IO.Path]::Combine($documentationRoot, 'PR-Format.md'))
        $script:recordExample = [regex]::Match(
            $format,
            '(?s)````markdown\r?\n(?<body>.*?)\r?\n````'
        )
    }

    It 'resolves artifact publication coverage before inspecting the scoped PR diff' {
        $coveragePosition = $format.IndexOf('### Resolve release coverage first', [StringComparison]::Ordinal)
        $reviewerPosition = $format.IndexOf('### Read the whole change', [StringComparison]::Ordinal)

        $coveragePosition | Should -BeGreaterOrEqual 0
        $reviewerPosition | Should -BeGreaterThan $coveragePosition
    }

    It 'requires published and candidate identities separately from the scoped PR comparison' {
        $requiredEvidence = @(
            '| Product scope |'
            '| Published artifact |'
            '| Published source |'
            '| Candidate source |'
            '| Scoped PR comparison |'
        )

        foreach ($field in $requiredEvidence) {
            $format | Should -Match ([regex]::Escape($field))
        }
    }

    It 'retains one complete description example with one boundary and five ordered classifiers' {
        $recordExample.Success | Should -BeTrue
        $body = $recordExample.Groups['body'].Value
        $boundary = [regex]::Escape('<!-- ANNOUNCEMENT STOP -->')

        [regex]::Matches($body, $boundary).Count | Should -Be 1
        $classifiers = @(
            [regex]::Matches($body, '(?m)^## (Breaking|Removed|New|Changed|Fixed):') |
                ForEach-Object { $_.Groups[1].Value }
        )
        $classifiers.Count | Should -Be 5
        $classifiers -join ',' | Should -BeExactly 'Breaking,Removed,New,Changed,Fixed'
    }

    It 'prompts every classifier for publication-baseline evidence' {
        $recordExample.Success | Should -BeTrue
        $prompt = [regex]::Escape('{{ Publication-baseline evidence:')

        [regex]::Matches($recordExample.Groups['body'].Value, $prompt).Count | Should -Be 5
    }

    It 'focuses on the authored record instead of repository file policy' {
        $format | Should -Match '### Complete description example'
        $format | Should -Not -Match 'PR-template|pull_request_template|GitHub PR template|inherited GitHub scaffold'
    }

    It 'retains five affected-product integration-evidence prompts' {
        $prompt = [regex]::Escape('For an affected integration template, identify its')

        [regex]::Matches($format, $prompt).Count | Should -Be 5
    }
}

Describe 'Canonical release-settings authoring contract' {
    BeforeAll {
        $ErrorActionPreference = 'Stop'
        $script:repositoryRoot = Split-Path -Path $PSScriptRoot -Parent
        $script:documentationRoot = [IO.Path]::Combine($repositoryRoot, 'src', 'docs')
        $releaseRoot = [IO.Path]::Combine($documentationRoot, 'Capabilities', 'release-management')
        $script:releaseDesign = [IO.File]::ReadAllText([IO.Path]::Combine($releaseRoot, 'design.md'))
        $script:releaseSpec = [IO.File]::ReadAllText([IO.Path]::Combine($releaseRoot, 'spec.md'))
    }

    It 'uses only the canonical release.settings.yml filename in <Directory>/<File>' -ForEach @(
        @{ Directory = @('Ways-of-Working'); File = 'PR-Format.md' }
        @{ Directory = @('Ways-of-Working'); File = 'Automation-Labels.md' }
        @{ Directory = @('Capabilities', 'release-management'); File = 'spec.md' }
        @{ Directory = @('Capabilities', 'release-management'); File = 'design.md' }
        @{ Directory = @('Capabilities', 'vscode-extension-framework'); File = 'design.md' }
    ) {
        $segments = [string[]] (@($documentationRoot) + $Directory + @($File))
        $guidance = [IO.File]::ReadAllText([IO.Path]::Combine($segments))

        ($guidance -cmatch '\.github/release\.settings\.yml') | Should -BeTrue
        ($guidance -cmatch 'release\.config\.yml') | Should -BeFalse
    }

    It 'preserves the branch, bump, and path-filter settings in the examples' {
        $releaseDesign | Should -Match (
            'release-branches:\s+- branch: main\s+release-type: stable\s+' +
            '- branch: dev\s+release-type: prerelease'
        )
        $releaseDesign | Should -Match '(?m)^DefaultBump: minor\r?$'
        $releaseDesign | Should -Match '(?m)^release-paths:\r?$'
        $releaseDesign | Should -Match 'ordered\s+include/exclude globs \(excludes win\)'
    }

    It 'preserves defaults, caller precedence, omission, and invalid-setting validation' {
        $releaseDesign | Should -Match '`DefaultBump` accepts exactly `patch`, `minor`, or `major`'
        $releaseDesign | Should -Match (
            'default is `patch`; omitting the configuration file or field inherits that value'
        )
        $releaseDesign | Should -Match (
            '(?s)shared defaults are overridden by repository settings in the optional\s+' +
            '`[^`]+`, then by explicitly supplied supported caller\s+inputs for that invocation'
        )
        $releaseDesign | Should -Match (
            'Omitted caller inputs preserve repository settings;\s+' +
            'they do not overwrite them with an input''s default'
        )
        $releaseDesign | Should -Match (
            'Unknown setting names,\s+null or empty values, and values outside the documented set fail validation,\s+' +
            'even when a narrower override or bump label exists'
        )
    }

    It 'keeps the optional file separate from target-route applicability' {
        $releaseSpec | Should -Match (
            'does not create a release pipeline, and its absence\s+does not opt a managed route out'
        )
        $releaseDesign | Should -Match (
            'A site deployment without a versioned artifact is\s+not by itself a release-managed route'
        )
        $releaseSpec | Should -Match (
            'A route without versioned release behavior MUST NOT require, apply, or report the ' +
            '`Release decisions` block or any `release:\*` label'
        )
    }

    It 'preserves required decision checks for managed routes without the optional file' {
        $releaseSpec | Should -Match (
            'Every PR targeting an invoked release route MUST receive a named release-decision CI check ' +
            'required by the branch ruleset or protection'
        )
        $releaseSpec | Should -Match 'MUST block both manual and automated merge'
        $releaseDesign | Should -Match (
            'native producer routes, changes that will not publish, and repositories without\s+' +
            'a release configuration file'
        )
        $releaseDesign | Should -Match 'path filters do not skip the validator'
        $releaseDesign | Should -Match 'failure, pending execution, and\s+absence block merge'
    }
}

Describe 'Solution-owned settings naming contract' {
    BeforeAll {
        $ErrorActionPreference = 'Stop'
        $repositoryRoot = Split-Path -Path $PSScriptRoot -Parent
        $script:documentationRoot = [IO.Path]::Combine($repositoryRoot, 'src', 'docs')
        $script:namingPath = [IO.Path]::Combine($documentationRoot, 'Coding-Standards', 'Naming.md')
        $script:naming = [IO.File]::ReadAllText($namingPath)
        $script:settingsRule = [regex]::Match(
            $naming,
            '(?s)## Solution settings files\r?\n(?<body>.*?)(?:\r?\n## |\z)'
        )
        $script:moduleSettings = [IO.File]::ReadAllText(
            [IO.Path]::Combine($documentationRoot, 'Initiatives', 'PSModule.md')
        )
    }

    It 'defines the conventional settings filename once in the Naming standard' {
        $settingsRule.Success | Should -BeTrue
        $settingsRule.Groups['body'].Value | Should -Match (
            'Solution-owned settings MUST use `<name>\.settings\.yml` as their conventional filename'
        )
        $owners = @(
            [IO.Directory]::EnumerateFiles($documentationRoot, '*.md', [IO.SearchOption]::AllDirectories) |
                Where-Object { [IO.File]::ReadAllText($_).Contains('`<name>.settings.yml`') }
        )

        $owners.Count | Should -Be 1
        $owners[0] | Should -BeExactly $namingPath
    }

    It 'excludes tool-owned filenames and YAML that is not solution settings' {
        $settingsRule.Groups['body'].Value | Should -Match (
            'Tool-mandated manifests, lockfiles, workflow filenames'
        )
        $settingsRule.Groups['body'].Value | Should -Match (
            'YAML files that are not solution-owned settings'
        )
    }

    It 'leaves the settings directory with the owning solution' {
        $settingsRule.Groups['body'].Value | Should -Match (
            'Each solution documents its settings location'
        )
        $settingsRule.Groups['body'].Value | Should -Match 'does not impose a shared directory'
    }

    It 'preserves supported explicit custom paths instead of imposing a runtime restriction' {
        $settingsRule.Groups['body'].Value | Should -Match 'documented explicit path override'
        $settingsRule.Groups['body'].Value | Should -Match (
            'does not remove that input or restrict otherwise supported custom paths'
        )
    }

    It 'links <Directory>/<File> to the one naming rule' -ForEach @(
        @{ Directory = @('Coding-Standards'); File = 'YAML.md' }
        @{ Directory = @('Ways-of-Working'); File = 'Repository-Standard.md' }
        @{ Directory = @('Capabilities', 'release-management'); File = 'design.md' }
        @{ Directory = @('Initiatives'); File = 'PSModule.md' }
    ) {
        $segments = [string[]] (@($documentationRoot) + $Directory + @($File))
        $guidance = [IO.File]::ReadAllText([IO.Path]::Combine($segments))

        $guidance | Should -Match 'Naming\.md#solution-settings-files'
        $guidance | Should -Not -Match ([regex]::Escape('`<name>.settings.yml`'))
    }

    It 'retains PSModule.yml through SettingsPath for module release settings' {
        $moduleSettings | Should -Match (
            'supported settings default is `\.github/PSModule\.yml`, through `SettingsPath`'
        )
        $moduleSettings | Should -Match 'including module release settings'
        $moduleSettings | Should -Match (
            'do not need a separate `\.github/release\.settings\.yml` file'
        )
        $moduleSettings | Should -Not -Match '(?i)psmodule\.settings\.yml'
    }

    It 'links the module compatibility boundary from <Directory>/<File>' -ForEach @(
        @{ Directory = @('Ways-of-Working'); File = 'Repository-Standard.md' }
        @{ Directory = @('Capabilities', 'release-management'); File = 'design.md' }
    ) {
        $segments = [string[]] (@($documentationRoot) + $Directory + @($File))
        $guidance = [IO.File]::ReadAllText([IO.Path]::Combine($segments))

        $guidance | Should -Match 'Initiatives/PSModule\.md#module-settings'
    }

    It 'distinguishes the release conventional filename from an implemented reader or renamed input' {
        $path = [IO.Path]::Combine($documentationRoot, 'Capabilities', 'release-management', 'design.md')
        $guidance = [IO.File]::ReadAllText($path)

        $guidance | Should -Match '`ConfigurationFile`'
        $guidance | Should -Match 'does not implement a reader or rename its public input'
        $guidance | Should -Match 'supported explicit custom paths'
        $guidance | Should -Not -Match 'auto-release\.yml|release\.config\.yml'
    }

    It 'points module settings to the verified canonical framework references' {
        $moduleSettings | Should -Match 'https://psmodule\.io/Process-PSModule/reference/workflow-inputs/'
        $moduleSettings | Should -Match 'https://psmodule\.io/Process-PSModule/reference/settings/'
    }

    It 'retains the VS Code template settings interface as a documented naming exception' {
        $path = [IO.Path]::Combine(
            $documentationRoot, 'Capabilities', 'vscode-extension-framework', 'design.md'
        )
        $guidance = [IO.File]::ReadAllText($path)

        $guidance | Should -Match (
            '`\.github/vscode-extension\.yml` is the documented template settings interface'
        )
        $guidance | Should -Match 'Naming\.md#solution-settings-files'
        $guidance | Should -Match 'supported naming exception'
        $guidance | Should -Match 'does not change this interface or its settings keys'
        $guidance | Should -Match 'a verified reader and a separate template/caller migration'
        $guidance | Should -Not -Match 'vscode-extension\.settings\.yml'
    }
}

Describe 'Repository PR-template-file policy' {
    BeforeAll {
        $ErrorActionPreference = 'Stop'
        $script:repositoryRoot = Split-Path -Path $PSScriptRoot -Parent
        $policyPath = [IO.Path]::Combine(
            $repositoryRoot, 'src', 'docs', 'Ways-of-Working', 'Repository-Standard.md'
        )
        $script:repositoryStandard = [IO.File]::ReadAllText($policyPath)
        $script:templatePathPattern = '(^|/)pull_request_template([./]|$)'
        $script:trackedFiles = @(& git --no-pager -C $repositoryRoot ls-files)
        if ($LASTEXITCODE -ne 0 -or $trackedFiles.Count -eq 0) {
            throw 'Could not inspect tracked source files for the repository file policy.'
        }
    }

    It 'keeps the authoritative no-file rule in Repository Standard' {
        $repositoryStandard | Should -Match '### No PR-template files'
        $repositoryStandard | Should -Match 'GitHub PR-template files MUST NOT'
    }

    It 'links the file policy from <File>' -ForEach @(
        @{ Directory = @('Ways-of-Working'); File = 'Organization-Standard.md' }
        @{ Directory = @('Capabilities', 'repository-governance'); File = 'design.md' }
    ) {
        $segments = [string[]] (@($repositoryRoot, 'src', 'docs') + $Directory + @($File))
        $path = [IO.Path]::Combine($segments)
        $guidance = [IO.File]::ReadAllText($path)

        $guidance | Should -Match 'Repository-Standard\.md#no-pr-template-files'
        $guidance | Should -Not -Match '(?im)^\|\s*`\.github/pull_request_template\.md`\s*\|'
    }

    It 'keeps repository-specific contribution instructions and canonical record guidance' {
        $path = [IO.Path]::Combine($repositoryRoot, '.github', 'CONTRIBUTING.md')
        $contribution = [IO.File]::ReadAllText($path)

        $contribution | Should -Match 'PR-Format/#complete-description-example'
        $contribution | Should -Not -Match 'pull_request_template\.md'
        $contribution | Should -Match 'Invoke-PesterSuite\.ps1'
        $contribution | Should -Match 'Test-DocumentationLink\.ps1'
    }

    It 'contains no tracked PR-template file or file-set directory' {
        $templateFiles = @(
            $trackedFiles | Where-Object { $_ -match $templatePathPattern }
        )

        $templateFiles.Count | Should -Be 0
    }

    It 'distinguishes the source path <Path> from unaffected guidance' -ForEach @(
        @{ Path = 'PULL_REQUEST_TEMPLATE.md'; IsPrTemplate = $true }
        @{ Path = '.github/pull_request_template.txt'; IsPrTemplate = $true }
        @{ Path = '.github/PULL_REQUEST_TEMPLATE/change.md'; IsPrTemplate = $true }
        @{ Path = '.github/ISSUE_TEMPLATE/feature.yml'; IsPrTemplate = $false }
        @{ Path = 'src/docs/Ways-of-Working/PR-Format.md'; IsPrTemplate = $false }
    ) {
        ($Path -match $templatePathPattern) | Should -Be $IsPrTemplate
    }
}
