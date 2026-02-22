# openclose

A CLI tool for organizing software specifications, PRDs (Product Requirements Documents), and implementation tracking.

## Overview

openclose helps development teams manage their project specifications through a structured workflow:

1. **Create specs** - Define features with PRD, tasks, and test scenarios
2. **Implement** - Follow the spec tasks to build features
3. **Validate** - Ensure specs meet formatting requirements
4. **Archive** - Clean up completed work

## Installation

### Using Homebrew (Recommended)

The easiest way to install openclose on macOS and Linux. Homebrew builds from source automatically:

```bash
# Install from the latest release (one-liner)
brew install bpingris/tap/openclose

# Or install from the tap (two steps)
brew tap bpingris/tap
brew install openclose
```

**Note:** Homebrew builds from source locally, so you won't encounter macOS Gatekeeper warnings that appear with downloaded binaries.

### From Source

Requires the [Odin programming language](https://odin-lang.org/):

```bash
mkdir -p build
odin build src -out:build/openclose -o:speed -vet -strict-style
```

## Quick Start

```bash
# Initialize openclose in your project
./openclose init

# Create a new spec
./openclose create my-feature

# View all specs and their progress
./openclose summary
```

## Commands

| Command | Description |
|---------|-------------|
| `init` | Initialize `.openclose` directory with `AGENTS.md` |
| `create <name>` | Create a new spec |
| `summary` | Show all specs with progress |
| `validate <name>` | Validate a spec's file formats |
| `archive <path>` | Archive a spec |
| `help` | Show help message |

## Spec Structure

Specs are stored in `.openclose/specs/<name>/` and contain:

- **PRD.md** - Product Requirements Document
- **tasks.md** - Implementation tasks (checked off as completed)
- **scenarios.md** - Test scenarios and acceptance criteria

## AI Assistant Integration

openclose generates custom commands for popular AI assistants:

- **OpenCode** - `.opencode/commands/`
- **Claude Code** - `.claude/commands/openclose/`
- **Cursor** - `.cursor/commands/`

These provide streamlined workflows for AI assistants to create specs, implement them, and archive completed work.

## Using with OpenCode

After running `openclose init`, within OpenCode you can use the following commands to work with specs:

| Command | Description |
|---------|-------------|
| `/oc-create <name>` | Create a new spec - guides you through naming and validation |
| `/oc-brainstorm <feature-idea>` | Run a guided brainstorming session to clarify scope before writing a spec |
| `/oc-impl <name>` | Implement a spec - reads the spec, validates it, and executes tasks in order |
| `/oc-phase <number>` | Implement a specific phase of the current spec |
| `/oc-archive <path>` | Archive a completed spec |

### Brainstorming Scope

For MVP, brainstorming is provided via generated agent commands (for example `/oc-brainstorm ...`).
A native `openclose brainstorm` CLI subcommand is intentionally deferred until the workflow and output schema are stabilized.
Brainstorm summaries can propose one or more specs depending on scope boundaries.
Transition guidance is chat-first: ask the agent to implement a selected spec, or continue refining in conversation.

### Example Workflow

```
# Create a new spec
/oc-create an endpoint called by admin users where it returns a list of tagged users

# Implement the full spec
/oc-impl my-feature

# Or implement just one phase
/oc-phase 2

# Archive when done
/oc-archive my-feature
```

## Inspired By

- [openspec](https://github.com/Fission-AI/OpenSpec/) - before their 1.0 release
- [speckit](https://github.com/github/spec-kit)

and other SDD tool.

## License

MIT
