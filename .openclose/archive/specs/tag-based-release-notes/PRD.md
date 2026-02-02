# tag-based-release-notes

Created: 2026-01-31

## Problem Statement
Currently, when creating a GitHub release for openclose, we manually write release notes or use generic commit messages. This doesn't provide users with a clear picture of what features or changes were included in the release. We need an automated system that:
1. Triggers when a new git tag is pushed
2. Creates a GitHub Release automatically
3. Generates meaningful release notes from archived specs that were completed between the previous tag and the current tag
4. Falls back to using commit messages if no relevant archived specs are found

## Requirements
- Create a GitHub Actions workflow that triggers on tag push (v*)
- The workflow must create a GitHub Release automatically using the GitHub API
- The workflow should attempt to identify archived specs that were completed between the previous tag and current tag
- If archived specs are found, generate release notes from their PRD.md content (title, description, key changes)
- If no archived specs match, fall back to generating release notes from commit messages between tags
- The release title should include the version number
- The release should be marked as a pre-release if the tag contains alpha/beta/rc
- Support both light and full release notes modes (summary vs detailed)
- Handle edge cases: first release (no previous tag), no archived specs, no commits between tags

## Technical Notes
- Workflow triggers on: `on.push.tags: ['v*']`
- Use GitHub API to create releases (via `gh` CLI or `actions/create-release`)
- Get previous tag using `git describe --tags --abbrev=0 HEAD^` or similar
- List archived specs in `.openclose/archive/specs/`
- Check if archived specs were created between previous tag and current tag using git timestamps
- Parse PRD.md files to extract titles and problem statements for release notes
- Fallback: use `git log <previous-tag>..<current-tag> --oneline` for commit-based notes
- Use GitHub Actions `GITHUB_TOKEN` for API authentication (no extra secrets needed)
- Consider using the `gh release create` command for simplicity
- Release notes format should be Markdown
- Tag message can be used as release title if available (from `git tag -a`)

## Related Links
- GitHub CLI release documentation: https://cli.github.com/manual/gh_release_create
- GitHub Actions create release: https://github.com/actions/create-release
- Git tag formatting: https://git-scm.com/book/en/v2/Git-Basics-Tagging
- OpenClose archive structure: `.openclose/archive/specs/<name>/`
- Semantic versioning: https://semver.org/
