package main

import "core:testing"

@(test)
test_has_rfc2119_keywords_must :: proc(t: ^testing.T) {
	text := "The system MUST validate inputs"
	testing.expect(t, has_rfc2119_keywords(text), "Expected MUST to be detected")
}

@(test)
test_has_rfc2119_keywords_must_not :: proc(t: ^testing.T) {
	text := "The system MUST NOT accept invalid data"
	testing.expect(t, has_rfc2119_keywords(text), "Expected MUST NOT to be detected")
}

@(test)
test_has_rfc2119_keywords_should :: proc(t: ^testing.T) {
	text := "The system SHOULD log warnings"
	testing.expect(t, has_rfc2119_keywords(text), "Expected SHOULD to be detected")
}

@(test)
test_has_rfc2119_keywords_may :: proc(t: ^testing.T) {
	text := "The system MAY cache results"
	testing.expect(t, has_rfc2119_keywords(text), "Expected MAY to be detected")
}

@(test)
test_has_rfc2119_keywords_required :: proc(t: ^testing.T) {
	text := "This field is REQUIRED"
	testing.expect(t, has_rfc2119_keywords(text), "Expected REQUIRED to be detected")
}

@(test)
test_has_rfc2119_keywords_optional :: proc(t: ^testing.T) {
	text := "This parameter is OPTIONAL"
	testing.expect(t, has_rfc2119_keywords(text), "Expected OPTIONAL to be detected")
}

@(test)
test_has_rfc2119_keywords_case_insensitive :: proc(t: ^testing.T) {
	text := "the system must validate inputs"
	testing.expect(t, has_rfc2119_keywords(text), "Expected lowercase 'must' to be detected")
}

@(test)
test_has_rfc2119_keywords_none_present :: proc(t: ^testing.T) {
	text := "The system validates inputs and processes data"
	testing.expect(t, !has_rfc2119_keywords(text), "Expected no RFC 2119 keywords to be detected")
}

@(test)
test_has_rfc2119_keywords_empty_string :: proc(t: ^testing.T) {
	text := ""
	testing.expect(t, !has_rfc2119_keywords(text), "Expected empty string to return false")
}

@(test)
test_has_rfc2119_keywords_multiple_keywords :: proc(t: ^testing.T) {
	text := "The system MUST validate inputs and SHOULD log warnings. It MAY also cache results."
	testing.expect(t, has_rfc2119_keywords(text), "Expected multiple RFC 2119 keywords to be detected")
}

@(test)
test_has_rfc2119_keywords_shall :: proc(t: ^testing.T) {
	text := "The system SHALL respond within 5 seconds"
	testing.expect(t, has_rfc2119_keywords(text), "Expected SHALL to be detected")
}

@(test)
test_has_rfc2119_keywords_shall_not :: proc(t: ^testing.T) {
	text := "The system SHALL NOT expose sensitive data"
	testing.expect(t, has_rfc2119_keywords(text), "Expected SHALL NOT to be detected")
}

@(test)
test_has_rfc2119_keywords_should_not :: proc(t: ^testing.T) {
	text := "The system SHOULD NOT block the main thread"
	testing.expect(t, has_rfc2119_keywords(text), "Expected SHOULD NOT to be detected")
}

@(test)
test_has_rfc2119_keywords_recommended :: proc(t: ^testing.T) {
	text := "Using caching is RECOMMENDED for performance"
	testing.expect(t, has_rfc2119_keywords(text), "Expected RECOMMENDED to be detected")
}

@(test)
test_contains_case_insensitive_basic :: proc(t: ^testing.T) {
	text := "The system MUST validate"
	pattern := "MUST"
	testing.expect(t, contains_case_insensitive(text, pattern), "Expected MUST to be found")
}

@(test)
test_contains_case_insensitive_lowercase :: proc(t: ^testing.T) {
	text := "the system must validate"
	pattern := "MUST"
	testing.expect(t, contains_case_insensitive(text, pattern), "Expected must to be found (case insensitive)")
}

@(test)
test_contains_case_insensitive_not_found :: proc(t: ^testing.T) {
	text := "The system should validate"
	pattern := "MUST"
	testing.expect(t, !contains_case_insensitive(text, pattern), "Expected MUST not to be found")
}

@(test)
test_contains_case_insensitive_empty_pattern :: proc(t: ^testing.T) {
	text := "The system MUST validate"
	pattern := ""
	testing.expect(t, contains_case_insensitive(text, pattern), "Empty pattern should always return true")
}

@(test)
test_contains_case_insensitive_longer_pattern :: proc(t: ^testing.T) {
	text := "MUST"
	pattern := "MUST NOT"
	testing.expect(t, !contains_case_insensitive(text, pattern), "Pattern longer than text should return false")
}

@(test)
test_contains_case_insensitive_at_end :: proc(t: ^testing.T) {
	text := "The system MUST"
	pattern := "MUST"
	testing.expect(t, contains_case_insensitive(text, pattern), "Expected MUST at end to be found")
}

@(test)
test_contains_case_insensitive_at_start :: proc(t: ^testing.T) {
	text := "MUST validate"
	pattern := "MUST"
	testing.expect(t, contains_case_insensitive(text, pattern), "Expected MUST at start to be found")
}

