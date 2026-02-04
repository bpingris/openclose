package main

// Data structures

Phase_Info :: struct {
	name:            string,
	total_tasks:     int,
	completed_tasks: int,
}

Spec_Info :: struct {
	name:               string,
	phases:             []Phase_Info,
	total_criteria:     int,
	completed_criteria: int,
	done:               bool,
	path:               string,
}

Validation_Error :: struct {
	file:    string,
	message: string,
}

// Command file configuration
Command_File :: struct {
	filename:    string,
	prompt:      string,
	title:       string,
	description: string,
}

// Agent configuration for command file generation
Agent_Info :: struct {
	name:         string,
	display_name: string,
	commands_dir: string,
	subdirectory: string, // Optional subdirectory (empty if none)
	commands:     []Command_File,
}

// Supported agents
AGENTS := []Agent_Info {
	{
		"opencode",
		"OpenCode",
		".opencode/commands/",
		"",
		[]Command_File {
			{"oc-create.md", CREATE_PROMPT, "oc-create", "Create a new spec using openclose cli"},
			{"oc-impl.md", IMPL_PROMPT, "oc-impl", "Implement a given spec"},
			{"oc-archive.md", ARCHIVE_PROMPT, "oc-archive", "Archive a given spec"},
		},
	},
	{
		"claude",
		"Claude Code",
		".claude/commands/",
		"openclose/",
		[]Command_File {
			{"create.md", CREATE_PROMPT, "create", "Create a new spec using openclose cli"},
			{"impl.md", IMPL_PROMPT, "impl", "Implement a given spec"},
			{"archive.md", ARCHIVE_PROMPT, "archive", "Archive a given spec"},
		},
	},
	{
		"cursor",
		"Cursor",
		".cursor/commands/",
		"",
		[]Command_File {
			{
				"cursor-create.md",
				CREATE_PROMPT,
				"cursor-create",
				"Create a new spec using openclose cli",
			},
			{"cursor-impl.md", IMPL_PROMPT, "cursor-impl", "Implement a given spec"},
			{"cursor-archive.md", ARCHIVE_PROMPT, "cursor-archive", "Archive a given spec"},
		},
	},
}
