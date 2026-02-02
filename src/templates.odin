package main

// Templates for generated files

AGENTS_TEMPLATE :: #load("../prompts/agents.md", string)

SPEC_TEMPLATE :: `# {name}

Created: {date}

## Problem Statement
What problem are we solving?

## Requirements
- Requirement 1
- Requirement 2
- Requirement 3

## Technical Notes
Any technical considerations, approaches, or constraints.

## Related Links
- Link to designs, docs, references
`


TASKS_TEMPLATE :: `# Tasks for {name}

## Phase 1: Foundation
- [ ] Initial setup
- [ ] Core structure

## Phase 2: Implementation
- [ ] Primary feature
- [ ] Secondary feature

## Phase 3: Polish
- [ ] Testing
- [ ] Documentation
`


SCENARIOS_TEMPLATE :: `# Scenarios for {name}

## Happy Path

### Scenario 1: Basic Success
**Given** the system is in initial state
**When** the user performs the primary action
**Then** the expected outcome should occur
**And** any side effects should be correct

## Edge Cases

### Scenario 2: Invalid Input
**Given** the system is ready
**When** the user provides invalid input
**Then** an appropriate error should be shown
**And** the system should remain stable

## Error Cases

### Scenario 3: System Failure
**Given** the system is operating normally
**When** an external dependency fails
**Then** the system should handle the error gracefully
**And** log the failure for debugging
`


EPIC_TEMPLATE :: `# Epic: {name}

Created: {date}

## Objective
What is the overall goal of this epic?

## Description
Detailed description of what this epic encompasses.

## Success Criteria
- Criteria 1
- Criteria 2

## Related Specs
- [Spec name](./spec-name/)
`


// Embedded prompt files - loaded at compile time using #load directive
// These are shared across all agents, only frontmatter differs
CREATE_PROMPT :: #load("../prompts/create.md", string)
IMPL_PROMPT :: #load("../prompts/impl.md", string)
ARCHIVE_PROMPT :: #load("../prompts/archive.md", string)
