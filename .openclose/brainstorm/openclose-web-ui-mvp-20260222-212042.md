# Brainstorm: CLI-Launched Web UI for OpenClose

Created: 2026-02-22
Status: ready-for-spec

## Problem
As `.openclose` content grows, terminal-only workflows make it hard to quickly understand what exists and where to work next. The main pain is visual organization and navigation, not collaboration.

You want a Web UI launched from the CLI so users can browse, create, and edit spec files faster while preserving the local-file workflow.

## Goals
- Provide a clear visual interface for `.openclose` content.
- Launch from CLI quickly and open in browser automatically.
- Support creating a complete spec scaffold from UI.
- Support markdown editing with preview and safe persistence.

## Capabilities
- Launch command: `openclose web` starts local server and opens default browser.
- Default server port: `6789`.
- Browse only `.openclose` content (brainstorms/specs).
- Create spec scaffold files: `PRD.md`, `tasks.md`, `scenarios.md`.
- Edit markdown with preview in UI.
- Save with atomic writes (temp + replace) and unsaved-change warnings.

## Constraints
- Local-only single-user usage; no auth.
- Offline operation (no internet dependency).
- Desktop-only MVP target.
- Keep output and file structure compatible with future CLI workflows.

## Non-Goals
- Guided brainstorming UI in MVP.
- Multi-user collaboration.
- Cloud sync / remote storage integrations.
- Advanced rich-text (WYSIWYG/block) editing.
- Permission/role management.

## Acceptance Signals
- `openclose web` launches and opens browser in under 3 seconds.
- Users can locate existing `.openclose` files quickly.
- Users can create full spec file sets from the UI.
- Markdown edits persist reliably without partial-write corruption.
- Users are warned before leaving with unsaved changes.

## Risks
- Primary risk: file safety (accidental overwrite or loss).
- Secondary risk: launcher/browser-open reliability across environments.
- Scope risk: adding brainstorm/chat UX too early can delay MVP delivery.

## Open Questions
- Should `openclose ui` be added as an alias to `openclose web` in MVP or in a follow-up release?

## Proposed Spec Name
`openclose-web-ui-mvp`

## Transition to Spec
- Suggested next command: `openclose create openclose-web-ui-mvp`
- Files to populate: `PRD.md`, `tasks.md`, `scenarios.md`
