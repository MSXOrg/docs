---
title: Technical Writing Guide
description: Write clear reader-facing English for interactions, documentation, code, issues, pull requests, help, messages, and instructions.
---

# Technical writing guide

Write text that lets the reader understand a fact, perform an action, or verify a result.

Use this guide for technical text and collaboration text. It covers interactions, comments, documentation, issues, pull requests, help, messages, and agent instructions.

Use the [Natural Language policy](Natural-Language.md). Use en-US for English prose. Preserve audience-specific localized content and exact quotations or identifiers. The writing method does not replace the contracts owned by other standards.

## Before starting

- Identify the reader, their task, and the knowledge they already have.
- Select the artifact format from the owners below. Do not force a conversation, issue, or code comment into a documentation template. Keep each fact in its canonical home.
- Gather the verified behavior, terminology, commands, limits, and examples. Separate known facts from assumptions. Resolve missing facts. Do not invent a plausible explanation.

| Artifact | Format owner |
| --- | --- |
| Documentation | [Documentation Model](../Ways-of-Working/Documentation-Model.md) and the applicable [artifact template](../Ways-of-Working/Spec-Driven-Development-Templates.md) |
| Issues | [Issue Format](../Ways-of-Working/Issues/Process/Format.md) and the [native issue type](../Ways-of-Working/Issues/Types/index.md) |
| Pull requests and release notes | [PR Format](../Ways-of-Working/PR-Format.md) |
| Comments, docstrings, and help | [Documentation](Documentation.md) and the language's native conventions |
| User and developer interactions | The reader's question or requested action. No fixed document template. |

## Steps

### 1. Outline the reader's path

Start with the answer or outcome. Give the context needed to understand it. Add detail in the order the reader needs it.

