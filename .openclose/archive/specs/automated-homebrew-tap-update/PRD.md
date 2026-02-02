# automated-homebrew-tap-update

Created: 2026-01-31

## Problem Statement
Currently, when releasing a new version of openclose, we must manually:
1. Create and push a new git tag in the openclose repository
2. Get the commit hash for that tag
3. Switch to the homebrew-tap repository
4. Update the formula with the new tag version and commit hash
5. Commit and push the changes to the tap

This manual process is error-prone, time-consuming, and delays the availability of new releases to Homebrew users. We need to automate this workflow so that pushing a new tag in the openclose repository automatically updates the homebrew-tap formula.

## Requirements
- Create a GitHub Actions workflow that triggers when a new tag (v*) is pushed to the openclose repository
- The workflow must automatically calculate the commit hash for the new tag
- The workflow must checkout the homebrew-tap repository
- The workflow must update the formula file with the new tag version and commit hash
- The workflow must commit and push the changes back to the homebrew-tap repository
- The workflow should handle errors gracefully and notify on failure
- Use a Personal Access Token (PAT) to allow cross-repository commits
- Support semantic versioning tags (v0.1.0, v1.2.3, etc.)
- The workflow should validate the tag format before proceeding

## Technical Notes
- Workflow triggers on: `on.push.tags: ['v*']`
- Use `actions/checkout@v4` to checkout the tap repository
- The tap repo URL: `https://github.com/bpingris/homebrew-tap`
- Formula file location: `Formula/openclose.rb`
- Need a GitHub Personal Access Token with `repo` scope stored as `TAP_GITHUB_TOKEN` secret
- Use sed or similar to update the formula file in-place
- Extract tag name from `github.ref` (e.g., `refs/tags/v0.2.0` -> `v0.2.0`)
- Get commit hash via `git rev-list -n 1 <tag>`
- Pattern to replace in formula: `tag: ".*"` and `revision: ".*"`
- Commit message should include the version number for clarity
- The workflow should run on ubuntu-latest for consistency

## Related Links
- GitHub Actions workflow syntax: https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
- Creating a personal access token: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
- GitHub Actions secrets: https://docs.github.com/en/actions/security-guides/encrypted-secrets
- sed command documentation: https://www.gnu.org/software/sed/manual/sed.html
- Semantic versioning: https://semver.org/
