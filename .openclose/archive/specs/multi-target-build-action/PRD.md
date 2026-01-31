# multi-target-build-action

Created: 2026-01-30

## Problem Statement
The openclose project currently has no automated build pipeline. Manual builds are error-prone and don't produce binaries for all supported platforms. We need a GitHub Actions workflow that automatically builds the Odin project for multiple targets, including macOS ARM (Apple Silicon), to enable continuous integration and release automation.

## Requirements
- Build the openclose Odin project on every push and pull request
- Support macOS ARM64 (Apple Silicon) as a primary target
- Support additional targets: macOS x86_64, Linux x86_64
- Create optimized release builds with proper compiler flags
- Upload build artifacts for each target platform
- Use caching to speed up Odin compiler and dependency downloads
- Fail the build if compilation produces any errors or warnings

## Technical Notes
- Project uses the Odin programming language
- Build directory contains the current binary at `build/openclose`
- Source files are in the `src/` directory with `.odin` extension
- Odin compiler must be installed in the GitHub Actions runner
- Consider using `laytan/setup-odin` action for Odin installation
- Cross-compilation may require different approaches for each platform
- macOS ARM64 builds should use `macos-latest` runner (which now uses Apple Silicon)
- Linux builds will need the ubuntu runner for compilation

## Related Links
- Odin documentation: https://odin-lang.org/docs/
- GitHub Actions workflow syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- laytan/setup-odin action: https://github.com/laytan/setup-odin
