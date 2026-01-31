# Release Guide

This document explains how to release new versions of openclose.

## Quick Release Checklist

- [ ] All changes committed and pushed to `main`
- [ ] Tests passing (GitHub Actions green)
- [ ] Version number decided (following semver: vMAJOR.MINOR.PATCH)
- [ ] GitHub PAT secret `TAP_GITHUB_TOKEN` configured (one-time setup)
- [ ] Create and push git tag
- [ ] Verify automated workflows complete successfully
- [ ] Verify Homebrew formula updated
- [ ] Verify GitHub Release created with binaries

## Detailed Release Steps

### 1. Prepare the Release

Ensure all changes are committed and pushed:

```bash
git checkout main
git pull origin main
# Verify everything is committed
git status
```

### 2. Create and Push Tag

Choose a version number following [semantic versioning](https://semver.org/):
- `v1.0.0` - Major release (breaking changes)
- `v0.2.0` - Minor release (new features, backwards compatible)
- `v0.1.1` - Patch release (bug fixes)

```bash
# Create annotated tag
git tag -a v0.2.0 -m "Release v0.2.0"

# Push tag to GitHub
git push origin v0.2.0
```

### 3. Automated Workflows Trigger

Pushing the tag automatically triggers two workflows:

#### Build Workflow (`.github/workflows/build.yml`)
- Builds binaries for macOS ARM64, macOS x86_64, and Linux x86_64
- Uploads binaries as artifacts
- Creates a GitHub Release with all binaries attached

#### Update Tap Workflow (`.github/workflows/update-tap.yml`)
- Extracts the tag name and commit hash
- Checks out the [homebrew-tap](https://github.com/bpingris/homebrew-tap) repository
- Updates `Formula/openclose.rb` with the new version and commit hash
- Commits and pushes the changes

### 4. Verify the Release

Check that both workflows completed successfully:

```bash
gh run list
```

Or check the [Actions tab](../../actions) on GitHub.

### 5. Verify Homebrew Formula Updated

Check the tap repository to confirm the formula was updated:

```bash
# The formula should now reference the new tag and commit
curl -s https://raw.githubusercontent.com/bpingris/homebrew-tap/main/Formula/openclose.rb | grep -E "tag:|revision:"
```

### 6. Test the Release

Users can now install or upgrade:

```bash
# For new users
brew tap bpingris/tap
brew install openclose

# For existing users
brew upgrade openclose

# Or download pre-built binaries from GitHub Releases
```

## One-Time Setup: Configure TAP_GITHUB_TOKEN

The automated tap update requires a Personal Access Token (PAT) to commit to the homebrew-tap repository.

### Step 1: Create a PAT

1. Go to [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Give it a name like "Homebrew Tap Update"
4. Select scope: `repo` (full control of private repositories)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again!)

### Step 2: Add to Repository Secrets

1. Go to the [openclose repository settings](../../settings/secrets/actions)
2. Click "New repository secret"
3. Name: `TAP_GITHUB_TOKEN`
4. Value: Paste your PAT from Step 1
5. Click "Add secret"

### Step 3: Verify Access

The PAT should have access to both repositories:
- `bpingris/openclose` (to read the tag)
- `bpingris/homebrew-tap` (to write the formula update)

## Troubleshooting

### Workflow Failed: "Bad credentials"

The `TAP_GITHUB_TOKEN` secret is missing or invalid. Check:
- Secret is configured in repository settings
- PAT has not expired
- PAT has `repo` scope

### Workflow Failed: Permission denied

The PAT might not have access to the homebrew-tap repository. Ensure:
- You're the owner of both repositories, OR
- The PAT has access to both repos if they're under different owners

### Formula Not Updated

Check the workflow logs:
```bash
gh run view <run-id> --log
```

Look for:
- Did the tag extraction work correctly?
- Did the tap repository checkout succeed?
- Did the sed commands modify the formula?
- Did the git push succeed?

### Users Can't Upgrade

If Homebrew doesn't see the new version:
```bash
# Force Homebrew to updaterew update

# Check what Homebrew sees
brew info openclose
```

## Rolling Back a Release

If you need to undo a release:

1. **Delete the tag locally and remotely:**
   ```bash
   git tag -d v0.2.0
   git push origin :refs/tags/v0.2.0
   ```

2. **Delete the GitHub Release** via the web UI

3. **Revert the Homebrew formula** in the tap repository

4. **Notify users** if they already upgraded
