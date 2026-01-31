# homebrew-distribution

Created: 2026-01-30

## Problem Statement
Currently, users must manually download and build openclose from source, which creates friction for adoption. We need to set up Homebrew distribution so users can install openclose with a simple `brew install openclose` command. Homebrew builds from source by default, which also resolves the macOS Gatekeeper warnings that occur with pre-built binaries.

## Requirements
- Create a Homebrew formula that builds openclose from source
- Support macOS (ARM64 and x86_64) and Linux platforms through Homebrew
- Keep the existing GitHub Actions workflow for building pre-built binaries (for users who prefer them)
- Create a separate GitHub Actions workflow for testing the Homebrew formula on each push/PR
- The formula must properly declare the Odin compiler as a build dependency
- The formula must install the binary to the correct Homebrew location
- Add a `brew test` block to verify the installation works
- Add a `brew test-bot` compatible configuration for CI testing
- Update README.md with Homebrew installation instructions

## Technical Notes
- Homebrew formulae are Ruby files that define how to build and install software
- Formulae are typically submitted to `homebrew-core` via pull request
- Odin compiler must be available as a Homebrew formula (it may already exist or need to be added)
- The formula should use `url` pointing to GitHub releases or git repository
- Use `depends_on "odin" => :build` to declare the build-time dependency
- Homebrew handles the build process automatically - users don't need to know about Odin
- Consider using `head` option for users who want to install from main branch
- The existing build workflow should remain unchanged and continue producing artifacts
- A separate workflow file for Homebrew testing should validate the formula builds correctly
- macOS Gatekeeper doesn't complain about locally-built binaries, so Homebrew distribution solves the signing issue

## Related Links
- Homebrew Formula Cookbook: https://docs.brew.sh/Formula-Cookbook
- homebrew-core contribution guide: https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request
- Odin Homebrew formula (if exists): https://formulae.brew.sh/formula/odin
- GitHub Actions workflow syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- Homebrew test-bot documentation: https://docs.brew.sh/Manpage#test-bot-options-url
