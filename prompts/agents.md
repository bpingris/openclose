## What is openclose?

openclose is a spec-driven workflow tool for organizing software work. It provides a structured way to:
- Define specifications with PRDs, tasks, and test scenarios
- Track implementation progress
- Archive completed work

## Core Concepts

- **Specs**: Units of work stored in `.openclose/specs/<name>/` containing:
  - `PRD.md` - Product Requirements Document
  - `tasks.md` - Implementation tasks (checked off as completed)
  - `scenarios.md` - Test scenarios and acceptance criteria

- **Archive**: Completed work moved to `.openclose/archive/`

## Available Commands

| Command | Description |
|---------|-------------|
| `openclose summary` | View all specs and their progress |
| `openclose create <name>` | Create a new spec |
| `openclose create <name> --epic <epic>` | Create a spec attached to an epic |
| `openclose validate <name>` | Validate a spec's file format |
| `openclose archive <path>` | Archive a spec or epic |
| `openclose help` | Show all available commands |
| `openclose version` | Show the current version |

## When to Create a Spec

Create a spec when the request:
- Is ambiguous or complex
- Involves multiple steps or phases
- Makes breaking changes to existing functionality
- Introduces new capabilities or architecture shifts
- Requires significant performance or security work

**Simple changes** (estimated under 1 hour) may skip the spec workflow and be implemented directly.

## Workflow Guidelines

### Creating Specs
1. Use `openclose create <spec-name>` to create the spec structure
2. Fill in PRD.md, tasks.md, and scenarios.md with meaningful content
3. Run `openclose validate <spec-name>` to ensure format is correct
4. Fix any validation errors before proceeding to implementation

### Implementing Specs
1. Always validate the spec first: `openclose validate <spec-name>`
2. Read PRD.md, tasks.md, and scenarios.md to understand requirements
3. Follow tasks in order, checking them off as you complete them (`- [ ]` → `- [x]`)
4. After implementation, ask the user if they want to archive the spec

### General Rules
- **Never archive specs without explicit user permission**
- Use the **question** tool when multiple specs match or when unclear what to do
- Check `openclose summary` to see the current state of all specs
- Respect user instructions for specific tasks or phases

## Project-Specific Commands

<!-- Add project-specific commands here that agents should run: -->
<!-- - Lint command: e.g., `npm run lint` -->
<!-- - Test command: e.g., `npm test` -->
<!-- - Typecheck command: e.g., `npm run typecheck` -->
<!-- - Build command: e.g., `make build` -->

## Project-Specific Conventions

<!-- Add framework-specific conventions or coding standards here: -->
<!-- - Use specific naming patterns -->
<!-- - Follow specific architectural patterns -->
<!-- - Testing requirements -->
<!-- - Code style preferences -->
