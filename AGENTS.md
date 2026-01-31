<!-- START OPENCLOSE INSTRUCTIONS -->
# openclose instructions

These instructions are for AI assistants working in this project.

Always open `@/.openclose/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/.openclose/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

## Release Automation

This project has automated release workflows:

### GitHub Actions Workflows

1. **build.yml** - Builds binaries for macOS ARM64, macOS x86_64, and Linux x86_64
   - Runs on every push to main and on pull requests
   - Creates pre-built binaries for GitHub Releases

2. **update-tap.yml** - Automatically updates the Homebrew tap when a new tag is pushed
   - Triggers on tag push (pattern: `v*`)
   - Updates `bpingris/homebrew-tap` Formula/openclose.rb with new version and commit hash
   - Requires `TAP_GITHUB_TOKEN` secret to be configured

### Making a Release

When asked about releasing:

1. Ensure all changes are committed and tests pass
2. Create and push a new git tag:
   ```bash
   git tag -a v0.2.0 -m "Release v0.2.0"
   git push origin v0.2.0
   ```
3. Workflows will automatically:
   - Build and upload binaries
   - Update the Homebrew formula

### One-time Setup (for maintainers)

The automated tap update requires a GitHub Personal Access Token:
1. Create PAT with `repo` scope at https://github.com/settings/tokens
2. Add as `TAP_GITHUB_TOKEN` secret in repository settings

See `RELEASE.md` for full release documentation.
<!-- END OPENCLOSE INSTRUCTIONS -->
