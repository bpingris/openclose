<user-request>
$ARGUMENTS
</user-request>

Run a guided brainstorming session for the user's feature idea.

MVP scope decision:
- Use this agent command workflow as the primary entry point.
- Native `openclose brainstorm` CLI behavior is deferred for now.
- Keep outputs compatible with a future CLI command by following the shared markdown schema below.

Session goals:
1. Narrow ambiguous user ideas into concrete, implementation-relevant decisions.
2. Identify missing details before spec creation starts.
3. Produce a normalized summary that can directly seed one or more implementation-ready specs.

Step 1: Start with the seed idea

- If the user provided arguments, treat them as the feature seed.
- If no seed is provided, ask for a short feature idea first.

Step 2: Run iterative clarification

- Ask focused follow-up questions in small batches (1-3 at a time).
- Prioritize questions that reduce ambiguity fastest.
- Cover at least: goals, capabilities, constraints, non-goals, acceptance signals, risks, and open questions.
- Decide whether the brainstorm should result in one spec or multiple specs based on scope boundaries.
- Keep the conversation collaborative and concise.
- If the user response is vague, ask one targeted follow-up rather than broad repeated prompts.

Step 3: Enforce completion rules

A session is implementation-ready only when all of these are present:
- clear problem statement and target outcome
- concrete capabilities or behaviors
- explicit constraints and non-goals
- acceptance signals (how success will be judged)
- known risks and open questions

If any required area is missing, continue clarification until complete.

Step 4: Produce normalized brainstorm summary

Output a final structured summary using this exact section shape:

```markdown
# Brainstorm: <feature-title>

Created: <YYYY-MM-DD>
Status: ready-for-spec

## Problem
<1-3 short paragraphs>

## Goals
- ...

## Capabilities
- ...

## Constraints
- ...

## Non-Goals
- ...

## Acceptance Signals
- ...

## Risks
- ...

## Open Questions
- ...

## Proposed Specs
1. `kebab-case-name` - <one-line rationale for this scope>
2. `optional-second-spec` - <one-line rationale, include only if needed>

## Transition to Spec
- If the user wants implementation now, suggest saying: `implement spec <kebab-case-name>`
- If multiple specs are proposed, present an ordered list and ask which spec to implement first.
- If scope is still unclear, continue the conversation to refine or split specs.
```

Step 5: Optional persistence

- Ask whether the user wants the brainstorm saved.
- If yes, save to: `.openclose/brainstorm/<session-slug>-<timestamp>.md`
- Ensure `.openclose/brainstorm/` exists before writing.
- Write the full markdown content in one pass to avoid partial files.
- On write failure, report a clear actionable error (path + reason) and keep the in-chat summary available.

Important guardrails:
- Do not start implementation during brainstorming.
- Do not create or modify a spec unless the user explicitly asks.
- Keep brainstorm output deterministic and human-readable so future tools can reuse it.
