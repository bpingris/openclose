# Tasks for agent-command-structure-flexibility

## Phase 1: Foundation
- [ ] Define Command_File struct to hold individual command configuration
  - filename: string
  - template: string (reference to template constant)
- [ ] Update Agent_Info struct
  - Remove file_prefix field
  - Add commands_dir field (base directory)
  - Add subdirectory field (optional subfolder, empty string if none)
  - Add commands field ([]Command_File)
- [ ] Update AGENTS array with new structure
  - OpenCode: `.opencode/commands/`, no subdirectory, 3 files with oc- prefix
  - Claude Code: `.claude/commands/`, subdirectory `openclose/`, 3 files no prefix

## Phase 2: Implementation
- [ ] Refactor check_existing_command_files function
  - Build full path using commands_dir + subdirectory + filename
  - Check each command file individually
  - Return list of existing full paths
- [ ] Refactor create_agent_commands function
  - Create base commands directory
  - Create subdirectory if specified (for Claude Code)
  - Iterate through command files and create each with correct template
  - Use full path: commands_dir + subdirectory + filename
- [ ] Update get_command_template or remove if no longer needed
  - Templates are now directly referenced in Command_File struct

## Phase 3: Polish
- [ ] Test OpenCode agent initialization
  - Verify directory structure
  - Verify file names and content
- [ ] Test Claude Code agent initialization
  - Verify nested directory structure
  - Verify file names and content
- [ ] Test file existence detection for both structures
  - Verify correct paths are checked
- [ ] Test error handling
  - Permission errors on directory creation
  - File write errors
- [ ] Update any documentation references
