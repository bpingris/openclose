# Scenarios for externalize-command-prompts

## Happy Path

### Scenario 1: Initialize OpenCode agent with external prompts
**Given** the openclose binary is built with external prompt files
**When** the user runs `openclose init` and selects "OpenCode"
**Then** the system reads prompts/create.md, prompts/impl.md, prompts/archive.md
**And** injects OpenCode-specific frontmatter into each file
**And** creates `.opencode/commands/oc-create.md` with:
  - Frontmatter: `title: oc-create`, `description: Create a new spec using openclose cli`
  - Body: Unified create prompt content
**And** creates `.opencode/commands/oc-impl.md` with appropriate frontmatter
**And** creates `.opencode/commands/oc-archive.md` with appropriate frontmatter

### Scenario 2: Initialize Claude Code agent with external prompts
**Given** the openclose binary is built with external prompt files
**When** the user runs `openclose init` and selects "Claude Code"
**Then** the system reads the same unified prompt files as Scenario 1
**And** creates `.claude/commands/openclose/create.md` with:
  - Frontmatter: `title: create`, `description: Create a new spec using openclose cli`
  - Body: Same unified create prompt content as OpenCode
**And** creates `impl.md` and `archive.md` with appropriate frontmatter

### Scenario 3: Initialize Cursor agent with external prompts
**Given** the openclose binary is built with external prompt files
**When** the user runs `openclose init` and selects "Cursor"
**Then** the system reads the same unified prompt files
**And** creates `.cursor/commands/cursor-create.md` with:
  - Frontmatter: `title: cursor-create`, `description: Create a new spec using openclose cli`
  - Body: Same unified content as other agents

### Scenario 4: All agents get identical prompt body content
**Given** OpenCode, Claude Code, and Cursor have all been initialized
**When** comparing the body content (excluding frontmatter) of corresponding command files
**Then** the content is byte-for-byte identical across all agents
**And** only the frontmatter differs (title field varies)

## Edge Cases

### Scenario 5: Prompt files are missing during init
**Given** the prompts/ directory or a required prompt file is missing
**When** the user runs `openclose init` and selects any agent
**Then** an error message is displayed: "Failed to load prompt file: prompts/create.md"
**And** the init command exits with failure
**And** no partial command files are created

### Scenario 6: Prompt file is empty
**Given** prompts/create.md exists but is empty
**When** the user runs `openclose init` and selects an agent
**Then** a warning is displayed: "Warning: prompts/create.md is empty"
**And** the command file is created with only frontmatter and empty body
**And** the init continues for other files

### Scenario 7: Prompt file has no placeholder markers
**Given** prompts/create.md has hardcoded frontmatter instead of placeholders
**When** the system loads and processes the file
**Then** the system should prepend new frontmatter
**Or** replace existing frontmatter based on pattern detection
**And** the final file should have correct agent-specific frontmatter

## Error Cases

### Scenario 8: Permission error reading prompt files
**Given** prompts/create.md exists but is not readable due to permissions
**When** the system tries to read the file
**Then** an error message is displayed: "Permission denied reading prompts/create.md"
**And** the init command exits with failure

### Scenario 9: Agent has invalid prompt file reference
**Given** an Agent_Info struct references a non-existent prompt file
**When** the system tries to load the prompt
**Then** an error message is displayed: "Invalid prompt reference: unknown.md"
**And** the init command skips that command file or exits with failure