@(test)
test_contains_case_insensitive_multiple_occurrences :: proc(t: ^testing.T) {
	text := "MUST do this and MUST do that"
	pattern := "MUST"
	testing.expect(t, contains_case_insensitive(text, pattern), "Expected multiple MUST occurrences to be found")
}

@(test)
test_contains_case_insensitive_overlapping :: proc(t: ^testing.T) {
	text := "AAAAAA"
	pattern := "AAA"
	testing.expect(t, contains_case_insensitive(text, pattern), "Expected overlapping pattern to be found")
}

@(test)
test_validate_prd_content_valid :: proc(t: ^testing.T) {
	content := `# Test Spec

## Problem Statement

We need to solve this problem.

## Requirements

1. The system MUST handle inputs
2. The system SHOULD validate data

## Technical Notes

Implementation details here.
`

	errors := validate_prd_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, len(errors), 0)
}

@(test)
test_validate_prd_content_missing_problem_statement :: proc(t: ^testing.T) {
	content := `# Test Spec

## Requirements

1. The system MUST handle inputs

## Technical Notes

Implementation details here.
`

	errors := validate_prd_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_prd_content_missing_requirements :: proc(t: ^testing.T) {
	content := `# Test Spec

## Problem Statement

We need to solve this problem.

## Technical Notes

Implementation details here.
`

	errors := validate_prd_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_prd_content_missing_technical_notes :: proc(t: ^testing.T) {
	content := `# Test Spec

## Problem Statement

We need to solve this problem.

## Requirements

1. The system MUST handle inputs
`

	errors := validate_prd_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_prd_content_missing_title :: proc(t: ^testing.T) {
	content := `Test Spec without title

## Problem Statement

We need to solve this problem.

## Requirements

1. The system MUST handle inputs

## Technical Notes

Implementation details here.
`

	errors := validate_prd_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_prd_content_empty :: proc(t: ^testing.T) {
	content := ""

	errors := validate_prd_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_prd_content_missing_rfc2119 :: proc(t: ^testing.T) {
	content := `# Test Spec

## Problem Statement

We need to solve this problem.

## Requirements

1. The system handles inputs
2. The system validates data

## Technical Notes

Implementation details here.
`

	errors := validate_prd_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_tasks_content_valid :: proc(t: ^testing.T) {
	content := `# Tasks for Test

## Phase 1: Foundation

- [ ] The system MUST implement this
- [x] The system SHOULD do that
`

	errors := validate_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, len(errors), 0)
}

@(test)
test_validate_tasks_content_no_phases :: proc(t: ^testing.T) {
	content := `# Tasks for Test

- [ ] Task without phase
- [ ] Another task
`

	errors := validate_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_tasks_content_no_checkboxes :: proc(t: ^testing.T) {
	content := `# Tasks for Test

## Phase 1

This is just a description.

## Phase 2

More description text.
`

	errors := validate_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_tasks_content_missing_rfc2119 :: proc(t: ^testing.T) {
	content := `# Tasks for Test

## Phase 1

- [ ] Implement the feature
- [ ] Test the system
`

	errors := validate_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_tasks_content_empty :: proc(t: ^testing.T) {
	content := ""

	errors := validate_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) >= 2)
}

@(test)
test_validate_scenarios_content_valid :: proc(t: ^testing.T) {
	content := `# Scenarios for Test

### Scenario 1: Valid case
**Given** a valid system
**When** the user MUST act
**Then** the system SHOULD respond
`

	errors := validate_scenarios_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, len(errors), 0)
}

@(test)
test_validate_scenarios_content_no_given :: proc(t: ^testing.T) {
	content := `# Scenarios for Test

### Scenario 1: Invalid
**When** action occurs
**Then** result happens
`

	errors := validate_scenarios_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_scenarios_content_no_when :: proc(t: ^testing.T) {
	content := `# Scenarios for Test

### Scenario 1: Invalid
**Given** initial state
**Then** result happens
`

	errors := validate_scenarios_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_scenarios_content_no_then :: proc(t: ^testing.T) {
	content := `# Scenarios for Test

### Scenario 1: Invalid
**Given** initial state
**When** action occurs
`

	errors := validate_scenarios_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_scenarios_content_missing_rfc2119 :: proc(t: ^testing.T) {
	content := `# Scenarios for Test

### Scenario 1: No keywords
**Given** a system
**When** something happens
**Then** something else occurs
`

	errors := validate_scenarios_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) > 0)
}

@(test)
test_validate_scenarios_content_empty :: proc(t: ^testing.T) {
	content := ""

	errors := validate_scenarios_content(content)
	defer free_all(context.temp_allocator)

	testing.expect(t, len(errors) >= 3)
}

@(test)
test_validate_scenarios_content_multiple_scenarios :: proc(t: ^testing.T) {
	content := `# Scenarios for Test

### Scenario 1: First
**Given** a system that MUST work
**When** the user acts
**Then** the system SHOULD respond

### Scenario 2: Second
**Given** another system
**When** something else MUST happen
**Then** a different result SHOULD occur
`

	errors := validate_scenarios_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, len(errors), 0)
}
