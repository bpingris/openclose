# openclose

A CLI tool for organizing software specifications, PRDs (Product Requirements Documents), and implementation tracking.

## Overview

openclose helps development teams manage their project specifications through a structured workflow:

1. **Create specs** - Define features with PRD, tasks, and test scenarios
2. **Implement** - Follow the spec tasks to build features
3. **Validate** - Ensure specs meet formatting requirements
4. **Archive** - Clean up completed work

## Installation

### From Source

Requires the [Odin programming language](https://odin-lang.org/):

```bash
mkdir -p build
odin build src -out:build/openclose -o:speed -vet -strict-style
```

### Pre-built Binaries

Download pre-built binaries from the [GitHub Releases](../../releases) page.

## Quick Start

```bash
# Initialize openclose in your project
./openclose init

# Create a new spec
./openclose create my-feature

# View all specs
./openclose view

# Check implementation progress
./openclose summary
```

## Commands

| Command | Description |
|---------|-------------|
| `init` | Initialize `.openclose` directory with `AGENTS.md` |
| `create <name>` | Create a new spec |
| `create <name> --epic <epic>` | Create a spec attached to an epic |
| `epic <name>` | Create a new epic |
| `view` | View all specs and epics |
| `summary` | Show progress summary |
| `validate <name>` | Validate a spec's file formats |
| `archive <path>` | Archive a spec or epic |
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

## Build

This project uses GitHub Actions for automated multi-platform builds:

- macOS ARM64 (Apple Silicon)
- macOS x86_64 (Intel)
- Linux x86_64

See `.github/workflows/build.yml` for the build configuration.

## License

MIT
