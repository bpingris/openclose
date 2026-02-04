package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

// Search_Result represents where an item was found
Search_Result :: struct {
	found_in_specs: bool,
	specs_path:     string,
}

// find_item searches for an item by name in specs/ directory
// Returns a SearchResult indicating where (if anywhere) the item was found
find_item :: proc(name: string) -> Search_Result {
	result := Search_Result {
		found_in_specs = false,
		specs_path     = "",
	}

	// Check in specs/
	specs_path := filepath.join({".openclose", "specs", name})
	if os.exists(specs_path) {
		result.found_in_specs = true
		result.specs_path = specs_path
	}

	return result
}

// Archive a spec by copying only PRD.md to the archive
archive_spec_prd_only :: proc(source_path: string, archive_dest: string) -> os.Error {
	// Check if PRD.md exists in source
	prd_source := filepath.join({source_path, "PRD.md"})
	if !os.exists(prd_source) {
		return os.General_Error.Not_Exist
	}

	// Create archive directory
	err := make_directory_recursive(archive_dest)
	if err != nil {
		return err
	}

	// Copy only PRD.md
	prd_dest := filepath.join({archive_dest, "PRD.md"})
	content, ok := os.read_entire_file(prd_source)
	if !ok {
		return os.General_Error.Not_Exist
	}

	file, file_err := os.open(prd_dest, os.O_CREATE | os.O_WRONLY | os.O_TRUNC, 0o644)
	if file_err != nil {
		return file_err
	}
	defer os.close(file)

	_, write_err := os.write(file, content)
	if write_err != nil {
		return write_err
	}

	return nil
}

// Archive command handler
archive_cmd :: proc() {
	if len(os.args) < 3 || os.args[2] == "help" || os.args[2] == "--help" || os.args[2] == "-h" {
		fmt.println("Usage: openclose archive <name>")
		fmt.println("       openclose archive specs/<spec-name>")
		fmt.println("")
		fmt.println("Archive a spec by copying only PRD.md to the archive")
		return
	}

	input := os.args[2]

	// Determine source path and archive destination
	full_source: string
	archive_dest: string
	display_path: string

	// Check if it's an explicit path (starts with specs/)
	if strings.has_prefix(input, "specs/") {
		// Use explicit path as provided
		full_source = filepath.join({".openclose", input})
		display_path = input

		if !os.exists(full_source) {
			fmt.eprintfln("Not found: '%s'", input)
			return
		}

		// Determine archive destination
		item_name := filepath.base(input)
		archive_dest = filepath.join({get_archive_specs_dir(), item_name})
	} else {
		// Bare name - search in specs/
		result := find_item(input)

		if result.found_in_specs {
			// Found in specs/
			full_source = result.specs_path
			display_path = fmt.tprintf("specs/%s", input)
			archive_dest = filepath.join({get_archive_specs_dir(), input})
		} else {
			// Not found
			fmt.eprintfln("Not found: '%s' (searched in specs/)", input)
			return
		}
	}

	// Check if destination already exists and remove it (for re-archiving scenarios)
	if os.exists(archive_dest) {
		err := remove_directory_recursive(archive_dest)
		if err != nil {
			fmt.eprintfln("Error removing existing archive: %s", err)
			return
		}
	}

	fmt.printfln("Archiving %s...", display_path)

	// Archive spec with PRD.md only
	err := archive_spec_prd_only(full_source, archive_dest)
	if err == os.General_Error.Not_Exist {
		fmt.eprintfln("Cannot archive spec: PRD.md not found in %s", display_path)
		return
	}
	if err != nil {
		fmt.eprintfln("Failed to archive spec: %s", err)
		return
	}

	// Remove the original
	err = remove_directory_recursive(full_source)
	if err != nil {
		fmt.eprintfln("Warning: archived but failed to remove original: %s", err)
		fmt.printfln("Archived to: %s", archive_dest)
		fmt.println("Please manually remove the original directory")
		return
	}

	fmt.printfln("✓ Archived (PRD.md only): %s -> %s", display_path, archive_dest)
}
