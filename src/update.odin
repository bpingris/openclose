package main

import "core:fmt"
import "core:os"

// Update command - regenerates agent command files with latest prompt content
update_cmd :: proc() {
	fmt.println("=== Updating agent command files ===\n")

	updated_count := 0
	skipped_count := 0

	for &agent in AGENTS {
		agent_updated, agent_skipped := update_agent_commands(&agent)
		updated_count += agent_updated
		skipped_count += agent_skipped
	}

	fmt.println("\n=== Update Complete ===")
	fmt.printfln("Updated: %d files", updated_count)
	if skipped_count > 0 {
		fmt.printfln("Skipped: %d files (no changes needed)", skipped_count)
	}
}

// Update command files for a specific agent
// Returns: (updated_count, skipped_count)
update_agent_commands :: proc(agent: ^Agent_Info) -> (int, int) {
	updated := 0
	skipped := 0

	// Check if this agent has any existing command files
	has_existing_files := false
	for cmd in agent.commands {
		file_path := fmt.tprintf("%s%s%s", agent.commands_dir, agent.subdirectory, cmd.filename)
		if os.exists(file_path) {
			has_existing_files = true
			break
		}
	}

	if !has_existing_files {
		return updated, skipped
	}

	fmt.printfln("Updating %s commands...", agent.display_name)

	// Ensure directories exist
	dir_err := os.make_directory(agent.commands_dir)
	if dir_err != nil && dir_err != os.Platform_Error.EEXIST {
		fmt.eprintfln("  Error creating directory %s: %s", agent.commands_dir, dir_err)
		return updated, skipped
	}

	if len(agent.subdirectory) > 0 {
		subdir_path := fmt.tprintf("%s%s", agent.commands_dir, agent.subdirectory)
		subdir_err := os.make_directory(subdir_path)
		if subdir_err != nil && subdir_err != os.Platform_Error.EEXIST {
			fmt.eprintfln("  Error creating directory %s: %s", subdir_path, subdir_err)
			return updated, skipped
		}
	}

	// Update each command file
	for cmd in agent.commands {
		file_path := fmt.tprintf("%s%s%s", agent.commands_dir, agent.subdirectory, cmd.filename)

		// Build new content
		new_content := build_command_content(cmd)

		// Check if file exists and needs updating
		if os.exists(file_path) {
			existing_content, ok := os.read_entire_file(file_path)
			if ok && string(existing_content) == new_content {
				// File exists and content is identical
				skipped += 1
				continue
			}
		}

		// Write the file
		file, file_err := os.open(file_path, os.O_CREATE | os.O_WRONLY | os.O_TRUNC, 0o644)
		if file_err != nil {
			fmt.eprintfln("  Error opening %s: %s", file_path, file_err)
			continue
		}
		defer os.close(file)

		_, write_err := os.write_string(file, new_content)
		if write_err != nil {
			fmt.eprintfln("  Error writing %s: %s", file_path, write_err)
			continue
		}

		if os.exists(file_path) {
			// File was updated
			fmt.printfln("  Updated %s", file_path)
		} else {
			// File was created
			fmt.printfln("  Created %s", file_path)
		}
		updated += 1
	}

	return updated, skipped
}
