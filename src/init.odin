package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

// Initialize the .openclose directory
init_openclose :: proc() {
	dir_name := ".openclose"
	file_path := ".openclose/AGENTS.md"

	dir_err := os.make_directory(dir_name)

	if dir_err != nil {
		if dir_err != os.Platform_Error.EEXIST {
			fmt.eprintfln("error creating %s: %s", dir_name, dir_err)
			return
		}
	}

	// Create subdirectories
	specs_dir := get_specs_dir()
	epics_dir := get_epics_dir()
	archive_dir := get_archive_dir()
	archive_specs_dir := get_archive_specs_dir()
	archive_epics_dir := get_archive_epics_dir()

	os.make_directory(specs_dir)
	os.make_directory(epics_dir)
	os.make_directory(archive_dir)
	os.make_directory(archive_specs_dir)
	os.make_directory(archive_epics_dir)

	// Check if AGENTS.md already exists
	if os.exists(file_path) {
		fmt.println("AGENTS.md already exists")
	} else {
		file, file_err := os.open(file_path, os.O_CREATE | os.O_WRONLY | os.O_TRUNC, 0o644)
		if file_err != nil {
			fmt.eprintfln("error creating %s: %s", file_path, file_err)
			return
		}
		defer os.close(file)

		_, write_err := os.write_string(file, AGENTS_TEMPLATE)
		if write_err != nil {
			fmt.eprintfln("error writing to %s: %s", file_path, write_err)
			return
		}

		fmt.println("Initialized .openclose with AGENTS.md")
	}

	// Prompt for agent selection
	selected_agent := prompt_agent_selection()
	if selected_agent == nil {
		fmt.println("No agent selected, skipping command file creation")
		return
	}

	// Check if command files already exist
	existing_files := check_existing_command_files(selected_agent)
	if len(existing_files) > 0 {
		fmt.println("\nWarning: The following command files already exist:")
		for file in existing_files {
			fmt.printfln("  - %s", file)
		}
		fmt.println("\nCommand aborted. Please remove existing files or choose a different agent.")
		return
	}

	// Create agent command directory and files
	create_agent_commands(selected_agent)
}

// Prompt user to select an agent
prompt_agent_selection :: proc() -> ^Agent_Info {
	fmt.println("\nWhich AI agent are you using?")
	fmt.println()

	for agent, i in AGENTS {
		fmt.printfln("  %d. %s", i + 1, agent.display_name)
	}

	fmt.println()
	fmt.printf("Enter number (1-%d): ", len(AGENTS))

	// Read user input
	reader: bufio.Reader
	bufio.reader_init(&reader, os.stream_from_handle(os.stdin))

	buffer: [1024]byte
	n, err := bufio.reader_read(&reader, buffer[:])
	if err != nil || n == 0 {
		fmt.println("Error reading input")
		return nil
	}

	// Parse the input
	input := strings.trim_space(string(buffer[:n]))
	selection, ok := strconv.parse_int(input)
	if !ok || selection < 1 || selection > len(AGENTS) {
		fmt.printfln("Invalid selection. Please enter a number between 1 and %d", len(AGENTS))
		return nil
	}

	return &AGENTS[selection - 1]
}

// Check if any command files already exist for the selected agent
check_existing_command_files :: proc(agent: ^Agent_Info) -> []string {
	existing: [dynamic]string

	for cmd in agent.commands {
		file_path := fmt.tprintf("%s%s%s", agent.commands_dir, agent.subdirectory, cmd.filename)
		if os.exists(file_path) {
			append(&existing, file_path)
		}
	}

	return existing[:]
}

create_agent_commands :: proc(agent: ^Agent_Info) {
	dir_err := os.make_directory(agent.commands_dir)
	if dir_err != nil {
		if dir_err != os.Platform_Error.EEXIST {
			fmt.eprintfln("error creating %s: %s", agent.commands_dir, dir_err)
			return
		}
	}

	if len(agent.subdirectory) > 0 {
		subdir_path := fmt.tprintf("%s%s", agent.commands_dir, agent.subdirectory)
		subdir_err := os.make_directory(subdir_path)
		if subdir_err != nil {
			if subdir_err != os.Platform_Error.EEXIST {
				fmt.eprintfln("error creating %s: %s", subdir_path, subdir_err)
				return
			}
		}
	}

	// Create command files
	for cmd in agent.commands {
		file_path := fmt.tprintf("%s%s%s", agent.commands_dir, agent.subdirectory, cmd.filename)

		// Build command content with frontmatter and embedded prompt
		content := build_command_content(cmd)

		file, file_err := os.open(file_path, os.O_CREATE | os.O_WRONLY | os.O_TRUNC, 0o644)
		if file_err != nil {
			fmt.eprintfln("error creating %s: %s", file_path, file_err)
			continue
		}
		defer os.close(file)

		_, write_err := os.write_string(file, content)
		if write_err != nil {
			fmt.eprintfln("error writing to %s: %s", file_path, write_err)
			continue
		}

		fmt.printfln("Created %s", file_path)
	}

	fmt.println("\nAgent command files created successfully!")
}
