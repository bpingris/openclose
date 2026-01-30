package main

import "core:fmt"
import "core:os"

print_help :: proc() {
	fmt.println("openclose - CLI tool for organizing specs and PRDs")
	fmt.println("")
	fmt.println("Commands:")
	fmt.println("  init                          Initialize .openclose directory with AGENTS.md")
	fmt.println("  create <name>                 Create a new spec")
	fmt.println(
		"  create <name> --epic <epic>   Create a new spec attached to an epic (creates epic if needed)",
	)
	fmt.println("  epic <name>                   Create a new epic")
	fmt.println("  view                          View all specs and epics")
	fmt.println("  summary                       Show progress summary of all specs and epics")
	fmt.println("  validate <name>               Validate a spec's file formats")
	fmt.println(
		"  archive <path>                Archive specs/epics (e.g., specs/name or epics/epic/name)",
	)
	fmt.println("  help                          Show this help message")
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
	case "epic":
		epic_cmd()
	case "view":
		view_cmd()
	case "summary":
		summary_cmd()
	case "validate":
		validate_cmd()
	case "archive":
		archive_cmd()
	case "help", "--help", "-h":
		print_help()
	case:
		fmt.printfln("Unknown command: %s", command)
		print_help()
	}
}
