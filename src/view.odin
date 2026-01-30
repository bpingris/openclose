package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

// Check if any epics exist
epics_exist :: proc() -> bool {
	epics_dir := get_epics_dir()
	if !os.exists(epics_dir) {
		return false
	}

	fd, err := os.open(epics_dir, os.O_RDONLY)
	if err != nil {
		return false
	}
	defer os.close(fd)

	files, read_err := os.read_dir(fd, 0)
	if read_err != nil {
		return false
	}

	for f in files {
		if is_directory(f.mode) {
			return true
		}
	}

	return false
}

// Collect spec directories in an epic
collect_epic_specs :: proc(epic_path: string) -> []string {
	specs := make([dynamic]string)

	fd, err := os.open(epic_path, os.O_RDONLY)
	if err != nil {
		return specs[:]
	}
	defer os.close(fd)

	files, read_err := os.read_dir(fd, 0)
	if read_err != nil {
		return specs[:]
	}

	for f in files {
		if is_directory(f.mode) {
			spec_path := filepath.join({epic_path, f.name})
			prd_path := filepath.join({spec_path, "PRD.md"})
			tasks_path := filepath.join({spec_path, "tasks.md"})

			if os.exists(prd_path) || os.exists(tasks_path) {
				append(&specs, f.name)
			}
		}
	}

	return specs[:]
}

// Update the Related Specs section in epic.md if it exists
update_epic_related_specs :: proc(epic_path: string) -> bool {
	epic_md_path := filepath.join({epic_path, "epic.md"})

	if !os.exists(epic_md_path) {
		return false
	}

	content, ok := os.read_entire_file(epic_md_path)
	if !ok {
		return false
	}

	text := string(content)

	// Check if file has ## Related Specs section
	if !strings.contains(text, "## Related Specs") {
		return false
	}

	// Get list of specs in this epic
	specs := collect_epic_specs(epic_path)

	if len(specs) == 0 {
		return false
	}

	// Build the new Related Specs section
	specs_section := "## Related Specs\n"
	for spec in specs {
		specs_section = fmt.tprintf("%s- [%s](./%s/)\n", specs_section, spec, spec)
	}

	// Find and replace the Related Specs section
	lines := strings.split_lines(text)
	new_lines := make([dynamic]string)
	in_related_specs := false
	found_section := false

	for line in lines {
		trimmed := strings.trim_space(line)

		// Check if we're entering the Related Specs section
		if trimmed == "## Related Specs" {
			found_section = true
			in_related_specs = true
			append(&new_lines, "## Related Specs")
			// Add the auto-generated specs
			for spec in specs {
				append(&new_lines, fmt.tprintf("- [%s](./%s/)", spec, spec))
			}
			continue
		}

		// Check if we're leaving the section (next ## header)
		if in_related_specs && strings.has_prefix(trimmed, "##") {
			in_related_specs = false
		}

		// Skip lines that were part of the old Related Specs section
		if in_related_specs {
			continue
		}

		append(&new_lines, line)
	}

	if !found_section {
		return false
	}

	// Write the updated content back
	new_content := strings.join(new_lines[:], "\n")

	file, err := os.open(epic_md_path, os.O_WRONLY | os.O_TRUNC, 0o644)
	if err != nil {
		return false
	}
	defer os.close(file)

	_, write_err := os.write_string(file, new_content)
	if write_err != nil {
		return false
	}

	return true
}

// Recursively view specs
view_specs_recursive :: proc(dir: string, prefix: string) {
	fd, err := os.open(dir, os.O_RDONLY)
	if err != nil {
		return
	}
	defer os.close(fd)

	files, read_err := os.read_dir(fd, 0)
	if read_err != nil {
		return
	}

	for f in files {
		if is_directory(f.mode) {
			fmt.printfln("%s%s/", prefix, f.name)
			view_specs_recursive(filepath.join({dir, f.name}), fmt.tprintf("%s  ", prefix))
		} else if f.name == "PRD.md" {
			// Read title from PRD
			prd_path := filepath.join({dir, f.name})
			content, ok := os.read_entire_file(prd_path)
			if ok && len(content) > 2 {
				// Get first line as title
				lines := strings.split_lines(string(content))
				if len(lines) > 0 && strings.has_prefix(lines[0], "# ") {
					title := strings.trim_prefix(lines[0], "# ")
					fmt.printfln("%s  -> %s", prefix, title)
				}
			}
		}
	}
}

// View command handler
view_cmd :: proc() {
	if !os.exists(".openclose") {
		fmt.println("No .openclose directory found. Run 'openclose init' first.")
		return
	}

	specs_dir := get_specs_dir()
	epics_dir := get_epics_dir()

	fmt.println("=== OpenClose Specs ===\n")

	// Show standalone specs
	if os.exists(specs_dir) {
		fmt.println("Standalone Specs:")
		view_specs_recursive(specs_dir, "  ")
	}

	// Show epics and their specs
	if os.exists(epics_dir) && epics_exist() {
		fmt.println("\nEpics:")
		fd, err := os.open(epics_dir, os.O_RDONLY)
		if err == nil {
			defer os.close(fd)
			files, _ := os.read_dir(fd, 0)
			for f in files {
				if is_directory(f.mode) {
					fmt.printfln("  %s/", f.name)
					epic_path := filepath.join({epics_dir, f.name})
					view_specs_recursive(epic_path, "    ")
					update_epic_related_specs(epic_path)
				}
			}
		}
	}
}