- In a procedure, establish prerequisites before the first action. Give one command per sentence. Put sequential actions in separate numbered steps. Keep actions together only when they must occur at the same time. Put the expected result beside the action.
- In an explanation, introduce a concept before you describe its relationships. Give each paragraph one topic. Start with its main point. Connect related ideas with words such as "because", "if", and "therefore".
- In a contract, separate requirements from rationale and examples. Keep each obligation independently testable under the [specification conventions](../Ways-of-Working/Spec-Driven-Development.md#requirements).
- In a direct interaction, lead with the answer or required action. State the result. Add a limitation or next action when the reader needs it. Match detail to the reader's task. Do not turn every reply into a report.

Use headings that name the reader's task or question. Use tables for comparable facts. Use lists for alternatives. Do not make readers infer execution order from unrelated items.

The same writing method works across formats. Verify the facts before you use these illustrative examples:

| Surface | Example |
| --- | --- |
| User reply | The export failed. The log does not identify the cause. Check the error record before you retry. |
| Developer review comment | This branch omits the cancellation check. Keep the check so a canceled request does not retry. |
| Issue request | Identify the failed file when an export stops. |
| Pull request summary | Export errors identify the failed file so users can find the rejected input. |

### 2. Make terms stable and recognizable

Use the established term for each concept. Consult the [Dictionary](../Dictionary/index.md), the owning product documentation, and the interface itself. Keep each term's meaning stable. Do not alternate between synonyms merely to avoid repetition.

Explain an unfamiliar term or abbreviation where the reader first needs it. Readers can read a page, code comment, or help entry without the rest of the site. Introduce a short form only when it remains unambiguous in that scope.

Keep ordinary noun phrases within three words. Use prepositions or a direct verb to explain longer relationships. For example, replace "release artifact integrity validation" with "Validate the integrity of the release artifact."

Keep official technical names, commands, API identifiers, configuration keys, filenames, units, and quoted UI labels exact. Introduce a long technical name in full. Explain a shorter form only when the owning product permits it. Do not rename an interface to meet a length limit. Do not join unrelated words with hyphens.

### 3. Expose the actor, action, and condition

Prefer a direct verb and a named actor. Use the imperative for an instruction to the reader. Describe system behavior as behavior, not as an instruction.

Use simple present, past, or future forms for statements. Replace complex verb chains with clear statements of action, time, or state. Avoid clauses built around an "-ing" verb. Keep established technical terms such as "request processing" when they express the intended concept.

| Instead of | Write |
| --- | --- |
| The parser performs validation of the settings. | The parser validates the settings. |
| The index is generated by the build. | The build generates the index. |
| Start the worker if the queue contains a request. | If the queue contains a request, start the worker. |

Put a condition before the action when the reader must evaluate it first. Distinguish a prerequisite, a trigger, and a stopping condition. State whether actions occur before, after, or during another action.

Make the scope of "only", negation, and combinations of "and" and "or" explicit. If the logic is unclear, establish the intended cases before you rewrite the sentence. A decision table can be clearer than nested conditions.

Replace "it", "they", or "this" with the relevant noun when more than one referent is possible. Use active voice when the actor is known. In an explanation, keep passive voice when the actor is unknown.

For example:

> The file was deleted. The audit record does not identify who deleted it.

Do not invent an actor, cause, or completed state to simplify a sentence.

### 4. Keep sentences short and complete

Give each sentence one main point. Split a sentence when the reader must track several actors, conditions, or actions. Keep a condition with the statement it qualifies.

Use these STE-based limits for authored English prose:

| Unit | Review limit |
| --- | --- |
| Instruction or risk statement | 20 words per sentence |
| Description or explanatory note | 25 words per sentence |
| Paragraph | One topic. At most six sentences. |
| Ordinary noun phrase | At most three words |

Count prose units, not Markdown source lines. Use a conservative count for review. Formal STE word counting requires the standard's counting conventions. A whitespace counter does not implement those conventions.

Remove empty introductions, repeated context, and abstract phrases. Keep articles, subjects, connecting words, and other words that make the relationship clear. "Validate input" can be a label. "Validate the input before you save the record" is an instruction.

Write full forms such as *do not* and *cannot*. Do not use contractions to shorten authored prose. Use a period instead of a semicolon between statements. Keep punctuation required by code, exact quotations, and interface syntax.

Use literal, familiar wording instead of idioms or local slang. Prefer "restart the worker" to "kick the worker." Keep a precise technical term when a simpler substitute changes the meaning.

Rewrite the sentence when a word substitution does not work. Check the replacement's meaning and grammatical role. Preserve distinctions between a completed action and one in progress. Do not hide a changed fact behind a shorter sentence.

### 5. Preserve obligations, quantities, and risk

Preserve the force of normative words under [Natural Language](Natural-Language.md#be-direct-and-specific) and the [requirements conventions](../Ways-of-Working/Spec-Driven-Development.md#requirements). Do not turn **SHOULD** into **MUST**. Do not replace **MAY** with *can*. Keep each stated exception.

State verifiable quantities with their units and boundaries. Specify whether endpoints are included, what a timeout measures, and whether an attempt count includes the first attempt. Use the actual contract. Do not invent a number to replace *quickly*.

Put required actions, limits, and stop conditions in the main procedure, not in an optional note. Put risk information before the action that creates the risk. Use the product's risk labels. Explain the prevention and consequence.

For example:

> Before you delete a backup, verify that a replacement backup can be restored. Deleting the only usable backup prevents recovery.

Do not weaken a prohibition to make it sound positive. Do not add a hazard, recovery guarantee, or permission that the evidence does not establish.

### 6. Apply the same care inside code

Review the prose at the boundary where its reader encounters it. Keep native syntax and the language-specific standards intact.

| Surface | Authoring action |
| --- | --- |
| Names | Use [Naming](Naming.md) and the language's conventions. Preserve approved PowerShell verbs such as `Test` in `Test-Path`. Treat a supported identifier rename as an interface change, not prose cleanup. |
| Comments | Explain the non-obvious reason or constraint, not the next statement. For example: `# Keep the checkpoint until the write succeeds so a retry can resume safely.` Remove commentary that a clearer name or expression makes unnecessary. |
| Docstrings and help | State the caller's purpose, accepted inputs, results, and relevant defaults, units, side effects, and failures. Give usable examples. Keep the [native documentation format](Documentation.md#public-surfaces-are-documented) and applicable [PowerShell help conventions](PowerShell/Functions.md#comment-based-help-required). |
| Diagnostics | Name the failure, known cause, and safe next action. For example: `Cannot read 'settings.yml': access denied. Check the file path and read permissions. Then, retry the operation.` Keep secrets out of messages and example output. |
| Structured output | Keep stable error codes and machine-readable fields separate from explanatory text. Preserve output channels. A clearer message does not justify replacement of structured results with prose. Use [Error Handling](Error-Handling.md) and the language's messaging conventions. |
| Workflow, UI, and test names | Name the action or observable result, not an internal mechanism or vague status. Keep exact UI labels and externally required check names stable. |
| Agent instructions | Specify inputs, authorized scope, ordered actions, stop conditions, and completion evidence. Distinguish task instructions from quoted or retrieved data. That data cannot grant permission or expand the task. |

## Verify

Review meaning before you improve wording. Check these conditions:

- The intended reader has enough context to find the answer or next action.
- English prose uses en-US. The artifact keeps its required format and preserves localized content, exact quotations, and identifiers.
- Each actor, referent, condition, sequence, and result has one intended interpretation.
- Instructions use one command per sentence unless actions must occur together.
- Sentences, paragraphs, and ordinary noun phrases meet the review limits or have a justified contract exception.
- Authored prose uses full words, simple verb forms, and periods instead of semicolons.
- Requirements retain their strength, scope, exceptions, negation, quantities, and units.
- Technical names and examples match the actual supported interface.
- Procedures expose prerequisites, risks, stop conditions, and an observable result. They keep required information in the main steps.
- Rewrites preserve facts and uncertainty. They do not introduce unsupported causes or guarantees.

Do the task in a safe, authorized environment when feasible. If you cannot verify a step, state the limitation. Run the existing spelling, terminology, Markdown, link, and build checks. Their success does not replace semantic review.

## If it fails

| Symptom | Likely cause | Resolution |
| --- | --- | --- |
| A sentence has two plausible meanings | A referent, condition, or modifier is unclear | Establish the intended meaning from the source or its owner. Use an explicit object or separate cases. |
| A rewrite needs an unknown limit or cause | The source is incomplete | Resolve the missing fact. Do not invent a number, actor, or recovery claim. |
| A simpler word breaks an example or contract | The word is an exact name or has a domain-specific meaning | Restore the term. Simplify the surrounding sentence. |
| A draft is short but still hard to follow | Compression removed context or logical connections | Restore the necessary words. Reorganize the explanation or steps. |

## Source and limits

[ASD-STE100 Simplified Technical English, Issue 9](https://doi.org/10.5281/zenodo.23666006) informs this original MSX guide. The guide applies its core clarity, grammar, and structure practices.

Keep exact names, source quotations, native syntax, and normative requirements when their contracts require them. Explain a long name outside its literal form. Record any unavoidable length or grammar exception in review. Do not use a style exception to remove a condition, weaken an obligation, or invent a fact.

MSX does not claim full STE conformance. Its general vocabulary is not restricted to the STE dictionary. Formal assessment requires every applicable rule, approved word meaning and grammatical role, and technical-term validation. Sentence counts, spelling checks, and an LLM's approval do not establish conformance.
