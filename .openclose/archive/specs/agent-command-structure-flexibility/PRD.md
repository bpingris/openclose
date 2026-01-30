# agent-command-structure-flexibility

Created: 2026-01-30

## Problem Statement
Currently, the `Agent_Info` structure assumes all agents use the same file naming convention (prefix-based like `oc-create.md`). However, different agents have different command file structures:
- OpenCode uses prefixed files in a flat directory (`oc-create.md`, `oc-impl.md`, etc.)
- Claude Code uses a subdirectory with simple filenames (`commands/openclose/create.md`, etc.)

We need to make the agent configuration more flexible to support these different directory and naming conventions.

## Requirements
- Update `Agent_Info` struct to define command files individually instead of using a generic prefix
- Each agent should specify:
  - Base commands directory
  - Subdirectory path (if any)
  - List of command files with their specific names and content templates
- Support OpenCode structure: `.opencode/commands/` with files `oc-create.md`, `oc-impl.md`, `oc-archive.md`
- Support Claude Code structure: `.claude/commands/openclose/` with files `create.md`, `impl.md`, `archive.md`
- Remove the generic `file_prefix` field and replace with explicit command file definitions
- Update the `create_agent_commands` function to use the new structure
- Update file existence checks to handle both structures correctly

## Technical Notes
- Define a new `Command_File` struct that holds filename and content template
- Update `Agent_Info` to have a slice of `Command_File` instead of `file_prefix`
- For OpenCode: 3 files in flat structure with `oc-` prefix
- For Claude Code: 3 files in `openclose/` subdirectory, no prefix
- Each command (create, impl, archive) maps to a specific template constant
- File existence checks should check the full path for each command file
- Keep Cursor agent for future use but focus implementation on OpenCode and Claude Code

## Agent Configurations

### OpenCode
- Base directory: `.opencode/commands/`
- Files:
  - `oc-create.md` (uses OC_CREATE_COMMAND template)
  - `oc-impl.md` (uses OC_IMPL_COMMAND template)
  - `oc-archive.md` (uses OC_ARCHIVE_COMMAND template)

### Claude Code
- Base directory: `.claude/commands/`
- Subdirectory: `openclose/`
- Files:
  - `create.md` (uses CLAUDE_CREATE_COMMAND template)
  - `impl.md` (uses CLAUDE_IMPL_COMMAND template)
  - `archive.md` (uses CLAUDE_ARCHIVE_COMMAND template)

## Related Links
- `src/types.odin` - Agent_Info struct definition
- `src/init.odin` - Command file creation logic
- `src/templates.odin` - Command content templates
