package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

// Find a spec by name
find_spec_path :: proc(spec_name: string) -> (string, bool) {
	spec_slug := slugify(spec_name)

	// Check standalone specs
	standalone_path := filepath.join({get_specs_dir(), spec_slug})
	if os.exists(standalone_path) {
		return standalone_path, true
	}

	// Check in epics
	epics_dir := get_epics_dir()
	if os.exists(epics_dir) {
		fd, err := os.open(epics_dir, os.O_RDONLY)
		if err == nil {
			defer os.close(fd)
			files, _ := os.read_dir(fd, 0)
			for f in files {
				if f.is_dir {
					epic_spec_path := filepath.join({epics_dir, f.name, spec_slug})
					if os.exists(epic_spec_path) {
						return epic_spec_path, true
					}
				}
			}
		}
	}

	return "", false
}

// RFC 2119 keywords for requirement validation
RFC2119_KEYWORDS :: []string{"MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", "OPTIONAL"}

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

// Validate PRD.md format
validate_prd :: proc(prd_path: string) -> []Validation_Error {
	errors := make([dynamic]Validation_Error)

	content, ok := os.read_entire_file(prd_path)
	if !ok {
		append(&errors, Validation_Error{file = "PRD.md", message = "Could not read file"})
		return errors[:]
	}

	text := string(content)

	// Check required sections
	required_sections := []string{"## Problem Statement", "## Requirements", "## Technical Notes"}
	for section in required_sections {
		if !strings.contains(text, section) {
			append(
				&errors,
				Validation_Error {
					file = "PRD.md",
					message = fmt.tprintf("Missing required section: %s", section),
				},
			)
		}
	}

	// Check for title (first line should be # Something)
	lines := strings.split_lines(text)
	if len(lines) > 0 {
		first_line := strings.trim_space(lines[0])
		if !strings.has_prefix(first_line, "# ") {
			append(
				&errors,
				Validation_Error {
					file = "PRD.md",
					message = "First line should be a title (e.g., # Spec Name)",
				},
			)
		}
	} else {
		append(&errors, Validation_Error{file = "PRD.md", message = "File is empty"})
	}

	// Check for RFC 2119 keywords in Requirements section
	if strings.contains(text, "## Requirements") {
		// Find the Requirements section content
		req_start := strings.index(text, "## Requirements")
		if req_start != -1 {
			req_section := text[req_start:]
			// Find the end of this section (next ## or end of file)
			next_section := strings.index(req_section[1:], "## ")
			if next_section != -1 {
				req_section = req_section[:next_section+1]
			}
			
			if !has_rfc2119_keywords(req_section) {
				append(
					&errors,
					Validation_Error {
						file = "PRD.md",
						message = "Requirements section SHOULD use RFC 2119 keywords (MUST, SHOULD, MAY, etc.)",
					},
				)
			}
		}
	}

	return errors[:]
}

// Validate tasks.md format
validate_tasks :: proc(tasks_path: string) -> []Validation_Error {
	errors := make([dynamic]Validation_Error)

	content, ok := os.read_entire_file(tasks_path)
	if !ok {
		append(&errors, Validation_Error{file = "tasks.md", message = "Could not read file"})
		return errors[:]
	}

	text := string(content)
	lines := strings.split_lines(text)

	has_phases := false
	has_checkboxes := false
	task_count := 0
	tasks_with_rfc2119 := 0

	for line in lines {
		trimmed := strings.trim_space(line)

		// Check for phase headers
		if strings.has_prefix(trimmed, "## ") && !strings.has_prefix(trimmed, "# Tasks") {
			has_phases = true
		}

		// Check for checkboxes and RFC 2119 keywords
		if strings.has_prefix(trimmed, "- [ ]") ||
		   strings.has_prefix(trimmed, "- [x]") ||
		   strings.has_prefix(trimmed, "- [X]") {
			has_checkboxes = true
			task_count += 1
			
			// Extract task description (after the checkbox)
			task_desc := trimmed
			if strings.has_prefix(trimmed, "- [ ]") {
				task_desc = trimmed[5:]
			} else if strings.has_prefix(trimmed, "- [x]") || strings.has_prefix(trimmed, "- [X]") {
				task_desc = trimmed[5:]
			}
			task_desc = strings.trim_space(task_desc)
			
			if has_rfc2119_keywords(task_desc) {
				tasks_with_rfc2119 += 1
			}
		}
	}

	if !has_phases {
		append(
			&errors,
			Validation_Error {
				file = "tasks.md",
				message = "Missing phase sections (e.g., ## Phase 1: Foundation)",
			},
		)
	}

	if !has_checkboxes {
		append(
			&errors,
			Validation_Error {
				file = "tasks.md",
				message = "No task checkboxes found (format: - [ ] Task description)",
			},
		)
	}

	// Check that tasks use RFC 2119 keywords
	if task_count > 0 && tasks_with_rfc2119 == 0 {
		append(
			&errors,
			Validation_Error {
				file = "tasks.md",
				message = "Tasks SHOULD use RFC 2119 keywords (MUST, SHOULD, MAY, etc.)",
			},
		)
	}

	return errors[:]
}

// Validate scenarios.md format
validate_scenarios :: proc(scenarios_path: string) -> []Validation_Error {
	errors := make([dynamic]Validation_Error)

	content, ok := os.read_entire_file(scenarios_path)
	if !ok {
		append(&errors, Validation_Error{file = "scenarios.md", message = "Could not read file"})
		return errors[:]
	}

	text := string(content)
	lines := strings.split_lines(text)

	has_given := false
	has_when := false
	has_then := false
	scenario_count := 0
	scenarios_with_rfc2119 := 0
	in_scenario := false
	current_scenario_has_rfc2119 := false

	for line in lines {
		trimmed := strings.trim_space(line)
		upper := strings.to_upper(trimmed)

		// Check for scenario headers (### Scenario)
		if strings.has_prefix(upper, "### SCENARIO") || strings.has_prefix(upper, "## SCENARIO") {
			// Save previous scenario RFC 2119 status
			if in_scenario && current_scenario_has_rfc2119 {
				scenarios_with_rfc2119 += 1
			}
			in_scenario = true
			current_scenario_has_rfc2119 = false
			scenario_count += 1
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
			Validation_Error{file = "scenarios.md", message = "No Given clauses found"},
		)
	}
	if !has_when {
		append(&errors, Validation_Error{file = "scenarios.md", message = "No When clauses found"})
	}
	if !has_then {
		append(&errors, Validation_Error{file = "scenarios.md", message = "No Then clauses found"})
	}

	// Check that scenarios use RFC 2119 keywords
	if scenario_count > 0 && scenarios_with_rfc2119 == 0 {
		append(
			&errors,
			Validation_Error {
				file = "scenarios.md",
				message = "Scenarios SHOULD use RFC 2119 keywords (MUST, SHOULD, MAY, etc.)",
			},
		)
	}

	return errors[:]
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
		fmt.println("Run 'openclose view' to see available specs")
		return
	}

	fmt.printfln("=== Validating spec: %s ===\n", spec_name)

	all_errors := make([dynamic]Validation_Error)
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
			fmt.printfln("  [%s] %s", err.file, err.message)
		}
	} else if has_all_files {
		fmt.println("\n✓ All files valid!")
	} else {
		fmt.println("\n⚠ Some files are missing")
	}

	fmt.println("")
}
