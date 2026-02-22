# brainstorm-multi-spec-handoff

Created: 2026-02-22

## Problem Statement

The current brainstorm output assumes exactly one follow-up spec and ends with a command suggestion (`openclose create <name>`). That does not match real agent-led behavior, where a brainstorm may naturally split into multiple specs and the user usually continues the conversation instead of running a CLI command manually.

This change updates the brainstorm contract so the output can recommend one or more specs when appropriate and provide transition guidance that matches conversational agent workflows.

## Requirements

1. The brainstorm summary schema MUST replace singular `## Proposed Spec Name` with plural `## Proposed Specs`.
2. Each proposed spec entry MUST include a kebab-case spec name and a short scope rationale.
3. The brainstorming flow MUST support recommending one or more specs depending on scope complexity.
4. The flow SHOULD recommend multiple specs when separable workstreams would reduce implementation risk or improve sequencing.
5. The `## Transition to Spec` section MUST NOT suggest `openclose create <spec-name>` as the primary next step.
6. The transition guidance MUST include conversational next-step options, such as asking the agent to implement a selected spec by name or continuing refinement in chat.
7. Template updates MUST be applied to the shared source prompt and generated command artifacts so behavior stays consistent.
8. The markdown output SHOULD remain deterministic and human-readable so saved brainstorms are still reusable by future tooling.

## Technical Notes

- Update `prompts/brainstorm.md` as the source of truth for summary schema and transition guidance.
- Regenerate/sync `.opencode/commands/oc-brainstorm.md` through existing command-generation flow to keep artifacts aligned.
- Keep section ordering stable to avoid churn in saved brainstorm files.
- Prefer transition text that is agent-first, for example: "Say: implement spec `<name>`" and "Continue discussion to refine scope".
- Ensure examples demonstrate both single-spec and multi-spec outputs.

## Related Links

- `prompts/brainstorm.md`
- `.opencode/commands/oc-brainstorm.md`
- `.openclose/specs/brainstorm-subcommand/PRD.md`
