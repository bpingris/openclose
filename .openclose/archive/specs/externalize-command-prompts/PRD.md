# externalize-command-prompts

Created: 2026-01-30

## Problem Statement
Currently, command prompts are stored as hardcoded string constants in the Odin source code (templates.odin, lines 105-123). This approach has several drawbacks:

1. **Difficult to maintain**: Editing prompts requires modifying and recompiling the source code
2. **Code clutter**: Large multi-line strings embedded in code reduce readability
3. **Duplication**: The same prompt content is duplicated across 3 agents (OpenCode, Claude Code, Cursor) with only minor frontmatter differences
4. **No distinction needed**: The actual instructions are identical across all agents - only the title/description metadata differs

## Requirements
- Move command prompt content from Odin code constants to external MD files
- Create unified prompt content that works for all agents (no agent-specific variations)
- Store prompts in a dedicated `prompts/` directory within the openclose installation
- Update the code to read prompt content from files at runtime
- Remove duplicate template constants (OC_CREATE_COMMAND, CLAUDE_CREATE_COMMAND, CURSOR_CREATE_COMMAND, etc.)
- Ensure each agent gets the same prompt content when initializing command files
- Update the frontmatter dynamically based on the agent's filename when writing to agent directories

## Unified Prompt Files

Three unified prompt files to be created:

### prompts/create.md
Instructions for creating a new spec:
- Use openclose create command
- Infer spec name from user input or ask if unclear
- Create the spec structure (PRD.md, tasks.md, scenarios.md)
- Do not implement, only create the spec
- Wait for user confirmation before proceeding

### prompts/impl.md
Instructions for implementing a spec:
- Find the matching spec in .openclose folder
- Handle multiple matches by asking user to select
- Validate spec before implementing
- Implement all tasks from tasks.md
- Fix spec if invalid, or ask user for guidance

### prompts/archive.md
Instructions for archiving a spec:
- Find the matching spec in .openclose folder
- Handle multiple matches by asking user to select
- Run openclose archive command
- Move spec to archive folder

## Technical Notes
- Create a `prompts/` directory in the openclose installation location
- Create three MD files: create.md, impl.md, archive.md
- Each file should have a placeholder for title/description frontmatter that gets filled when writing to agent directories
- Update Agent_Info struct to reference these unified files instead of hardcoded templates
- Update create_agent_commands() to read content from prompt files and inject agent-specific frontmatter
- Remove the duplicate OC_*, CLAUDE_*, CURSOR_* template constants from templates.odin
- Consider embedding prompt files at compile time or loading at runtime
- Handle file read errors gracefully with fallback messages

## Related Links
- src/templates.odin - Current template constants
- src/types.odin - Agent_Info struct definition
- src/init.odin - Command file creation logic
