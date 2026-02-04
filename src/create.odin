package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

// Create a new spec
create_spec :: proc(name: string) {
	spec_slug := slugify(name)
	defer delete(spec_slug)

	spec_dir := filepath.join({get_specs_dir(), spec_slug})

	// Create directory recursively
	dir_err := make_directory_recursive(spec_dir)
	if dir_err != nil {
		fmt.eprintfln("error creating directory %s: %s", spec_dir, dir_err)
		return
	}

	// Create PRD.md
	prd_path := filepath.join({spec_dir, "PRD.md"})
	file, file_err := os.open(prd_path, os.O_CREATE | os.O_WRONLY | os.O_TRUNC, 0o644)
	if file_err != nil {
		fmt.eprintfln("error creating %s: %s", prd_path, file_err)
		return
	}
	defer os.close(file)

	content, _ := strings.replace(SPEC_TEMPLATE, "{name}", name, 1)
	content, _ = strings.replace(content, "{date}", current_date(), 1)

	_, write_err := os.write_string(file, content)
	if write_err != nil {
		fmt.eprintfln("error writing to %s: %s", prd_path, write_err)
		return
	}

	// Create tasks.md
	tasks_path := filepath.join({spec_dir, "tasks.md"})
	tasks_file, tasks_err := os.open(tasks_path, os.O_CREATE | os.O_WRONLY | os.O_TRUNC, 0o644)
	if tasks_err != nil {
		fmt.eprintfln("error creating %s: %s", tasks_path, tasks_err)
		return
	}
	defer os.close(tasks_file)

	tasks_content, _ := strings.replace(TASKS_TEMPLATE, "{name}", name, 1)
	_, tasks_write_err := os.write_string(tasks_file, tasks_content)
	if tasks_write_err != nil {
		fmt.eprintfln("error writing to %s: %s", tasks_path, tasks_write_err)
		return
	}

	// Create scenarios.md
	scenarios_path := filepath.join({spec_dir, "scenarios.md"})
	scenarios_file, scenarios_err := os.open(
		scenarios_path,
		os.O_CREATE | os.O_WRONLY | os.O_TRUNC,
		0o644,
	)
	if scenarios_err != nil {
		fmt.eprintfln("error creating %s: %s", scenarios_path, scenarios_err)
		return
	}
	defer os.close(scenarios_file)

	scenarios_content, _ := strings.replace(SCENARIOS_TEMPLATE, "{name}", name, 1)
	_, scenarios_write_err := os.write_string(scenarios_file, scenarios_content)
	if scenarios_write_err != nil {
		fmt.eprintfln("error writing to %s: %s", scenarios_path, scenarios_write_err)
		return
	}

	fmt.printfln("Created spec: %s at %s", name, spec_dir)
}

// Create command handler
create_cmd :: proc() {
	if len(os.args) < 3 {
		fmt.println("Usage: openclose create <name>")
		return
	}

	name := os.args[2]
	create_spec(name)
}
