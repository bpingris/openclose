package main

import "core:fmt"
import "core:os"
import "core:strings"

print_help :: proc() {
	sb, sb_err := strings.builder_make()
	if sb_err != nil {
		fmt.eprintfln("Failed to create strings.Builder: %v", sb_err)
	}

	defer strings.builder_destroy(&sb)

	strings.write_string(&sb, "openclose - CLI tool for organizing specs and PRDs\n")
	strings.write_string(&sb, "\n")
	strings.write_string(&sb, "Commands:\n")
	strings.write_string(
		&sb,
		"  init                          Initialize .openclose directory with AGENTS.md\n",
	)
	strings.write_string(&sb, "  create <name>                 Create a new spec\n")
	strings.write_string(&sb, "  summary                       Show all specs with progress\n")
	strings.write_string(&sb, "  validate <name>               Validate a spec's file formats\n")
	strings.write_string(
		&sb,
		"  archive <path>                Archive a spec (e.g., specs/name)\n",
	)
	strings.write_string(
		&sb,
		"  update                        Update agent command files with latest prompts\n",
	)
	strings.write_string(&sb, "  version                       Show the current version\n")
	strings.write_string(&sb, "  help                          Show this help message\n")

	fmt.println(strings.to_string(sb))
}


main :: proc() {
	if len(os.args) < 2 {
		print_help()
		return
	}


	command := os.args[1]

	switch command {
	case "init":
		init_openclose()
	case "create":
		create_cmd()
	case "summary":
		summary_cmd()
	case "validate":
		validate_cmd()
	case "archive":
		archive_cmd()
	case "update":
		update_cmd()
	case "version":
		version_cmd()
	case "help", "--help", "-h":
		print_help()
	case:
		fmt.printfln("Unknown command: %s", command)
		print_help()
	}
}
