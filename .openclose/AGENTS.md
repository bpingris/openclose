# Project Overview

openclose is a CLI tool for organizing software specifications, PRDs (Product Requirements Documents), and implementation tracking. It helps development teams manage their project specifications through a structured workflow:

1. **Create specs** - Define features with PRD, tasks, and test scenarios
2. **Implement** - Follow the spec tasks to build features
3. **Validate** - Ensure specs meet formatting requirements
4. **Archive** - Clean up completed work

# Technology Stack

- **Language**: Odin (systems programming language)
- **Build**: `odin build src -out:build/openclose -o:speed -vet -strict-style`
- **Test**: `odin test src -all-packages`
- **Version**: Current version managed in `src/version.odin`

# Architecture Notes

## High-level Structure

```
src/
├── main.odin          # Entry point and command routing
├── parsing.odin       # Task/content parsing logic
├── validate.odin      # Spec validation logic
├── create.odin        # Spec creation functionality
├── archive.odin       # Spec archiving functionality
├── summary.odin       # Progress summary display
├── update.odin        # Agent command file updates
├── utils.odin         # Utility functions (slugify, etc.)
├── types.odin         # Common data structures
├── init.odin          # Initialization logic
└── *_test.odin        # Unit tests
```

## Key Directories

- `.openclose/specs/` - Active specifications
- `.openclose/epics/` - Epic (grouped) specifications
- `.openclose/archive/` - Archived specs and epics
- `.opencode/commands/` - OpenCode agent commands
- `.claude/commands/openclose/` - Claude Code agent commands
- `.cursor/commands/` - Cursor agent commands

# Rules & Conventions

## Coding Standards

1. **Memory Management**:
   - Use `context.temp_allocator` for temporary allocations within functions
   - Use `defer free_all(context.temp_allocator)` to clean up temporary memory
   - File I/O allocations (`os.read_entire_file`) use default allocator - always `defer delete(content)`
   - Return values that persist must use default allocator or be documented

2. **Function Naming**:
   - `verb_noun` pattern (e.g., `parse_tasks`, `validate_prd`)
   - Content processing functions: `{action}_{type}_content` (e.g., `parse_tasks_content`)
   - File I/O wrappers: `{action}_{type}` (e.g., `parse_tasks`)

3. **Unit Testing**:
   - Test content processing functions directly without file I/O
   - Name tests: `test_{function_name}_{scenario}`
   - Use `context.temp_allocator` in tests with `defer free_all(context.temp_allocator)`
   - Test edge cases: empty content, valid content, missing sections

4. **Error Handling**:
   - Return empty slices for no errors
   - Use `Validation_Error` struct for validation errors
   - Include file name and descriptive message

## Things to Avoid

- Don't mix file I/O with content processing logic
- Don't use `defer free_all(context.temp_allocator)` in file I/O wrapper functions
- Don't allocate return values that persist with temp_allocator unless documented
- Don't leak file content allocations - always `defer delete(content)`

# Memory Management Patterns

## Pattern 1: Content Processing Functions

Content processing functions accept string content and use `context.temp_allocator`:

```odin
parse_tasks_content :: proc(content: string) -> (total: int, completed: int, phases: []Phase_Info) {
    phases_list := make([dynamic]Phase_Info, context.temp_allocator)
    lines := strings.split_lines(content, context.temp_allocator)
    // ... process content ...
    return total, completed, phases_list[:]
}
```

**Caller must clean up**: `defer free_all(context.temp_allocator)`

## Pattern 2: File I/O Wrapper Functions

File I/O functions read files and delegate to content functions:

```odin
parse_tasks :: proc(tasks_path: string) -> (total: int, completed: int, phases: []Phase_Info) {
    content, ok := os.read_entire_file(tasks_path)
    if !ok {
        return 0, 0, nil
    }
    defer delete(content)  // Clean up file content
    
    return parse_tasks_content(string(content))
}
```

## Pattern 3: Caller Cleanup

When calling content processing functions:

```odin
// Unit test example
@(test)
test_parse_tasks_content :: proc(t: ^testing.T) {
    content := "- [ ] Task 1"
    total, completed, phases := parse_tasks_content(content)
    defer free_all(context.temp_allocator)  // Clean up all temp allocations
    
    testing.expect_value(t, total, 1)
}
```

## Pattern 4: Function-Level Temp Allocator Cleanup

For functions that allocate multiple temporary strings:

```odin
collect_spec_info :: proc(spec_path: string, spec_name: string) -> Spec_Info {
    tasks_path := filepath.join({spec_path, "tasks.md"}, context.temp_allocator)
    prd_path := filepath.join({spec_path, "PRD.md"}, context.temp_allocator)
    defer free_all(context.temp_allocator)  // Clean up path strings
    
    // ... use paths ...
    return Spec_Info{...}
}
```

# How to Run

## Building

```bash
mkdir -p build
odin build src -out:build/openclose -o:speed -vet -strict-style
```

## Testing

```bash
odin test src -all-packages
```

## Usage

```bash
# Initialize
./build/openclose init

# Create a spec
./build/openclose create my-feature

# Validate a spec
./build/openclose validate my-feature

# Show summary
./build/openclose summary

# Archive a spec
./build/openclose archive specs/my-feature
```

# Contribution Guidelines

1. Create a spec for any significant refactoring or feature
2. Write unit tests for new content processing functions
3. Follow memory management patterns documented above
4. Verify no memory leaks exist by running tests with memory tracking
5. Ensure all tests pass: `odin test src -all-packages`
6. Ensure project builds: `odin build src -out:build/openclose -o:speed -vet -strict-style`
7. Update AGENTS.md if adding new patterns or conventions
