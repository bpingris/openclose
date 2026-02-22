# brainstorm-subcommand

Created: 2026-02-22

## Problem Statement

Users often start with an incomplete idea (for example, "a profile page where users can update email/password") and need guided discussion before they can write a strong spec.
The current workflow jumps too quickly from idea to implementation tasks, which causes missing requirements, unclear boundaries, and avoidable back-and-forth.

The team is also undecided about where brainstorming should live:
- as an `openclose` CLI command (`openclose brainstorm`), or
- as an agent command template (`/oc-brainstorm ...`) that orchestrates a guided conversation.

This spec defines how brainstorming should work end-to-end, including decision criteria for command surface, expected outputs, persistence behavior, and error handling.

## Requirements

1. The solution MUST support a brainstorming entry point that can be invoked as `/oc-brainstorm <feature-idea>` from the coding agent command set.
2. The `/oc-brainstorm` template MUST instruct the agent to run a structured clarification loop and ask focused follow-up questions before producing output.
3. The clarification loop MUST capture at least: user goal, core capabilities, constraints, non-goals, acceptance signals, risks, and unresolved questions.
4. The brainstorm result MUST end with a structured summary that is ready to seed `openclose create` content.
5. The implementation plan MUST explicitly document whether MVP is agent-command-only, CLI-command-only, or hybrid, and MUST justify that decision.
6. The design SHOULD define a common markdown schema for persisted brainstorms so both agent workflows and potential CLI workflows can reuse it.
7. Persisted brainstorms MAY be written under `.openclose/brainstorm/<session-slug>-<timestamp>.md` when the user requests saving.
8. If persistence is enabled, the system MUST create required directories, MUST avoid partial/corrupt files, and MUST print actionable write-failure errors.
9. If a native `openclose brainstorm` command is included, it SHOULD align with the same schema and question structure used by `/oc-brainstorm`.

## MVP Decision

- Selected scope: **agent-command-only** for MVP (`/oc-brainstorm`).
- Rationale: this delivers immediate value with lower implementation risk while preserving a reusable schema that keeps a future CLI subcommand straightforward.
- Deferred item: native `openclose brainstorm` CLI command, pending validation of the prompt workflow and persisted artifact shape.

## Technical Notes

- Add a new prompt template file for brainstorming (for example `prompts/brainstorm.md`) and wire a generated `oc-brainstorm` command into agent command generation.
- Reuse existing command-generation mechanisms so `init` and `update` can provision or refresh brainstorm command files.
- Define a stable markdown output contract for brainstorm artifacts, including metadata and summary blocks.
- If CLI support is implemented, route it through `main.odin` and keep behavior compatible with the same output contract.
- Keep question flow deterministic and concise so sessions remain predictable for users and coding agents.

## Related Links

- `.openclose/AGENTS.md`
- Existing command implementations in `src/create.odin`, `src/validate.odin`, `src/summary.odin`, and `src/update.odin`
