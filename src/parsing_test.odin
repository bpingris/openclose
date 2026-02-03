package main

import "core:testing"

@(test)
test_parse_tasks_content_valid_tasks :: proc(t: ^testing.T) {
	content := `# Tasks for Test

## Phase 1: Foundation

- [x] Extract parse_tasks_content function
- [ ] Add unit tests

## Phase 2: Implementation

- [x] Refactor original function
- [x] Verify functionality
`

	total, completed, phases := parse_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, total, 4)
	testing.expect_value(t, completed, 3)
	testing.expect_value(t, len(phases), 2)
}

@(test)
test_parse_tasks_content_empty :: proc(t: ^testing.T) {
	content := ""

	total, completed, phases := parse_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, total, 0)
	testing.expect_value(t, completed, 0)
	testing.expect_value(t, len(phases), 0)
}

@(test)
test_parse_tasks_content_no_checkboxes :: proc(t: ^testing.T) {
	content := `# Tasks for Test

## Phase 1: Foundation

This is just a description without any tasks.

## Phase 2: Implementation

More text here.
`

	total, completed, phases := parse_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, total, 0)
	testing.expect_value(t, completed, 0)
	testing.expect_value(t, len(phases), 2)
}

@(test)
test_parse_tasks_content_all_incomplete :: proc(t: ^testing.T) {
	content := `# Tasks

## Phase 1

- [ ] Task 1
- [ ] Task 2
- [ ] Task 3
`

	total, completed, phases := parse_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, total, 3)
	testing.expect_value(t, completed, 0)
	testing.expect_value(t, len(phases), 1)
}

@(test)
test_parse_tasks_content_all_complete :: proc(t: ^testing.T) {
	content := `# Tasks

## Phase 1

- [x] Task 1
- [X] Task 2
- [x] Task 3
`

	total, completed, phases := parse_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, total, 3)
	testing.expect_value(t, completed, 3)
	testing.expect_value(t, len(phases), 1)
}

@(test)
test_parse_tasks_content_phase_tracking :: proc(t: ^testing.T) {
	content := `# Tasks

## Phase 1: Setup

- [x] Setup database
- [ ] Configure app

## Phase 2: Feature

- [ ] Implement feature
- [x] Write tests
`

	total, completed, phases := parse_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, total, 4)
	testing.expect_value(t, completed, 2)
	testing.expect_value(t, len(phases), 2)

	if len(phases) >= 2 {
		testing.expect_value(t, phases[0].total_tasks, 2)
		testing.expect_value(t, phases[0].completed_tasks, 1)
		testing.expect_value(t, phases[1].total_tasks, 2)
		testing.expect_value(t, phases[1].completed_tasks, 1)
	}
}

@(test)
test_parse_tasks_content_mixed_checkbox_styles :: proc(t: ^testing.T) {
	content := `# Tasks

## Phase 1

- [x] Lowercase x task
- [X] Uppercase X task
- [ ] Incomplete task
`

	total, completed, _ := parse_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, total, 3)
	testing.expect_value(t, completed, 2)
}

@(test)
test_parse_tasks_content_task_header_excluded :: proc(t: ^testing.T) {
	content := `# Tasks for Test

## Phase 1

- [x] Actual task
`

	total, completed, phases := parse_tasks_content(content)
	defer free_all(context.temp_allocator)

	testing.expect_value(t, total, 1)
	testing.expect_value(t, completed, 1)
	testing.expect_value(t, len(phases), 1)
}
