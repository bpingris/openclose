package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

// Find a spec by name
find_spec_path :: proc(spec_name: string) -> (string, bool) {
	spec_slug, ok := normalize_spec_name(spec_name)
	if !ok {
		return "", false
	}
	defer delete(spec_slug)

	// Check standalone specs
	standalone_path := filepath.join({get_specs_dir(), spec_slug})
	if os.exists(standalone_path) {
		return standalone_path, true
	}

	delete(standalone_path)
	return "", false
}

// RFC 2119 keywords for requirement validation
RFC2119_KEYWORDS :: []string {
	"MUST",
	"MUST NOT",
	"REQUIRED",
	"SHALL",
	"SHALL NOT",
	"SHOULD",
	"SHOULD NOT",
	"RECOMMENDED",
	"MAY",
	"OPTIONAL",
}

// Case-insensitive string contains check (avoids allocation)
contains_case_insensitive :: proc(text: string, pattern: string) -> bool {
	if len(pattern) == 0 {
		return true
	}
	if len(text) < len(pattern) {
		return false
	}

	pattern_upper := transmute([]u8)pattern
	text_upper := transmute([]u8)text

	for i := 0; i <= len(text) - len(pattern); i += 1 {
		found := true
		for j := 0; j < len(pattern); j += 1 {
			text_char := text_upper[i + j]
			pattern_char := pattern_upper[j]

			// Convert to uppercase for comparison
			if text_char >= 'a' && text_char <= 'z' {
				text_char = text_char - 'a' + 'A'
			}

			if text_char != pattern_char {
				found = false
				break
			}
		}
		if found {
			return true
		}
	}
	return false
}

// Check if text contains RFC 2119 keywords
has_rfc2119_keywords :: proc(text: string) -> bool {
	for keyword in RFC2119_KEYWORDS {
		if contains_case_insensitive(text, keyword) {
			return true
		}
	}
	return false
}

// Count lines up to a byte position in text
get_line_number :: proc(text: string, byte_pos: int) -> int {
	line := 1
	for i := 0; i < byte_pos && i < len(text); i += 1 {
		if text[i] == '\n' {
			line += 1
		}
	}
	return line
}

// Validate PRD.md content string format
// This function can be unit tested without file I/O
validate_prd_content :: proc(text: string) -> []Validation_Error {
	errors := make([dynamic]Validation_Error, context.temp_allocator)

	// Check required sections
	required_sections := []string{"## Problem Statement", "## Requirements", "## Technical Notes"}
	for section in required_sections {
		if !strings.contains(text, section) {
			section_pos := strings.index(text, section)
			line_num := 1
			if section_pos != -1 {
				line_num = get_line_number(text, section_pos)
			}
			append(
				&errors,
				Validation_Error {
					file = "PRD.md",
					line = line_num,
					message = fmt.tprintf("Missing required section: %s", section),
				},
			)
		}
	}

	// Check for title (first line should be # Something)
	lines := strings.split_lines(text, context.temp_allocator)
	if len(lines) > 0 {
		first_line := strings.trim_space(lines[0])
		if !strings.has_prefix(first_line, "# ") {
			append(
				&errors,
				Validation_Error {
					file = "PRD.md",
					line = 1,
					message = "First line should be a title (e.g., # Spec Name)",
				},
			)
		}
	} else {
		append(&errors, Validation_Error{file = "PRD.md", line = 1, message = "File is empty"})
	}

	// Check for RFC 2119 keywords in Requirements section
	if strings.contains(text, "## Requirements") {
		// Find the Requirements section content
		req_start := strings.index(text, "## Requirements")
		if req_start != -1 {
			// Get content after "## Requirements" header (including the newline)
			header_len := len("## Requirements")
			req_section := text[req_start + header_len:]

			// Find where next ## section starts (if any)
			next_section := strings.index(req_section, "\n## ")
			if next_section != -1 {
				req_section = req_section[:next_section]
			}

			// Check each requirement line for RFC 2119 keywords
			req_lines := strings.split_lines(req_section, context.temp_allocator)
			first_missing_line := 0
			req_start_line := get_line_number(text, req_start)

			for line, i in req_lines {
				trimmed := strings.trim_space(line)
				// Check if this is a numbered list item (e.g., "1. Something")
				if len(trimmed) > 0 &&
				   trimmed[0] >= '0' &&
				   trimmed[0] <= '9' &&
				   strings.contains(trimmed, ".") {
					// Extract the text after the number
					dot_idx := strings.index(trimmed, ".")
					if dot_idx != -1 && dot_idx < len(trimmed) - 1 {
						req_text := trimmed[dot_idx + 1:]
						req_text = strings.trim_space(req_text)
						if len(req_text) > 0 && !has_rfc2119_keywords(req_text) {
							if first_missing_line == 0 {
								first_missing_line = req_start_line + i + 1
							}
						}
					}
				}
			}

			if first_missing_line > 0 {
				append(
					&errors,
					Validation_Error {
						file = "PRD.md",
						line = first_missing_line,
						message = "Requirements SHOULD use RFC 2119 keywords (MUST, SHOULD, MAY, etc.)",
					},
				)
			}
		}
	}

	return errors[:]
}

