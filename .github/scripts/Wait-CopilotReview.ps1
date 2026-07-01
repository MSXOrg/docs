#Requires -Version 7.0

<#
    .SYNOPSIS
    Request a Copilot review if needed, wait for it, and report whether Copilot left new comments.

    .DESCRIPTION
    Drives one round of the Copilot review loop from the
    [Contribution Workflow](../../src/docs/Ways-of-Working/Contribution-Workflow.md).
    It:

    1. Ensures a Copilot review is requested. It checks whether Copilot is
       already processing a request (from the timeline - the org ruleset is not
       relied upon, and reviewRequests empties almost immediately) and requests
       one only if not (unless -SkipRequest).
    2. Polls until Copilot submits a review newer than the request, or the
       timeout elapses.
    3. Reports the review state and any inline comments Copilot added this round,
       and sets an exit code so a caller can branch on the result:

         0  clean round - Copilot requested no changes and left no new inline comments
         2  Copilot has feedback - a new inline comment or a changes-requested review
         1  no review arrived before the timeout

    Requires the GitHub CLI (gh) authenticated for the target host.

    .EXAMPLE
    ./.github/scripts/Wait-CopilotReview.ps1 -Repository MSXOrg/docs -PullRequest 1

    Requests a Copilot review on PR 1, waits for it, and reports the outcome.

    .EXAMPLE
    ./.github/scripts/Wait-CopilotReview.ps1 -Repository MSXOrg/docs -PullRequest 1 -SkipRequest

    Waits for a review already requested elsewhere, without re-requesting one.

    .INPUTS
    None. This script does not accept pipeline input.

    .OUTPUTS
    [pscustomobject] with Repository, PullRequest, ReviewState, SubmittedAt,
    NewCommentCount, NewComments, and Blessed.

    .NOTES
    Note the login asymmetry: the submitted review's author login is
    'copilot-pull-request-reviewer', while inline comments are attributed to
    'Copilot'.
#>

[OutputType([pscustomobject])]
[CmdletBinding(SupportsShouldProcess)]
param(
    # Target repository in 'owner/name' form, e.g. 'MSXOrg/docs'.
    [Parameter(Mandatory)]
    [ValidatePattern('^[^/]+/[^/]+$')]
    [string] $Repository,

    # Pull request number.
    [Parameter(Mandatory)]
    [ValidateRange(1, [int]::MaxValue)]
    [int] $PullRequest,

    # GitHub host for gh; sets GH_HOST for the duration of the run.
    [Parameter()]
    [string] $GitHubHost = 'github.com',

    # How long to wait for Copilot's review before giving up, in minutes.
    [Parameter()]
    [ValidateRange(1, 120)]
    [int] $TimeoutMinutes = 10,

    # Seconds between polls while waiting for the review.
    [Parameter()]
    [ValidateRange(5, 300)]
    [int] $PollIntervalSeconds = 20,

    # Poll for an already-requested review without requesting a new one.
    [Parameter()]
    [switch] $SkipRequest
)

$ErrorActionPreference = 'Stop'

#region Constants
# The reviewer bot's login on submitted reviews (inline comments show 'Copilot').
Set-Variable -Name ReviewerLogin -Value 'copilot-pull-request-reviewer' -Option ReadOnly
# The logins Copilot uses; the review bot posts inline comments as 'Copilot'.
Set-Variable -Name CopilotLogins -Value @('Copilot', 'copilot-pull-request-reviewer') -Option ReadOnly
# gh --jq filters, kept in variables so the gh calls stay within the line limit.
Set-Variable -Name TimelineFilter -Option ReadOnly -Value @'
.[] | select(.event=="review_requested" and (.requested_reviewer.login=="Copilot")) | .created_at
'@
Set-Variable -Name CommentFilter -Option ReadOnly -Value @'
.[] | {path, line, body, login: .user.login, createdAt: .created_at}
'@
#endregion Constants

# Preserve the caller's gh environment; $env: changes are process-wide, so
# GH_HOST / GH_PAGER are restored on the way out.
$previousGhHost = $env:GH_HOST
$previousGhPager = $env:GH_PAGER

