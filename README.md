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

# Or install the latest development version from main branch
brew install bpingris/tap/openclose --HEAD
```

**Note:** Homebrew builds from source locally, so you won't encounter macOS Gatekeeper warnings that appear with downloaded binaries.

### From Source

Requires the [Odin programming language](https://odin-lang.org/):

```bash
mkdir -p build
odin build src -out:build/openclose -o:speed -vet -strict-style
```

### Pre-built Binaries

Download pre-built binaries from the [GitHub Releases](../../releases) page.

**Note:** macOS users may see a Gatekeeper warning when running pre-built binaries. To bypass:
- Right-click the binary and select "Open" instead of double-clicking
- Or run: `xattr -d com.apple.quarantine build/openclose`

**Which installation method should I use?**

- **Homebrew**: Recommended for most users. Automatically handles dependencies, updates, and avoids Gatekeeper issues.
- **From Source**: Use if you want to modify the code or need a specific version not yet in Homebrew.
- **Pre-built Binaries**: Use if you need a quick download and don't have Homebrew installed (requires bypassing Gatekeeper on macOS).

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
| `create <name> --epic <epic>` | Create a spec attached to an epic |
| `epic <name>` | Create a new epic |
| `summary` | Show all specs with progress |
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

## Release Process (For Maintainers)

To release a new version:

1. **Create and push a tag:**
   ```bash
   git tag -a v0.2.0 -m "Release v0.2.0"
   git push origin v0.2.0
   ```

2. **Automated workflow triggers:**
   - The `release.yml` workflow creates a GitHub Release with auto-generated release notes
   - The `update-tap.yml` workflow automatically updates the Homebrew formula in the [homebrew-tap](https://github.com/bpingris/homebrew-tap) repository
   - The `build.yml` workflow creates pre-built binaries for all platforms

3. **Done!** Users can now:
   - Upgrade via Homebrew: `brew update && brew upgrade openclose`
   - Download pre-built binaries from the [Releases](../../releases) page

### Setting up the automated tap update (one-time setup)

The automated Homebrew tap update requires a Personal Access Token (PAT):

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate a new token with `repo` scope
3. In the openclose repository, go to Settings → Secrets and variables → Actions
4. Add a new secret named `TAP_GITHUB_TOKEN` with your PAT value

## License

MIT
