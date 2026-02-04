# Remove Epic Feature

Created: 2026-02-03

## Problem Statement

The epic feature adds unnecessary complexity to the openclose tool. Users can achieve the same organization goals using standalone specs with clear naming conventions. The epic feature:

1. Creates nested directory structures that complicate navigation
2. Adds cognitive overhead with the concept of "epics" vs "specs"
3. Requires additional code paths for validation, archiving, and summary
4. Makes the CLI interface more complex with `--epic` flags and `epic` commands

Removing this feature will simplify the codebase, reduce maintenance burden, and streamline the user experience.

## Requirements

1. The `epic` subcommand MUST be removed from the CLI
2. The `--epic` flag on the `create` command MUST be removed
3. All epic-related helper functions in `utils.odin` MUST be removed
4. Epic-related code in `validate.odin` MUST be removed
5. Epic-related code in `archive.odin` MUST be removed
6. Epic-related code in `create.odin` MUST be removed
7. Epic-related code in `summary.odin` MUST be removed
8. The `Epic_Info` type in `types.odin` MUST be removed
9. The `collect_epic_info` function in `parsing.odin` MUST be removed
10. The epic template file MUST be removed or archived
11. The `.openclose/epics/` directory handling MUST be removed
12. All existing specs MUST continue to work as standalone specs
13. The help text MUST be updated to remove epic references

## Technical Notes

- Files to modify:
  - `src/main.odin`: Remove `epic` case from switch, update help text
  - `src/create.odin`: Remove `create_epic` and epic parameter from `create_spec`, remove `epic_cmd`
  - `src/utils.odin`: Remove `get_epics_dir` and `get_archive_epics_dir`
  - `src/validate.odin`: Remove epic search from `find_spec_path`
  - `src/archive.odin`: Remove epic handling from archive logic
  - `src/summary.odin`: Remove epic collection and display
  - `src/parsing.odin`: Remove `collect_epic_info` function
  - `src/types.odin`: Remove `Epic_Info` type
  - `prompts/epic.md`: Remove or archive this template

- Simplifications after removal:
  - All specs live directly in `.openclose/specs/`
  - No nested directory structures
  - Archive only handles specs, not epics
  - Summary only shows flat list of specs
  - `find_spec_path` only searches specs directory

- Backward compatibility:
  - Existing specs in `.openclose/specs/` remain unchanged
  - Any specs that were in epics should be manually moved to specs if needed

## Related Links

- Current epic-related code search: `grep -r "epic" src/`
- Epic directory: `.openclose/epics/`
- Epic template: `prompts/epic.md`
