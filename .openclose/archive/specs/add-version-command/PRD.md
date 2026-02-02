# add-version-command

Created: 2026-02-01

## Problem Statement
Users need a way to quickly check which version of the openclose CLI they are running. Currently, there's no command to display version information, making it difficult to verify installation or report issues with the correct version context.

## Requirements
- Add a `version` command that displays the current version
- The version should be embedded at build time from the latest git tag (e.g., v0.1.5)
- If no git tag exists during build, embed "unknown" or "dev"
- The command should be simple: `openclose version`
- Output format: print the version string directly (e.g., "v0.1.5")

## Technical Notes
- This is an Odin project
- Version must be embedded at compile time using Odin's `config` package with `@(init) procedures` or a constant defined at build time
- The GitHub Actions workflow (`build.yml`) should inject the version from git tags during the build process
- The version command should simply print the embedded version constant (no git subprocess at runtime)
- Handle build-time cases where: (1) git is not available, (2) no tags exist - fallback to "unknown"
- Add the version constant to `src/version.odin` and the command handler there
- Update the build workflow to set the version before compilation

## Related Links
- Existing command examples: `src/summary.odin` (simple), `src/validate.odin` (complex)
- Main entry point: `src/main.odin`
- Build workflow: `.github/workflows/build.yml`