// Validate PRD.md format
// Reads file and delegates to validate_prd_content for validation
validate_prd :: proc(prd_path: string) -> []Validation_Error {
	content, ok := os.read_entire_file(prd_path)
	if !ok {
		errors := make([dynamic]Validation_Error)
		append(&errors, Validation_Error{file = "PRD.md", message = "Could not read file"})
		return errors[:]
	}
	defer delete(content)

	return validate_prd_content(string(content))
}

// Validate tasks.md content string format
// This function can be unit tested without file I/O
validate_tasks_content :: proc(text: string) -> []Validation_Error {
	errors := make([dynamic]Validation_Error, context.temp_allocator)

	lines := strings.split_lines(text, context.temp_allocator)

	has_phases := false
	has_checkboxes := false
	task_count := 0
	tasks_with_rfc2119 := 0
	first_task_line := 0
	first_phase_line := 0
	first_task_missing_rfc2119_line := 0

	for line, i in lines {
		trimmed := strings.trim_space(line)

		// Check for phase headers
		if strings.has_prefix(trimmed, "## ") && !strings.has_prefix(trimmed, "# Tasks") {
			has_phases = true
			if first_phase_line == 0 {
				first_phase_line = i + 1
			}
		}

		// Check for checkboxes and RFC 2119 keywords
		if strings.has_prefix(trimmed, "- [ ]") ||
		   strings.has_prefix(trimmed, "- [x]") ||
		   strings.has_prefix(trimmed, "- [X]") {
			has_checkboxes = true
			task_count += 1
			if first_task_line == 0 {
				first_task_line = i + 1
			}

			// Extract task description (after the checkbox)
			task_desc := trimmed
			if strings.has_prefix(trimmed, "- [ ]") {
				task_desc = trimmed[5:]
			} else if strings.has_prefix(trimmed, "- [x]") ||
			   strings.has_prefix(trimmed, "- [X]") {
				task_desc = trimmed[5:]
			}
			task_desc = strings.trim_space(task_desc)

			if has_rfc2119_keywords(task_desc) {
				tasks_with_rfc2119 += 1
			} else if first_task_missing_rfc2119_line == 0 {
				first_task_missing_rfc2119_line = i + 1
			}
		}
	}

	if !has_phases {
		append(
			&errors,
			Validation_Error {
				file = "tasks.md",
				line = first_phase_line,
				message = "Missing phase sections (e.g., ## Phase 1: Foundation)",
			},
		)
	}

	if !has_checkboxes {
		append(
			&errors,
			Validation_Error {
				file = "tasks.md",
				line = first_task_line,
				message = "No task checkboxes found (format: - [ ] Task description)",
			},
		)
	}

	// Check that tasks use RFC 2119 keywords
	if task_count > 0 && tasks_with_rfc2119 < task_count {
		append(
			&errors,
			Validation_Error {
				file = "tasks.md",
				line = first_task_missing_rfc2119_line,
				message = "Tasks SHOULD use RFC 2119 keywords (MUST, SHOULD, MAY, etc.)",
			},
		)
	}

	return errors[:]
}

// Validate tasks.md format
// Reads file and delegates to validate_tasks_content for validation
validate_tasks :: proc(tasks_path: string) -> []Validation_Error {
	content, ok := os.read_entire_file(tasks_path)
	if !ok {
		errors := make([dynamic]Validation_Error)
		append(&errors, Validation_Error{file = "tasks.md", message = "Could not read file"})
		return errors[:]
	}
	defer delete(content)

	return validate_tasks_content(string(content))
}

