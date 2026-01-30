# Tasks for externalize-command-prompts

## Phase 1: Foundation
- [x] Create prompts/ directory structure
  - Create `prompts/` directory alongside src/
  - Create create.md, impl.md, archive.md files
  - Extract and unify content from existing templates
- [x] Design frontmatter template system
  - Define placeholder format for title/description
  - Create function to inject agent-specific frontmatter
  - Test frontmatter generation with all agents
- [x] Update Agent_Info struct
  - Replace template field with prompt_filename field
  - Update AGENTS array to reference prompt files
  - Remove file-specific prefixes from agent configs

## Phase 2: Implementation
- [x] Create unified prompt files
  - Create prompts/create.md with unified content
  - Create prompts/impl.md with unified content
  - Create prompts/archive.md with unified content
  - Remove agent-specific metadata, keep only placeholder markers
- [x] Implement prompt file loading
  - Create load_prompt_file() function in utils.odin
  - Handle file read errors with clear error messages
  - Cache loaded prompts to avoid repeated file reads
- [x] Refactor create_agent_commands()
  - Read prompt content from files instead of using template constants
  - Inject agent-specific frontmatter (title, description) based on filename
  - Write complete content with frontmatter to agent command files
- [x] Remove duplicate templates
  - Remove OC_CREATE_COMMAND, OC_IMPL_COMMAND, OC_ARCHIVE_COMMAND
  - Remove CLAUDE_CREATE_COMMAND, CLAUDE_IMPL_COMMAND, CLAUDE_ARCHIVE_COMMAND
  - Remove CURSOR_CREATE_COMMAND, CURSOR_IMPL_COMMAND, CURSOR_ARCHIVE_COMMAND
  - Keep only SPEC_TEMPLATE, TASKS_TEMPLATE, etc. for spec generation

## Phase 3: Polish
- [x] Test with OpenCode agent
  - Verify correct frontmatter: `title: oc-create`, `description: Create a new spec using openclose cli`
  - Verify all three command files created correctly
  - Verify prompt content is identical across agents
- [x] Test with Claude Code agent
  - Verify correct frontmatter: `title: create`, `description: Create a new spec using openclose cli`
  - Verify subdirectory structure works correctly
  - Verify file paths are correct
- [x] Test with Cursor agent
  - Verify correct frontmatter: `title: cursor-create`, `description: Create a new spec using openclose cli`
  - Verify flat directory structure works correctly
- [x] Test file loading error handling
  - Simulate missing prompt file
  - Verify graceful error message
  - Verify init command fails appropriately
- [x] Update any documentation references
  - Check README.md for references to template constants
  - Check AGENTS.md for outdated information
  - Update any internal documentation
