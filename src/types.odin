package main

// Data structures

Phase_Info :: struct {
	name: string,
	total_tasks: int,
	completed_tasks: int,
}

Spec_Info :: struct {
	name: string,
	phases: []Phase_Info,
	total_criteria: int,
	completed_criteria: int,
	done: bool,
	path: string,
}

Epic_Info :: struct {
	name: string,
	specs: []Spec_Info,
	total_criteria: int,
	completed_criteria: int,
}

Validation_Error :: struct {
	file: string,
	message: string,
}

// Agent configuration for command file generation
Agent_Info :: struct {
	name: string,
	display_name: string,
	commands_dir: string,
	file_prefix: string,
}

// Supported agents
AGENTS := []Agent_Info{
	{"opencode", "OpenCode", ".opencode/commands/", "oc"},
	{"claude", "Claude Code", ".claude/commands/", "claude"},
	{"cursor", "Cursor", ".cursor/commands/", "cursor"},
}
