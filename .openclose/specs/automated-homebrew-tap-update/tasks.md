# Tasks for automated-homebrew-tap-update

## Phase 1: Foundation
- [ ] Create GitHub Personal Access Token with `repo` scope
  - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
  - Generate new token with `repo` scope
  - Copy the token value (you'll only see it once)
- [ ] Add the PAT as `TAP_GITHUB_TOKEN` secret in openclose repository settings
  - Go to openclose repository → Settings → Secrets and variables → Actions
  - Click "New repository secret"
  - Name: `TAP_GITHUB_TOKEN`
  - Value: Paste your PAT from above
- [x] Create `.github/workflows/update-tap.yml` workflow file
- [x] Configure workflow trigger on tag push pattern `v*`
- [x] Add workflow step to extract tag name from `github.ref`
- [x] Add workflow step to get commit hash for the tag

## Phase 2: Implementation
- [x] Add workflow step to checkout homebrew-tap repository using PAT
- [x] Add workflow step to update the formula file with new tag and hash
- [x] Implement sed commands or script to update `tag:` and `revision:` fields
- [x] Add workflow step to commit changes with descriptive message
- [x] Add workflow step to push changes back to tap repository
- [x] Add error handling and notifications on failure (workflow will fail visibly if any step fails)
- [ ] Test the workflow by creating a test tag (e.g., v0.0.1-test)
  - After setting up the PAT secret, create a test tag to verify it works

## Phase 3: Polish
- [x] Document the automated workflow in README.md
- [x] Add documentation about required PAT setup for maintainers (see Phase 1 tasks above)
- [x] Create a RELEASE.md guide explaining the full release process
- [ ] Verify the workflow works end-to-end with a real release (to be done after PAT setup)
- [ ] Monitor first automated update to ensure it works correctly (to be done after first release)
- [x] Update AGENTS.md with information about the release automation
