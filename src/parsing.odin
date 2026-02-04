package main

import "core:os"
import "core:path/filepath"
import "core:strings"

// Parse tasks content string to extract completion stats
// This function can be unit tested without file I/O
parse_tasks_content :: proc(
	content: string,
) -> (
	total: int,
	completed: int,
	phases: []Phase_Info,
) {
	phases_list := make([dynamic]Phase_Info, context.temp_allocator)
	lines := strings.split_lines(content, context.temp_allocator)
	current_phase: Phase_Info
	in_phase := false

	for line in lines {
		trimmed := strings.trim_space(line)

		// Check if we're entering a phase section (## Phase X or similar)
		if strings.has_prefix(trimmed, "## ") && !strings.has_prefix(trimmed, "# Tasks") {
			// Save previous phase if we were in one
			if in_phase && current_phase.name != "" {
				append(&phases_list, current_phase)
			}

			// Start new phase
			current_phase = Phase_Info {
				name            = strings.trim_prefix(trimmed, "## "),
				total_tasks     = 0,
				completed_tasks = 0,
			}
			in_phase = true
			continue
		}

		// Count checkboxes in phase
		if in_phase {
			if strings.has_prefix(trimmed, "- [ ]") ||
			   strings.has_prefix(trimmed, "- [x]") ||
			   strings.has_prefix(trimmed, "- [X]") {
				current_phase.total_tasks += 1
				total += 1
				if strings.has_prefix(trimmed, "- [x]") || strings.has_prefix(trimmed, "- [X]") {
					current_phase.completed_tasks += 1
					completed += 1
				}
			}
		}
	}

	// Don't forget the last phase
	if in_phase && current_phase.name != "" {
		append(&phases_list, current_phase)
	}

	return total, completed, phases_list[:]
}

// Parse tasks.md file to extract completion stats
// Reads file and delegates to parse_tasks_content for parsing
parse_tasks_for_completion :: proc(
	tasks_path: string,
) -> (
	total: int,
	completed: int,
	phases: []Phase_Info,
) {
	content, ok := os.read_entire_file(tasks_path)
	if !ok {
		return 0, 0, nil
	}
	defer delete(content)

	total, completed, phases = parse_tasks_content(string(content))
	return total, completed, phases
}

// Collect spec information
collect_spec_info :: proc(spec_path: string, spec_name: string) -> Spec_Info {
	tasks_path := filepath.join({spec_path, "tasks.md"}, context.temp_allocator)
	prd_path := filepath.join({spec_path, "PRD.md"}, context.temp_allocator)
	defer free_all(context.temp_allocator)

	total, completed, phases := 0, 0, make([]Phase_Info, 0)

	// Try tasks.md first, fall back to PRD.md for backward compatibility
	if os.exists(tasks_path) {
		total, completed, phases = parse_tasks_for_completion(tasks_path)
	} else if os.exists(prd_path) {
		// Legacy: parse PRD.md for old specs
		total, completed, _ = parse_tasks_for_completion(prd_path)
	}

	return Spec_Info {
		name = spec_name,
		phases = phases,
		total_criteria = total,
		completed_criteria = completed,
		done = total > 0 && completed == total,
		path = spec_path,
	}
}

// Recursively collect specs from a directory
collect_specs_recursive :: proc(dir: string, specs: ^[dynamic]Spec_Info) {
	fd, open_err := os.open(dir, os.O_RDONLY)
	if open_err != nil {
		return
	}
	defer os.close(fd)

	files, read_err := os.read_dir(fd, 0)
	if read_err != nil {
		return
	}

	for f in files {
		if f.is_dir {
			spec_path := filepath.join({dir, f.name})
			prd_path := filepath.join({spec_path, "PRD.md"})
			tasks_path := filepath.join({spec_path, "tasks.md"})

			if os.exists(prd_path) || os.exists(tasks_path) {
				// This is a spec directory
				info := collect_spec_info(spec_path, f.name)
				append(specs, info)
			} else {
				// This might be a parent directory, recurse
				collect_specs_recursive(spec_path, specs)
			}
		}
	}
}
