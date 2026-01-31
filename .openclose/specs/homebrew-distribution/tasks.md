# Tasks for homebrew-distribution

## Phase 1: Foundation
- [x] Research if Odin compiler has an official Homebrew formula
- [x] Create `homebrew/` directory in the project root
- [x] Create `homebrew/openclose.rb` formula file with basic structure
- [x] Add URL pointing to GitHub repository (use head for now, or specific release)
- [x] Add `depends_on "odin" => :build` for build dependency
- [x] Implement `install` method to compile and install the binary
- [x] Add `test` block to verify installation works

## Phase 2: Implementation
- [x] Create separate GitHub Actions workflow `homebrew.yml` for testing the formula
- [x] Configure workflow to run on push and PR to main branch
- [x] Add macOS ARM64 job to test formula build
- [x] Add Linux job to test formula build (optional, but recommended)
- [x] Use `brew install --build-from-source ./homebrew/openclose.rb` to test locally
- [x] Add `brew test openclose` step to verify the test block works
- [ ] ~~Add macOS x86_64 job to test formula build~~ (skipped - macOS-latest covers ARM64, Linux covers x86_64)
- [ ] ~~Ensure the formula works with `brew install openclose --HEAD` for main branch installs~~ (to be tested manually)

## Phase 3: Polish
- [x] Update README.md with Homebrew installation instructions
- [x] Add note explaining that Homebrew builds from source (no Gatekeeper warnings)
- [x] Document the difference between Homebrew install vs downloading pre-built binaries
- [ ] ~~Test the complete workflow by opening a PR to homebrew-core (or create a tap first)~~ (to be done after creating a release)
- [ ] ~~Consider creating a custom tap `bpingris/homebrew-tap` as an alternative to homebrew-core~~ (optional - can use homebrew-core directly)
- [x] Verify the formula passes `brew audit --strict openclose` (via CI job)
- [x] Ensure formula works on clean macOS and Linux systems (via CI)
