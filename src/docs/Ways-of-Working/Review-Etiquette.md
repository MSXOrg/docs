---
title: Review Etiquette
description: Tone, scope, severity, and how to disagree well.
---

# Review Etiquette

Reviewers and authors use evidence, explicit severity, and scoped feedback to resolve concerns and keep reviews focused.

## For the Reviewer

### What to assess

Consider each of the following dimensions when reviewing a PR:

- **Functional** — Does the code meet the stated needs?
- **Reliability** — Is there confidence that the code will run failure-free?
- **Performance** — Is the code as efficient as it can be?
- **Usability** — Consider the users of the service or product being provided; is the experience of high quality with this change?
- **Security** — Does this change improve the security posture of the service or product? Does it worsen it?
- **Maintainability** — Is the architecture good for future maintenance?
- **Standards** — Is the code meeting coding standards for the project and language?

### Stay in scope

The PR delivers one Task or Bug. Suggestions that go beyond that delivery leaf are **new issues**, not blocking review comments. File the follow-up and link it from the comment.

### One concern per comment

Each thread addresses one concern.
Keep unrelated findings in separate threads so each can be resolved independently.

### Be clear about severity

Use explicit prefixes so the author knows what is blocking:

- `Blocking:` — must be addressed before merge.
- `Question:` — needs clarification; may or may not lead to a change.
- `Suggestion:` — improvement worth considering; the author can take or leave it with reasoning.
- `Nit:` — small style or preference issue; the author can dismiss freely.

### Reason from evidence

Cite the docs, the linter rule, the security advisory, or a recorded decision in the closing delivery issue.
"It feels off" does not identify a problem or required change.
"This contradicts the decision recorded in Owner/Repo#N" identifies evidence the author can inspect.

### Don't review your own PR publicly

Self-review is fine and encouraged — but it goes to the terminal as a pre-flight report, not as GitHub comments on your own PR. (And by GitHub rules, you cannot `Request changes` on your own PR — submit a `Comment` review and use a blocking label if needed.)

### Approving is co-signing

An approving review records the reviewer's acceptance of the change.
Approve only after all blocking concerns are resolved.
The required-approval ruleset requires a reviewer identity separate from the author and from the built-in Actions identity.
An agent may approve when it uses that separate identity and did not author the change.
See [Branching and Merging § Who approves](Branching-and-Merging.md#who-approves) for the mechanics.

### Distinguish bots from humans

Bots report findings from linters and security scanners.
Human comments can add context that automation does not have.
Read both carefully; do not dismiss comments in bulk.

## For the Responder (the author)

### Reply before resolving

Every resolved thread has a reply that explains the action.
State what was fixed, why a finding was dismissed, or which issue owns the follow-up.
Do not resolve threads in bulk without replies.

### Forward progress over discussion

A valid concern that needs deep design discussion becomes a follow-up issue and a resolved thread, not an open thread that blocks the PR. Open threads are blockers — minimize them.

### Don't expand the PR

An out-of-scope suggestion remains out of scope.
Reply, file the follow-up issue, link it, and resolve the thread.
Do not include the suggestion only to satisfy the reviewer.

### Propagate fixes

If the same problem occurs in several places, fix every occurrence consistently.
A partial fix that leaves identical problems in similar files is incomplete.

### Test coverage gaps

When a reviewer finds a real bug that existing tests missed, add or correct a test that covers it.
The fix is incomplete without that coverage.
A source-only fix leaves the regression without test coverage.

### Don't bulk-dismiss bot feedback

Address linter and security findings, or suppress them with explicit justification.
Do not dismiss a finding without a reason.

## For both sides

### Tone

- Use impersonal language where possible. Prefer "This change does X" to "You did X".
- Do not use sarcasm. Readers may not share the same language or local context.
- Assume good intent. Both reviewer and author work toward a correct result.

### Disagreements

When the Reviewer and Responder genuinely disagree:

1. Re-state the disagreement plainly in the thread.
2. Reference the relevant doc, decision, or principle.
3. If the disagreement remains, escalate to a human maintainer or file a discussion issue.
   Do not repeat the same discussion in the thread.

### Converge, don't diverge

Every change in a review round should move the PR closer to merge.
Avoid introducing new code that needs another review round.
If a fix introduces a new design choice, explain it in the response.
Let the Reviewer accept that choice before making further changes.

### Stale comments

If the code referenced by a comment has changed, state that in the reply.
Do not leave stale comments as open threads without a response.

## What this is not

This is not a process gate.
It defines **shared etiquette** for professional, respectful reviews by humans and agents.
