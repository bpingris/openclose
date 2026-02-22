package main

import "core:fmt"
import "core:os"
import os2 "core:os/os2"
import "core:path/filepath"
import "core:strings"
import "core:testing"

run_openclose_command :: proc(
	project_root: string,
	work_dir: string,
	cmd_args: []string,
) -> (
	state: os2.Process_State,
	stdout: []byte,
	stderr: []byte,
	err: os2.Error,
) {
	src_path := filepath.join({project_root, "src"}, context.temp_allocator)

	command := make([dynamic]string, context.temp_allocator)
	append(&command, "odin")
	append(&command, "run")
	append(&command, src_path)
	append(&command, "--")
	for arg in cmd_args {
		append(&command, arg)
	}

	return os2.process_exec(
		os2.Process_Desc {
			working_dir = work_dir,
			command = command[:],
		},
		context.allocator,
	)
}

make_test_workspace :: proc(t: ^testing.T) -> string {
	workspace, err := os2.make_directory_temp("", "openclose-integration-*", context.allocator)
	testing.expect(t, err == nil, "Failed to create temporary workspace")
	if err != nil {
		return ""
	}

	return workspace
}

cleanup_test_workspace :: proc(path: string) {
	if len(path) == 0 {
		return
	}

	if os.exists(path) {
		_ = os2.remove_all(path)
	}
	delete(path)
}

write_text_file :: proc(path: string, content: string) -> os.Error {
	file, file_err := os.open(path, os.O_CREATE | os.O_WRONLY | os.O_TRUNC, 0o644)
	if file_err != nil {
		return file_err
	}
	defer os.close(file)

	_, write_err := os.write_string(file, content)
	return write_err
}

@(test)
test_integration_create_rejects_path_traversal_input :: proc(t: ^testing.T) {
	defer free_all(context.temp_allocator)

	project_root := os.get_current_directory(context.temp_allocator)
	workspace := make_test_workspace(t)
	defer cleanup_test_workspace(workspace)

	state, stdout, stderr, run_err := run_openclose_command(
		project_root,
		workspace,
		[]string{"create", "../../outside-spec"},
	)
	defer delete(stdout)
	defer delete(stderr)

	testing.expect(t, run_err == nil)
	testing.expect(t, state.exit_code == 0)
	testing.expect(t, strings.contains(string(stderr), "invalid spec name"))

	outside_path := filepath.join({workspace, "outside-spec"}, context.temp_allocator)
	specs_root := filepath.join({workspace, ".openclose", "specs"}, context.temp_allocator)
	testing.expect(t, !os.exists(outside_path), "Traversal path should not be created")
	testing.expect(t, !os.exists(specs_root), "Invalid create should not initialize specs directory")
}

@(test)
test_integration_archive_rejects_explicit_path_traversal :: proc(t: ^testing.T) {
	defer free_all(context.temp_allocator)

	project_root := os.get_current_directory(context.temp_allocator)
	workspace := make_test_workspace(t)
	defer cleanup_test_workspace(workspace)

	outside_target := filepath.join({workspace, "outside-target"}, context.temp_allocator)
	dir_err := make_directory_recursive(outside_target)
	testing.expect(t, dir_err == nil)

	prd_path := filepath.join({outside_target, "PRD.md"}, context.temp_allocator)
	write_err := write_text_file(prd_path, "# External PRD\n")
	testing.expect(t, write_err == nil)

	state, stdout, stderr, run_err := run_openclose_command(
		project_root,
		workspace,
		[]string{"archive", "specs/../../outside-target"},
	)
	defer delete(stdout)
	defer delete(stderr)

	testing.expect(t, run_err == nil)
	testing.expect(t, state.exit_code == 0)
	testing.expect(t, strings.contains(string(stderr), "Invalid path"))
	testing.expect(t, os.exists(outside_target), "External directory should not be removed")

	archive_path := filepath.join(
		{workspace, ".openclose", "archive", "specs", "outside-target"},
		context.temp_allocator,
	)
	testing.expect(t, !os.exists(archive_path), "Archive should not be created for invalid path")
}

@(test)
test_integration_summary_shows_phase_breakdown :: proc(t: ^testing.T) {
	defer free_all(context.temp_allocator)

	project_root := os.get_current_directory(context.temp_allocator)
	workspace := make_test_workspace(t)
	defer cleanup_test_workspace(workspace)

	create_state, create_stdout, create_stderr, create_err := run_openclose_command(
		project_root,
		workspace,
		[]string{"create", "my-spec"},
	)
	defer delete(create_stdout)
	defer delete(create_stderr)

	testing.expect(t, create_err == nil)
	testing.expect(t, create_state.exit_code == 0)

	summary_state, summary_stdout, summary_stderr, summary_err := run_openclose_command(
		project_root,
		workspace,
		[]string{"summary"},
	)
	defer delete(summary_stdout)
	defer delete(summary_stderr)

	summary_text := string(summary_stdout)
	testing.expect(t, summary_err == nil)
	testing.expect(t, summary_state.exit_code == 0)
	testing.expect(t, strings.contains(summary_text, "Phase 1: Foundation"))
	testing.expect(t, strings.contains(summary_text, "Phase 2: Implementation"))
	testing.expect(t, strings.contains(summary_text, "Phase 3: Polish"))
}

