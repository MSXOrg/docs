#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

Describe 'PR Format authoring contract' {
    BeforeAll {
        $ErrorActionPreference = 'Stop'
        $repositoryRoot = Split-Path -Path $PSScriptRoot -Parent
        $documentationRoot = [IO.Path]::Combine($repositoryRoot, 'src', 'docs', 'Ways-of-Working')
        $script:format = [IO.File]::ReadAllText([IO.Path]::Combine($documentationRoot, 'PR-Format.md'))
        $script:template = [regex]::Match(
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

    It 'retains one complete scaffold with one boundary and five ordered classifiers' {
        $template.Success | Should -BeTrue
        $body = $template.Groups['body'].Value
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
        $template.Success | Should -BeTrue
        $prompt = [regex]::Escape('{{ Publication-baseline evidence:')

        [regex]::Matches($template.Groups['body'].Value, $prompt).Count | Should -Be 5
    }
}
