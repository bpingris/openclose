# Refactor Codebase for Testability

Created: 2026-02-03

## Problem Statement

The current Odin codebase has functions that read files and process content in a tightly coupled manner. This makes unit testing difficult because:

1. Tests MUST use actual files on disk to test content processing logic
2. Unit tests cannot directly pass mock data or test edge cases easily
3. File I/O dependencies make tests slow and harder to maintain

We need to refactor the code to separate file I/O from content processing, enabling proper unit testing without requiring files on disk.

## Requirements

1. Functions that parse or validate file content MUST be refactored to accept content as a string parameter rather than a file path
2. The file reading logic MUST remain in the original functions or be handled at a higher level
3. New content-processing functions MUST use `context.temp_allocator` for temporary memory allocations to ensure proper cleanup
4. Functions MUST properly free memory using `delete` or `free_all(context.temp_allocator)` when needed
5. Unit tests MUST be able to pass arbitrary string content to the extracted functions
6. The refactored code MUST maintain the same external API and behavior

## Technical Notes

- Target files for refactoring:
  - `src/parsing.odin`: `parse_tasks_for_completion` - split file reading from parsing logic
  - `src/validate.odin`: `validate_prd`, `validate_tasks`, `validate_scenarios` - split validation logic

- Memory management approach:
  - Use `context.temp_allocator` for temporary allocations within processing functions
  - Call `free_all(context.temp_allocator)` after function returns to clean up
  - Alternatively, manually `delete` allocated memory when appropriate

- Testing strategy:
  - Create new unit tests that pass content strings directly to extracted functions
  - Tests should cover edge cases like empty content, malformed content, valid content
  - No file I/O required in unit tests

- Patterns to follow:
  ```odin
  // Original pattern (before):
  parse_file :: proc(path: string) -> Result {
      content, ok := os.read_entire_file(path)
      // ... parse content directly
  }
  
  // New pattern (after):
  parse_file :: proc(path: string) -> Result {
      content, ok := os.read_entire_file(path)
      defer delete(content)  // or free_all(context.temp_allocator)
      return parse_content(string(content))
  }
  
  parse_content :: proc(text: string) -> Result {
      // Pure function that processes text
      // Uses context.temp_allocator for temporary allocations
  }
  ```

## Related Links

- Odin documentation: https://odin-lang.org/docs/
- Current files to refactor: src/parsing.odin, src/validate.odin
- Related tests: src/validate_test.odin, src/utils_test.odin
