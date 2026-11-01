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
