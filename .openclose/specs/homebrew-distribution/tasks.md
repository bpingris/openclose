# Tasks for homebrew-distribution

## Phase 1: Foundation
- [x] Research if Odin compiler has an official Homebrew formula
- [x] ~~Create `homebrew/` directory in the project root~~ (moved to separate tap repo)
- [x] ~~Create `homebrew/openclose.rb` formula file with basic structure~~ (moved to separate tap repo)
- [x] Add URL pointing to GitHub repository (use head for now, or specific release)
- [x] Add `depends_on "odin" => :build` for build dependency
- [x] Implement `install` method to compile and install the binary
- [x] Add `test` block to verify installation works
- [x] Create separate tap repository `bpingris/homebrew-tap`
- [x] Push formula to tap repository with correct tag and revision

## Phase 2: Implementation
- [x] Create separate GitHub Actions workflow `homebrew.yml` for testing the formula
- [x] Configure workflow to run on push and PR to main branch
- [x] Update workflow to test from tap (`brew tap bpingris/tap && brew install openclose`)
- [x] Add macOS ARM64 job to test tap installation
- [x] Add Linux job to test tap installation
- [x] Add HEAD install test job
- [x] Add `brew test openclose` step to verify the test block works
- [ ] ~~Add macOS x86_64 job to test formula build~~ (skipped - macOS-latest covers ARM64, Linux covers x86_64)
- [ ] ~~Use `brew install --build-from-source ./homebrew/openclose.rb` to test locally~~ (no longer applicable - using tap)
- [x] Ensure the formula works with `brew install openclose --HEAD` for main branch installs

## Phase 3: Polish
- [x] Update README.md with Homebrew installation instructions
- [x] Add note explaining that Homebrew builds from source (no Gatekeeper warnings)
- [x] Document the difference between Homebrew install vs downloading pre-built binaries
- [x] Created custom tap `bpingris/homebrew-tap`
- [ ] ~~Test the complete workflow by opening a PR to homebrew-core~~ (using custom tap instead)
- [x] Remove local `homebrew/` directory (formula now lives in tap repo)
- [x] Update GitHub Actions to test from tap instead of local files
