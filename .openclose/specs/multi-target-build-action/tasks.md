# Tasks for multi-target-build-action

## Phase 1: Foundation
- [x] Create `.github/workflows/` directory structure
- [x] Create initial workflow file `build.yml` with basic structure
- [x] Set up Odin compiler installation step using `laytan/setup-odin`
- [x] Configure workflow triggers (push, pull_request)

## Phase 2: Implementation
- [x] Add macOS ARM64 build job using `macos-latest` runner
- [x] Add macOS x86_64 build job using `macos-13` runner (Intel)
- [x] Add Linux x86_64 build job using `ubuntu-latest` runner
- [ ] ~~Add Windows x86_64 build job using `windows-latest` runner~~ (removed - Windows not needed)
- [x] Configure compiler flags for optimized release builds (`-o:speed` or `-o:aggressive`)
- [x] Add artifact upload step for each build target
- [x] Set up caching for Odin compiler to speed up subsequent runs

## Phase 3: Polish
- [x] Test workflow by pushing to a branch and verifying all jobs pass
- [x] Verify artifacts are uploaded correctly and can be downloaded
- [ ] Add build status badge to README.md (skipped - no README.md exists)
- [x] Document the workflow in AGENTS.md or README.md
- [x] Ensure build fails on compiler warnings (using `-vet -strict-style` flags)
