package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

// Search_Result represents where an item was found
Search_Result :: struct {
	found_in_specs: bool,
	found_in_epics: bool,
	specs_path:     string,
	epics_path:     string,
}

// find_item searches for an item by name in both specs/ and epics/ directories
// Returns a SearchResult indicating where (if anywhere) the item was found
find_item :: proc(name: string) -> Search_Result {
	result := Search_Result {
		found_in_specs = false,
		found_in_epics = false,
		specs_path     = "",
		epics_path     = "",
	}

	// Check in specs/
	specs_path := filepath.join({".openclose", "specs", name})
	if os.exists(specs_path) {
		result.found_in_specs = true
		result.specs_path = specs_path
	}

	// Check in epics/
	epics_path := filepath.join({".openclose", "epics", name})
	if os.exists(epics_path) {
		result.found_in_epics = true
		result.epics_path = epics_path
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
		fmt.println("       openclose archive <path>")
		fmt.println("")
		fmt.println("Archive a spec or epic using one of these formats:")
		fmt.println(
			"  openclose archive <name>                   - Auto-detect and archive (searches specs/ and epics/)",
		)
		fmt.println("  openclose archive specs/<spec-name>        - Archive standalone spec (PRD.md only)")
		fmt.println("  openclose archive epics/<epic>/<spec>      - Archive epic spec (PRD.md only)")
		fmt.println("  openclose archive epics/<epic>             - Archive entire epic")
		fmt.println("")
		fmt.println("Archived specs only preserve PRD.md, epics preserve full structure")
		return
	}

	input := os.args[2]

	// Determine source path and archive destination
	full_source: string
	archive_dest: string
	display_path: string

	// Check if it's an explicit path (starts with specs/ or epics/)
	if strings.has_prefix(input, "specs/") || strings.has_prefix(input, "epics/") {
		// Use explicit path as provided
		full_source = filepath.join({".openclose", input})
		display_path = input

		if !os.exists(full_source) {
			fmt.eprintfln("Not found: '%s'", input)
			return
		}

		// Determine archive destination based on path structure
		item_name := filepath.base(input)

		if strings.has_prefix(input, "specs/") {
			// Standalone spec -> archive/specs/
			archive_dest = filepath.join({get_archive_specs_dir(), item_name})
		} else if strings.has_prefix(input, "epics/") {
			// Epic or epic spec -> archive/epics/
			parts := strings.split(input, "/")
			if len(parts) >= 2 {
				if len(parts) == 2 {
					// Archiving entire epic: epics/<epic>
					archive_dest = filepath.join({get_archive_epics_dir(), item_name})
				} else {
					// Archiving spec within epic: epics/<epic>/<spec>
					rest := strings.join(parts[1:], "/")
					archive_dest = filepath.join({get_archive_epics_dir(), rest})
				}
			}
		}
	} else {
		// Bare name - search in both specs/ and epics/
		result := find_item(input)

		if result.found_in_specs && result.found_in_epics {
			// Ambiguous - found in both locations
			fmt.eprintfln("Ambiguous name '%s' found in both specs/ and epics/", input)
			fmt.printfln(
				"Please specify using full path (e.g., specs/%s or epics/%s)",
				input,
				input,
			)
			return
		} else if result.found_in_specs {
			// Found in specs/
			full_source = result.specs_path
			display_path = fmt.tprintf("specs/%s", input)
			archive_dest = filepath.join({get_archive_specs_dir(), input})
		} else if result.found_in_epics {
			// Found in epics/
			full_source = result.epics_path
			display_path = fmt.tprintf("epics/%s", input)
			archive_dest = filepath.join({get_archive_epics_dir(), input})
		} else {
			// Not found in either location
			fmt.eprintfln("Not found: '%s' (searched in specs/ and epics/)", input)
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

	// Determine if this is a spec (PRD.md only) or epic (full copy)
	is_spec := false
	if strings.has_prefix(display_path, "specs/") {
		is_spec = true
	} else if strings.has_prefix(display_path, "epics/") {
		// Check if it's a spec within an epic (epics/<epic>/<spec>) or an epic itself
		parts := strings.split(display_path, "/")
		if len(parts) >= 3 {
			// It's a spec within an epic: epics/<epic>/<spec>
			is_spec = true
		}
		// If len(parts) == 2, it's an epic itself: epics/<epic>
	}

	fmt.printfln("Archiving %s...", display_path)

	if is_spec {
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
	} else {
		// Archive epic with full directory copy
		parent_dir := filepath.dir(archive_dest)
		if parent_dir != "" && parent_dir != "." {
			err := make_directory_recursive(parent_dir)
			if err != nil {
				fmt.eprintfln("Error creating archive directory: %s", err)
				return
			}
		}

		err := copy_directory(full_source, archive_dest)
		if err != nil {
			fmt.eprintfln("Failed to copy to archive: %s", err)
			return
		}
	}

	// Remove the original
	err := remove_directory_recursive(full_source)
	if err != nil {
		fmt.eprintfln("Warning: archived but failed to remove original: %s", err)
		fmt.printfln("Archived to: %s", archive_dest)
		fmt.println("Please manually remove the original directory")
		return
	}

	if is_spec {
		fmt.printfln("✓ Archived (PRD.md only): %s -> %s", display_path, archive_dest)
	} else {
		fmt.printfln("✓ Archived: %s -> %s", display_path, archive_dest)
	}
}
