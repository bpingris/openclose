# Scenarios for agent-command-structure-flexibility

## Happy Path

### Scenario 1: Initialize with OpenCode agent
**Given** the user runs `openclose init`
**When** the user selects "OpenCode" from the agent list
**Then** the `.opencode/commands/` directory is created
**And** three files are created: `oc-create.md`, `oc-impl.md`, `oc-archive.md`
**And** each file contains the correct OpenCode template content

### Scenario 2: Initialize with Claude Code agent
**Given** the user runs `openclose init`
**When** the user selects "Claude Code" from the agent list
**Then** the `.claude/commands/openclose/` directory is created
**And** three files are created: `create.md`, `impl.md`, `archive.md`
**And** each file contains the correct Claude Code template content

## Edge Cases

### Scenario 3: OpenCode commands directory already exists
**Given** the `.opencode/commands/` directory already exists
**When** the user runs init and selects OpenCode
**Then** the system uses the existing directory
**And** checks for existing command files

### Scenario 4: Claude Code subdirectory already exists
**Given** the `.claude/commands/openclose/` directory already exists
**When** the user runs init and selects Claude Code
**Then** the system uses the existing directory structure
**And** checks for existing command files

### Scenario 5: Mixed existing files for OpenCode
**Given** `oc-create.md` already exists but `oc-impl.md` and `oc-archive.md` do not
**When** the user runs init and selects OpenCode
**Then** a warning is displayed listing `oc-create.md`
**And** the command is aborted without creating any files

### Scenario 6: Mixed existing files for Claude Code
**Given** `create.md` already exists but `impl.md` and `archive.md` do not
**When** the user runs init and selects Claude Code
**Then** a warning is displayed listing `create.md`
**And** the command is aborted without creating any files

## Error Cases

### Scenario 7: Cannot create Claude Code subdirectory
**Given** there is a permission error preventing subdirectory creation
**When** the system tries to create `.claude/commands/openclose/`
**Then** an error message is displayed
**And** the command exits with failure

### Scenario 8: Invalid agent configuration
**Given** an agent has empty command file list
**When** the init command tries to process the agent
**Then** a warning is displayed: "No command files configured for agent"
**And** the command skips command creation for that agent
