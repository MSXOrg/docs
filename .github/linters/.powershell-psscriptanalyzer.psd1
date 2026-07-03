# PSScriptAnalyzer settings — the enforcement mechanism for the PowerShell coding
# standard (src/docs/Coding-Standards/PowerShell/index.md). The standard is the
# source of truth; every rule configured here is derived from it. Change a rule by
# changing the standard first, then reflect it here — never the other way around.
#
# super-linter discovers this file automatically as POWERSHELL_CONFIG_FILE
# (.powershell-psscriptanalyzer.psd1) under .github/linters.
@{
    # Run the full default rule set — approved verbs, singular nouns, alias bans,
    # $null-on-the-left comparisons, Invoke-Expression, unused variables, and the
    # rest — then tighten the formatting rules below to match the standard.
    IncludeDefaultRules = $true

    # Gate on errors and warnings; both map to rules the standard requires.
    Severity = @('Error', 'Warning')

    Rules = @{
        # One True Brace Style: opening brace on the statement line, closing brace
        # on its own line with no blank line before it. NewLineAfter stays false on
        # the close brace so else / elseif / catch / finally sit on the same line as
        # the preceding brace ("} else {"), as the standard requires.
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }
        PSPlaceCloseBrace = @{
            Enable = $true
            NewLineAfter = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore = $true
        }

        # Indent with four spaces, never tabs.
        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        }

        # One space around operators and after commas, and consistent brace and
        # parenthesis spacing.
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckSeparator = $true
        }
    }
}
