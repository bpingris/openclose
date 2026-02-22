package main

import "core:strings"
import "core:testing"

find_agent_by_name :: proc(name: string) -> (^Agent_Info, bool) {
	for i in 0 ..< len(AGENTS) {
		if AGENTS[i].name == name {
			return &AGENTS[i], true
		}
	}

	return nil, false
}

find_command_by_filename :: proc(commands: []Command_File, filename: string) -> (^Command_File, bool) {
	for i in 0 ..< len(commands) {
		if commands[i].filename == filename {
			return &commands[i], true
		}
	}

	return nil, false
}

@(test)
test_agents_include_brainstorm_command :: proc(t: ^testing.T) {
	Expected_Command :: struct {
		agent_name: string,
		filename:   string,
		title:      string,
	}

	expected := []Expected_Command {
		{"opencode", "oc-brainstorm.md", "oc-brainstorm"},
		{"claude", "brainstorm.md", "brainstorm"},
		{"cursor", "cursor-brainstorm.md", "cursor-brainstorm"},
	}

	for entry in expected {
		agent, agent_ok := find_agent_by_name(entry.agent_name)
		testing.expect(t, agent_ok, "Expected agent is missing")
		if !agent_ok {
			continue
		}

		cmd, cmd_ok := find_command_by_filename(agent.commands, entry.filename)
		testing.expect(t, cmd_ok, "Expected brainstorm command file is missing")
		if !cmd_ok {
			continue
		}

		testing.expect_value(t, cmd.title, entry.title)
		testing.expect_value(t, cmd.prompt, BRAINSTORM_PROMPT)
	}
}

@(test)
test_brainstorm_prompt_contains_required_summary_schema :: proc(t: ^testing.T) {
 	required_sections := []string {
		"## Problem",
		"## Goals",
		"## Capabilities",
		"## Constraints",
		"## Non-Goals",
		"## Acceptance Signals",
		"## Risks",
		"## Open Questions",
		"## Proposed Specs",
		"## Transition to Spec",
	}

	for section in required_sections {
		testing.expect(t, strings.contains(BRAINSTORM_PROMPT, section), "Prompt is missing a required summary section")
	}
}

@(test)
test_brainstorm_prompt_contains_persistence_and_failure_guidance :: proc(t: ^testing.T) {
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, ".openclose/brainstorm/<session-slug>-<timestamp>.md"))
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, "Write the full markdown content in one pass to avoid partial files"))
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, "On write failure, report a clear actionable error"))
}

@(test)
test_brainstorm_prompt_documents_mvp_surface_decision :: proc(t: ^testing.T) {
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, "MVP scope decision"))
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, "Native `openclose brainstorm` CLI behavior is deferred for now"))
}

@(test)
test_brainstorm_prompt_uses_agent_handoff_language :: proc(t: ^testing.T) {
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, "implement spec <kebab-case-name>"))
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, "continue the conversation to refine or split specs"))
	testing.expect(t, !strings.contains(BRAINSTORM_PROMPT, "openclose create <kebab-case-name>"))
}

@(test)
test_brainstorm_prompt_supports_single_and_multi_spec_outcomes :: proc(t: ^testing.T) {
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, "one spec or multiple specs"))
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, "`optional-second-spec`"))
	testing.expect(t, strings.contains(BRAINSTORM_PROMPT, "If multiple specs are proposed"))
}