try {
    $env:GH_HOST = $GitHubHost
    $env:GH_PAGER = ''

    if ($SkipRequest) {
        # Poll only - do not request. Look back over the whole timeout window so
        # an already-submitted or in-flight review is still eligible.
        Write-Verbose 'SkipRequest set - polling for an existing or in-flight Copilot review.'
        $since = [datetimeoffset]::UtcNow.AddMinutes(-$TimeoutMinutes)
    } else {
        # Ensure a review is requested. Do NOT rely on any org ruleset to
        # auto-request one. Copilot is 'processing' when there is a
        # review_requested for it with no Copilot review since. Use the timeline,
        # because reviewRequests empties almost immediately after the request.
        $requestedAt = gh api "repos/$Repository/issues/$PullRequest/timeline" --paginate --jq $TimelineFilter
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to read the timeline for $Repository#$PullRequest (gh exited $LASTEXITCODE)."
        }
        $lastRequestedAt = $requestedAt | Sort-Object | Select-Object -Last 1

        $reviewsJson = gh pr view $PullRequest --repo $Repository --json reviews
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to read reviews for $Repository#$PullRequest (gh exited $LASTEXITCODE)."
        }
        $lastReviewedAt = $reviewsJson | ConvertFrom-Json |
            Select-Object -ExpandProperty reviews |
            Where-Object { $_.author.login -eq $ReviewerLogin -and $_.submittedAt } |
            ForEach-Object { [datetimeoffset] $_.submittedAt } |
            Sort-Object |
            Select-Object -Last 1

        $processing = $lastRequestedAt -and
            ((-not $lastReviewedAt) -or ([datetimeoffset] $lastRequestedAt -gt $lastReviewedAt))

        if ($processing) {
            Write-Verbose "Copilot is already processing a review (requested $lastRequestedAt) - waiting for it."
            # Anchor just before the pending request so its review counts.
            $since = ([datetimeoffset] $lastRequestedAt).AddSeconds(-1)
        } elseif ($PSCmdlet.ShouldProcess("$Repository#$PullRequest", 'Request a Copilot review')) {
            Write-Verbose "No Copilot review in progress - requesting one on $Repository#$PullRequest ..."
            $null = gh pr edit $PullRequest --repo $Repository --add-reviewer '@copilot' 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to request a Copilot review (gh exited $LASTEXITCODE)."
            }
            Write-Verbose 'Requested a Copilot review.'
            # Anchor after the request so only a review from this round counts.
            $since = [datetimeoffset]::UtcNow
        } else {
            # -WhatIf: no request was made, so fall back to poll-only semantics
            # (as with -SkipRequest) rather than waiting for a review that will
            # never arrive. Look back over the window so an in-flight review counts.
            Write-Verbose 'WhatIf - no review requested; polling for an existing or in-flight review.'
            $since = [datetimeoffset]::UtcNow.AddMinutes(-$TimeoutMinutes)
        }
    }

    $deadline = [datetimeoffset]::UtcNow.AddMinutes($TimeoutMinutes)
    Write-Verbose "Waiting for a Copilot review (timeout ${TimeoutMinutes}m, every ${PollIntervalSeconds}s) ..."

    $review = $null
    while ([datetimeoffset]::UtcNow -lt $deadline) {
        $reviewsJson = gh pr view $PullRequest --repo $Repository --json reviews
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to read reviews for $Repository#$PullRequest (gh exited $LASTEXITCODE)."
        }
        $review = $reviewsJson | ConvertFrom-Json |
            Select-Object -ExpandProperty reviews |
            Where-Object {
                $_.author.login -eq $ReviewerLogin -and
                $_.submittedAt -and
                [datetimeoffset] $_.submittedAt -gt $since
            } |
            Sort-Object { [datetimeoffset] $_.submittedAt } |
            Select-Object -Last 1

        if ($review) {
            break
        }

        Start-Sleep -Seconds $PollIntervalSeconds
    }

    if (-not $review) {
        Write-Warning "No Copilot review arrived within $TimeoutMinutes minute(s)."
        exit 1
    }

    # Inline comments Copilot added in this round. Filter by author so human
    # comments are not miscounted, and paginate so nothing is missed on a busy
    # pull request.
    $commentsJson = gh api "repos/$Repository/pulls/$PullRequest/comments" --paginate --jq $CommentFilter
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to read review comments for $Repository#$PullRequest (gh exited $LASTEXITCODE)."
    }
    $newComments = @(
        $commentsJson |
            ForEach-Object { $_ | ConvertFrom-Json } |
            Where-Object { $_.login -in $CopilotLogins -and [datetimeoffset] $_.createdAt -gt $since } |
            ForEach-Object {
                [pscustomobject]@{
                    Path = $_.path
                    Line = $_.line
                    Body = $_.body
                }
            }
    )

    # Blessed only when Copilot left no new inline comments AND did not request
    # changes; a summary-only CHANGES_REQUESTED review has zero inline comments
    # but is not a clean pass.
    $blessed = $newComments.Count -eq 0 -and $review.state -ne 'CHANGES_REQUESTED'

    if ($blessed) {
        Write-Verbose 'Clean round - Copilot requested no changes and left no new inline comments.'
    } else {
        Write-Verbose "Copilot has feedback (state=$($review.state), new inline comments=$($newComments.Count))."
    }

    [pscustomobject]@{
        Repository      = $Repository
        PullRequest     = $PullRequest
        ReviewState     = $review.state
        SubmittedAt     = $review.submittedAt
        NewCommentCount = $newComments.Count
        NewComments     = $newComments
        Blessed         = $blessed
    }

    if ($blessed) {
        exit 0
    } else {
        exit 2
    }
} finally {
    if ($null -eq $previousGhHost) {
        Remove-Item -Path Env:\GH_HOST -ErrorAction SilentlyContinue
    } else {
        $env:GH_HOST = $previousGhHost
    }
    if ($null -eq $previousGhPager) {
        Remove-Item -Path Env:\GH_PAGER -ErrorAction SilentlyContinue
    } else {
        $env:GH_PAGER = $previousGhPager
    }
}
