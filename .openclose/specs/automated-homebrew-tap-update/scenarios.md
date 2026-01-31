# Scenarios for automated-homebrew-tap-update

## Happy Path

### Scenario 1: Successful Automated Tap Update
**Given** the user has created a new tag `v0.2.0` in the openclose repository
**And** the `TAP_GITHUB_TOKEN` secret is configured
**When** the user pushes the tag to GitHub
**Then** the workflow should trigger automatically
**And** extract the tag version `v0.2.0` from the ref
**And** get the commit hash for the tag
**And** checkout the homebrew-tap repository
**And** update the formula with the new tag and commit hash
**And** commit the changes with message "Update openclose to v0.2.0"
**And** push the commit to the tap repository
**And** users can immediately install the new version via `brew upgrade openclose`

### Scenario 2: Multiple Version Updates
**Given** the workflow has successfully run for version v0.1.0
**When** the user creates and pushes tag v0.2.0
**Then** the workflow should update the formula from v0.1.0 to v0.2.0
**And** the formula should reference the correct new commit hash
**And** the tap repository history should show both update commits

## Edge Cases

### Scenario 3: Invalid Tag Format
**Given** the user pushes a tag named `invalid-tag-format` (not starting with 'v')
**When** the workflow trigger condition is checked
**Then** the workflow should NOT trigger (the pattern is 'v*')
**And** the tap should remain unchanged

### Scenario 4: Tag Already Exists in Formula
**Given** the formula already has tag `v0.1.0`
**When** the user accidentally re-pushes the same tag
**Then** the workflow should still run
**And** the formula should be updated with the same values
**And** the commit should show no actual changes (or be a no-op)

### Scenario 5: Missing PAT Secret
**Given** the `TAP_GITHUB_TOKEN` secret is not configured
**When** the workflow attempts to checkout the tap repository
**Then** the workflow should fail with an authentication error
**And** the failure should be logged clearly in the Actions UI
**And** the tap should not be modified

## Error Cases

### Scenario 6: Network Failure During Tap Checkout
**Given** the workflow is running
**And** GitHub is experiencing connectivity issues
**When** the workflow attempts to checkout the tap repository
**Then** the checkout step should fail
**And** the workflow should stop without making changes
**And** the error should be visible in the Actions logs

### Scenario 7: Formula File Not Found
**Given** the tap repository structure has changed
**And** `Formula/openclose.rb` no longer exists
**When** the workflow attempts to update the formula
**Then** the sed/update step should fail
**And** the workflow should report a clear error
**And** the failure notification should suggest checking the tap repository structure

### Scenario 8: Push Permission Denied
**Given** the PAT has expired or been revoked
**When** the workflow attempts to push to the tap repository
**Then** the push should fail with a permission error
**And** the workflow should report the authentication failure
**And** the formula changes should remain uncommitted (or the commit should be visible but push fails)

### Scenario 9: Commit Hash Extraction Failure
**Given** the tag was created but the commit is somehow unreachable
**When** the workflow runs `git rev-list -n 1 <tag>`
**Then** the command should fail
**And** the workflow should not proceed with updating the formula
**And** an appropriate error message should be displayed
