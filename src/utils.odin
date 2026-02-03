package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:time"
import "core:unicode"

// Directory path helpers
get_specs_dir :: proc() -> string {
	return ".openclose/specs"
}

get_epics_dir :: proc() -> string {
	return ".openclose/epics"
}

get_archive_dir :: proc() -> string {
	return ".openclose/archive"
}

get_archive_specs_dir :: proc() -> string {
	return ".openclose/archive/specs"
}

get_archive_epics_dir :: proc() -> string {
	return ".openclose/archive/epics"
}

// String utilities
current_date :: proc() -> string {
	now := time.now()
	return fmt.tprintf("%d-%02d-%02d", time.year(now), time.month(now), time.day(now))
}

slugify :: proc(name: string) -> string {
	sb := strings.builder_make()

	defer strings.builder_destroy(&sb)

	for r in name {
		switch r {
		case ' ', '_':
			strings.write_rune(&sb, '-')
		case:
			strings.write_rune(&sb, unicode.to_lower(r))
		}
	}

	return strings.clone(strings.to_string(sb))
}

make_directory_recursive :: proc(path: string) -> os.Error {
	if os.exists(path) {
		return nil
	}

	parent := filepath.dir(path)
	if parent != "" && parent != "." && parent != "/" {
		err := make_directory_recursive(parent)
		if err != nil {
			return err
		}
	}

	return os.make_directory(path)
}

// Simple recursive copy of a directory
copy_directory :: proc(src: string, dst: string) -> os.Error {
	defer free_all(context.temp_allocator)

	err := make_directory_recursive(dst)
	if err != nil {
		return err
	}

	// Open source directory
	fd, fd_err := os.open(src, os.O_RDONLY)
	if fd_err != nil {
		return fd_err
	}
	defer os.close(fd)

	// Read entries
	entries, entries_err := os.read_dir(fd, 0)
	if entries_err != nil {
		return entries_err
	}

	// Copy each entry
	for entry in entries {
		src_path := filepath.join({src, entry.name}, context.temp_allocator)
		dst_path := filepath.join({dst, entry.name}, context.temp_allocator)

		if entry.is_dir {
			copy_err := copy_directory(src_path, dst_path)
			if copy_err != nil {
				return copy_err
			}
		} else {
			content, ok := os.read_entire_file(src_path, context.temp_allocator)
			if !ok {
				return os.General_Error.Not_Exist
			}

			file, file_err := os.open(dst_path, os.O_CREATE | os.O_WRONLY | os.O_TRUNC, 0o644)
			if file_err != nil {
				return file_err
			}
			defer os.close(file)

			_, write_err := os.write(file, content)
			if write_err != nil {
				return write_err
			}
		}
	}

	return nil
}

// Remove directory and all its contents
remove_directory_recursive :: proc(path: string) -> os.Error {
	// Open directory
	fd, fd_err := os.open(path, os.O_RDONLY)
	if fd_err != nil {
		return fd_err
	}
	defer os.close(fd)

	// Read entries
	entries, entries_err := os.read_dir(fd, 0)
	if entries_err != nil {
		return entries_err
	}

	// Remove each entry
	for entry in entries {
		entry_path := filepath.join({path, entry.name})

		if entry.is_dir {
			// Recursively remove subdirectory
			remove_err := remove_directory_recursive(entry_path)
			if remove_err != nil {
				return remove_err
			}
		} else {
			// Remove file
			remove_err := os.remove(entry_path)
			if remove_err != nil {
				return remove_err
			}
		}
	}

	// Remove the now-empty directory using os.remove (works for empty dirs on Unix)
	return os.remove(path)
}

// Build the complete command file content with frontmatter and embedded prompt
build_command_content :: proc(cmd: Command_File) -> string {
	// Build frontmatter and combine with embedded prompt
	return fmt.tprintf(
		"---\ntitle: %s\ndescription: %s\n---\n\n%s",
		cmd.title,
		cmd.description,
		cmd.prompt,
	)
}
