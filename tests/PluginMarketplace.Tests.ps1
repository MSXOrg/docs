#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*' }

Describe 'Copilot plugin marketplace' {
    BeforeAll {
        $script:repositoryRoot = Split-Path -Parent $PSScriptRoot
        $marketplacePath = Join-Path $script:repositoryRoot '.github/plugin/marketplace.json'
        $script:marketplace = Get-Content -LiteralPath $marketplacePath -Raw | ConvertFrom-Json
    }

    It 'uses unique plugin names' {
        $names = @($marketplace.plugins.name)

        @($names | Sort-Object -Unique).Count | Should -Be $names.Count
    }

    It 'resolves every plugin source' {
        foreach ($plugin in $marketplace.plugins) {
            $pluginRoot = Join-Path $repositoryRoot $plugin.source

            Test-Path -LiteralPath $pluginRoot -PathType Container | Should -BeTrue
            Test-Path -LiteralPath (Join-Path $pluginRoot 'plugin.json') -PathType Leaf |
                Should -BeTrue
        }
    }

    It 'keeps marketplace metadata aligned with each plugin manifest' {
        foreach ($plugin in $marketplace.plugins) {
            $pluginRoot = Join-Path $repositoryRoot $plugin.source
            $manifest = Get-Content -LiteralPath (Join-Path $pluginRoot 'plugin.json') -Raw |
                ConvertFrom-Json

            $manifest.'$schema' |
                Should -BeExactly 'https://agent-plugins.org/schemas/1.0.0/plugin.schema.json'
            $manifest.name | Should -BeExactly $plugin.name
            $manifest.version | Should -BeExactly $plugin.version
        }
    }

    It 'contains valid Agent Skills in every plugin' {
        foreach ($plugin in $marketplace.plugins) {
            $pluginRoot = Join-Path $repositoryRoot $plugin.source
            $skillDirectories = @(
                Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'skills') -Directory
            )

            $skillDirectories.Count | Should -BeGreaterThan 0
            foreach ($skillDirectory in $skillDirectories) {
                $skillPath = Join-Path $skillDirectory.FullName 'SKILL.md'
                Test-Path -LiteralPath $skillPath -PathType Leaf | Should -BeTrue

                $content = Get-Content -LiteralPath $skillPath -Raw
                $frontmatter = [regex]::Match(
                    $content,
                    '\A---\r?\n(?<yaml>.*?)\r?\n---(?:\r?\n|\z)',
                    [System.Text.RegularExpressions.RegexOptions]::Singleline
                )
                $frontmatter.Success | Should -BeTrue

                $name = [regex]::Match(
                    $frontmatter.Groups['yaml'].Value,
                    '(?m)^name: (?<value>[^\r\n]+)\r?$'
                )
                $description = [regex]::Match(
                    $frontmatter.Groups['yaml'].Value,
                    '(?m)^description: (?<value>[^\r\n]+)\r?$'
                )

                $name.Success | Should -BeTrue
                $description.Success | Should -BeTrue
                $name.Groups['value'].Value | Should -BeExactly $skillDirectory.Name
                $name.Groups['value'].Value |
                    Should -Match '^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$'
                $description.Groups['value'].Value.Length | Should -BeLessOrEqual 1024
            }
        }
    }
}