@(test)
test_integration_create_and_update_agent_commands_nested_paths :: proc(t: ^testing.T) {
	defer free_all(context.temp_allocator)

	workspace := make_test_workspace(t)
	defer cleanup_test_workspace(workspace)

	commands_dir := filepath.join({workspace, ".claude", "commands"}, context.temp_allocator)

	agent := Agent_Info {
		name = "integration",
		display_name = "Integration",
		commands_dir = commands_dir,
		subdirectory = "/openclose/",
		commands = []Command_File {
			{
				filename = "create.md",
				prompt = "integration test prompt",
				title = "create",
				description = "integration test command",
			},
		},
	}

	create_agent_commands(&agent)

	command_path := filepath.join(
		{workspace, ".claude", "commands", "openclose", "create.md"},
		context.temp_allocator,
	)
	testing.expect(t, os.exists(command_path), "Nested command path should be created")

	updated, skipped := update_agent_commands(&agent)
	testing.expect_value(t, updated, 0)
	testing.expect_value(t, skipped, 1)
}

@(test)
test_integration_opencode_brainstorm_command_generated :: proc(t: ^testing.T) {
	defer free_all(context.temp_allocator)

	workspace := make_test_workspace(t)
	defer cleanup_test_workspace(workspace)

	opencode_commands_dir := fmt.tprintf("%s/", filepath.join({workspace, ".opencode", "commands"}, context.temp_allocator))

	opencode_agent := AGENTS[0]
	opencode_agent.commands_dir = opencode_commands_dir
	opencode_agent.subdirectory = ""

	create_agent_commands(&opencode_agent)

	brainstorm_path := filepath.join(
		{workspace, ".opencode", "commands", "oc-brainstorm.md"},
		context.temp_allocator,
	)
	testing.expect(t, os.exists(brainstorm_path), "oc-brainstorm command file should be created")

	brainstorm_content, ok := os.read_entire_file(brainstorm_path)
	testing.expect(t, ok)
	if ok {
		defer delete(brainstorm_content)
		brainstorm_text := string(brainstorm_content)
		testing.expect(t, strings.contains(brainstorm_text, "MVP scope decision"))
		testing.expect(t, strings.contains(brainstorm_text, ".openclose/brainstorm/<session-slug>-<timestamp>.md"))
		testing.expect(t, strings.contains(brainstorm_text, "## Proposed Specs"))
		testing.expect(t, strings.contains(brainstorm_text, "implement spec <kebab-case-name>"))
		testing.expect(t, !strings.contains(brainstorm_text, "openclose create <kebab-case-name>"))
	}
}

@(test)
test_integration_update_refreshes_brainstorm_prompt_content :: proc(t: ^testing.T) {
	defer free_all(context.temp_allocator)

	workspace := make_test_workspace(t)
	defer cleanup_test_workspace(workspace)

	opencode_commands_path := filepath.join({workspace, ".opencode", "commands"}, context.temp_allocator)
	dir_err := make_directory_recursive(opencode_commands_path)
	testing.expect(t, dir_err == nil)

	stale_brainstorm_path := filepath.join(
		{workspace, ".opencode", "commands", "oc-brainstorm.md"},
		context.temp_allocator,
	)
	stale_content := "---\ntitle: oc-brainstorm\ndescription: stale\n---\n\nopenclose create <kebab-case-name>\n"
	write_err := write_text_file(stale_brainstorm_path, stale_content)
	testing.expect(t, write_err == nil)

	opencode_agent := AGENTS[0]
	opencode_agent.commands_dir = fmt.tprintf("%s/", opencode_commands_path)
	opencode_agent.subdirectory = ""

	updated, _ := update_agent_commands(&opencode_agent)
	testing.expect(t, updated > 0)

	updated_content, ok := os.read_entire_file(stale_brainstorm_path)
	testing.expect(t, ok)
	if ok {
		defer delete(updated_content)
		updated_text := string(updated_content)
		testing.expect(t, strings.contains(updated_text, "## Proposed Specs"))
		testing.expect(t, strings.contains(updated_text, "implement spec <kebab-case-name>"))
		testing.expect(t, !strings.contains(updated_text, "openclose create <kebab-case-name>"))
	}
}