// Validate scenarios.md content string format
// This function can be unit tested without file I/O
validate_scenarios_content :: proc(text: string) -> []Validation_Error {
	errors := make([dynamic]Validation_Error, context.temp_allocator)

	lines := strings.split_lines(text, context.temp_allocator)

	has_given := false
	has_when := false
	has_then := false
	scenario_count := 0
	scenarios_with_rfc2119 := 0
	in_scenario := false
	current_scenario_has_rfc2119 := false
	first_scenario_line := 0

	for line, i in lines {
		trimmed := strings.trim_space(line)
		upper := strings.to_upper(trimmed, context.temp_allocator)

		// Check for scenario headers (### Scenario)
		if strings.has_prefix(upper, "### SCENARIO") || strings.has_prefix(upper, "## SCENARIO") {
			// Save previous scenario RFC 2119 status
			if in_scenario && current_scenario_has_rfc2119 {
				scenarios_with_rfc2119 += 1
			}
			in_scenario = true
			current_scenario_has_rfc2119 = false
			scenario_count += 1
			if first_scenario_line == 0 {
				first_scenario_line = i + 1
			}
		}

		if strings.has_prefix(upper, "**GIVEN**") || strings.has_prefix(upper, "GIVEN ") {
			has_given = true
			if in_scenario && has_rfc2119_keywords(trimmed) {
				current_scenario_has_rfc2119 = true
			}
		}
		if strings.has_prefix(upper, "**WHEN**") || strings.has_prefix(upper, "WHEN ") {
			has_when = true
			if in_scenario && has_rfc2119_keywords(trimmed) {
				current_scenario_has_rfc2119 = true
			}
		}
		if strings.has_prefix(upper, "**THEN**") || strings.has_prefix(upper, "THEN ") {
			has_then = true
			if in_scenario && has_rfc2119_keywords(trimmed) {
				current_scenario_has_rfc2119 = true
			}
		}
	}

	// Check last scenario
	if in_scenario && current_scenario_has_rfc2119 {
		scenarios_with_rfc2119 += 1
	}

	if !has_given {
		append(
			&errors,
			Validation_Error{file = "scenarios.md", line = 1, message = "No Given clauses found"},
		)
	}
	if !has_when {
		append(
			&errors,
			Validation_Error{file = "scenarios.md", line = 1, message = "No When clauses found"},
		)
	}
	if !has_then {
		append(
			&errors,
			Validation_Error{file = "scenarios.md", line = 1, message = "No Then clauses found"},
		)
	}

	// Check that scenarios use RFC 2119 keywords
	if scenario_count > 0 && scenarios_with_rfc2119 == 0 {
		append(
			&errors,
			Validation_Error {
				file = "scenarios.md",
				line = first_scenario_line,
				message = "Scenarios SHOULD use RFC 2119 keywords (MUST, SHOULD, MAY, etc.)",
			},
		)
	}

	return errors[:]
}

// Validate scenarios.md format
// Reads file and delegates to validate_scenarios_content for validation
validate_scenarios :: proc(scenarios_path: string) -> []Validation_Error {
	content, ok := os.read_entire_file(scenarios_path)
	if !ok {
		errors := make([dynamic]Validation_Error)
		append(&errors, Validation_Error{file = "scenarios.md", message = "Could not read file"})
		return errors[:]
	}
	defer delete(content)

	return validate_scenarios_content(string(content))
}

// Validate command handler
validate_cmd :: proc() {
	if len(os.args) < 3 {
		fmt.println("Usage: openclose validate <spec-name>")
		return
	}

	spec_name := os.args[2]
	spec_path, found := find_spec_path(spec_name)

	if !found {
		fmt.eprintfln("Spec not found: %s", spec_name)
		fmt.println("Run 'openclose summary' to see available specs")
		return
	}

	fmt.printfln("=== Validating spec: %s ===\n", spec_name)

	all_errors := make([dynamic]Validation_Error)
	defer delete(all_errors)
	has_all_files := true

	// Validate PRD.md
	prd_path := filepath.join({spec_path, "PRD.md"})
	if os.exists(prd_path) {
		prd_errors := validate_prd(prd_path)
		for err in prd_errors {
			append(&all_errors, err)
		}
		if len(prd_errors) == 0 {
			fmt.println("✓ PRD.md - Valid")
		} else {
			fmt.println("✗ PRD.md - Has errors")
		}
	} else {
		has_all_files = false
		fmt.println("✗ PRD.md - Missing")
	}

	// Validate tasks.md
	tasks_path := filepath.join({spec_path, "tasks.md"})
	if os.exists(tasks_path) {
		tasks_errors := validate_tasks(tasks_path)
		for err in tasks_errors {
			append(&all_errors, err)
		}
		if len(tasks_errors) == 0 {
			fmt.println("✓ tasks.md - Valid")
		} else {
			fmt.println("✗ tasks.md - Has errors")
		}
	} else {
		has_all_files = false
		fmt.println("✗ tasks.md - Missing")
	}

	// Validate scenarios.md
	scenarios_path := filepath.join({spec_path, "scenarios.md"})
	if os.exists(scenarios_path) {
		scenarios_errors := validate_scenarios(scenarios_path)
		for err in scenarios_errors {
			append(&all_errors, err)
		}
		if len(scenarios_errors) == 0 {
			fmt.println("✓ scenarios.md - Valid")
		} else {
			fmt.println("✗ scenarios.md - Has errors")
		}
	} else {
		has_all_files = false
		fmt.println("✗ scenarios.md - Missing")
	}

	// Print detailed errors
	if len(all_errors) > 0 {
		fmt.println("\nErrors found:")
		for err in all_errors {
			if err.line > 0 {
				fmt.printfln("  [%s:%d] %s", err.file, err.line, err.message)
			} else {
				fmt.printfln("  [%s] %s", err.file, err.message)
			}
		}
	} else if has_all_files {
		fmt.println("\n✓ All files valid!")
	} else {
		fmt.println("\n⚠ Some files are missing")
	}

	fmt.println("")
}
