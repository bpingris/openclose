package main

// Templates for generated files

AGENTS_TEMPLATE :: `# Project Overview
What this project does and why it exists.

# Technology Stack
Languages, frameworks, tools, versions.

# Architecture Notes
High-level structure, important directories, patterns.

# Rules & Conventions
Coding standards, naming rules, things to avoid.

# How to Run
How to build, run, and test the project locally.

# Contribution Guidelines
How changes should be made, tested, and reviewed.
`

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
- [ ] Task 1 - Initial setup
- [ ] Task 2 - Core structure

## Phase 2: Implementation
- [ ] Task 3 - Primary feature
- [ ] Task 4 - Secondary feature

## Phase 3: Polish
- [ ] Task 5 - Testing
- [ ] Task 6 - Documentation
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

// Agent command file templates
OC_CREATE_COMMAND :: `# OpenCode: Create Spec

Create a new spec for the current project.

## Steps
1. Run the create command
2. Provide spec name
3. Fill in PRD details

## Usage
    odin run ./src -- create <epic-name>
`

OC_IMPL_COMMAND :: `# OpenCode: Implement Spec

Implement the spec given by the user.

## Instructions
1. Read the spec from .openclose/specs/
2. Validate the spec is complete
3. Follow the tasks and scenarios
4. Mark tasks as completed

## Usage
User provides spec name to implement
`

OC_ARCHIVE_COMMAND :: `# OpenCode: Archive Spec

Archive a completed or cancelled spec.

## Steps
1. Move spec to archive folder
2. Preserve all files
3. Update references

## Usage
    odin run ./src -- archive <spec-name>
`

CLAUDE_CREATE_COMMAND :: `# Claude Code: Create Spec

Create a new spec for the current project.

## Steps
1. Run the create command
2. Provide spec name
3. Fill in PRD details
`

CLAUDE_IMPL_COMMAND :: `# Claude Code: Implement Spec

Implement the spec given by the user.

## Instructions
1. Read the spec from .openclose/specs/
2. Validate the spec is complete
3. Follow the tasks and scenarios
4. Mark tasks as completed
`

CLAUDE_ARCHIVE_COMMAND :: `# Claude Code: Archive Spec

Archive a completed or cancelled spec.

## Steps
1. Move spec to archive folder
2. Preserve all files
3. Update references
`

CURSOR_CREATE_COMMAND :: `# Cursor: Create Spec

Create a new spec for the current project.

## Steps
1. Run the create command
2. Provide spec name
3. Fill in PRD details
`

CURSOR_IMPL_COMMAND :: `# Cursor: Implement Spec

Implement the spec given by the user.

## Instructions
1. Read the spec from .openclose/specs/
2. Validate the spec is complete
3. Follow the tasks and scenarios
4. Mark tasks as completed
`

CURSOR_ARCHIVE_COMMAND :: `# Cursor: Archive Spec

Archive a completed or cancelled spec.

## Steps
1. Move spec to archive folder
2. Preserve all files
3. Update references
`
