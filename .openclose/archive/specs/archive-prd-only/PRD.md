# archive-prd-only

Created: 2026-01-30

## Problem Statement
Currently, when archiving specs, we move all three files (PRD.md, tasks.md, scenarios.md) to the archive folder. This creates unnecessary clutter in the archive directory since:

1. Once a spec is implemented and archived, the tasks are "done" and scenarios are "passed" - they're no longer actionable
2. The PRD.md contains the essential information: what problem was solved, requirements, and technical decisions
3. Archiving all files takes more disk space and makes browsing archived specs more difficult
4. The archive folder becomes cluttered with duplicate/redundant information

## Requirements
- Modify the archive process to only keep PRD.md when archiving specs
- Remove tasks.md and scenarios.md from archived specs
- Ensure the PRD.md alone provides sufficient context for future reference
- Maintain backward compatibility with existing archived specs (leave them as-is)

## Alternative Approaches Considered (Notes for Future Reference)

### Option 2: Compact/Compress All Files
- **Approach**: Keep all three files but compress them into a single archive file per spec
- **Pros**: Complete history preserved, takes less disk space than raw files
- **Cons**: Requires extraction to view, adds complexity to archive/unarchive operations
- **Status**: Not selected for now, but noted as alternative if storage becomes concern

### Option 3: archive.json Index
- **Approach**: Replace file-based archive with a single JSON index containing spec names, dates, and brief descriptions
- **Pros**: Minimal storage, easy to parse programmatically
- **Cons**: Loses all detailed context and technical decisions, can't review what was actually built
- **Status**: Not selected - too much information loss

### Option 4: Keep All Files (Current Behavior)
- **Approach**: Continue archiving all three files as we do now
- **Pros**: Complete history, no code changes needed
- **Cons**: Cluttered archive, redundant information, harder to browse
- **Status**: Current behavior, being replaced by PRD-only approach

## Technical Notes
- Modify the `copy_directory` call in archive logic to selectively copy only PRD.md
- Update the archive directory creation to only create the spec folder and copy PRD.md
- The archive folder structure remains the same: `.openclose/archive/specs/<spec-name>/PRD.md`
- Existing archived specs with all three files should be left untouched (backward compatibility)
- Consider adding a header comment to archived PRD.md noting that tasks/scenarios were removed during archive

## Related Links
- src/archive.odin - Archive command implementation
- src/utils.odin - copy_directory function
