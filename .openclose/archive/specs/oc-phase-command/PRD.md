# oc-phase-command

Created: 2026-02-04

## Problem Statement

Agents currently lack a mechanism to implement a specific phase of a multi-phase spec in isolation. The existing workflow expects agents to implement full specs from start to finish, but users may want to have an agent implement just a single phase without continuing to subsequent phases.

## Requirements

- Create a new agent command file `.opencode/commands/oc-phase.md` that accepts a phase number as an argument
- The command should instruct the agent to implement only the specified phase
- The agent should NOT automatically continue to subsequent phases after completing the given phase
- The agent should NOT perform any git operations (add, commit, etc.) after implementing the phase
- The agent should output a message asking the user to implement the specified phase
- The agent should stop execution after implementing the phase and not attempt to continue with the spec
- The `update` command (src/update.odin) should detect if `.opencode/commands/oc-phase.md` is missing from the user's project and add it automatically

## Technical Notes

The command file should follow the existing pattern established by other commands in `.opencode/commands/` (e.g., `oc-create.md`, `oc-impl.md`). The implementation should leverage the existing spec structure and phase parsing logic in the openclose codebase.

## Related Links

- Existing command: `.opencode/commands/oc-impl.md`
- Existing command: `.opencode/commands/oc-create.md`
- Spec structure: `.openclose/specs/`
- Phase parsing logic in `src/parsing.odin`
