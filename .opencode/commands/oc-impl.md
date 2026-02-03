---
title: oc-impl
description: Implement a given spec
---

<user-request>
$ARGUMENTS
</user-request>

Implement the spec given by the user following these steps:

Step 1: Find and Validate the Spec

You MUST locate the spec in the .openclose/specs/ directory (do not look in the archive folder).

- Search for specs matching the user's request
- If multiple specs match: You MUST use the question tool to ask the user which one to implement
- If no spec is found: You MUST inform the user and stop

Once you have identified the spec, you MUST validate it:

    openclose validate <spec-name>

If validation fails:
1. You MUST alert the user that the spec is invalid
2. You MUST use the question tool to ask:
   The spec <spec-name> has validation errors. Would you like to:
   - Review the spec yourself and fix it
   - Let me attempt to fix the validation errors
   
   What would you prefer?
3. You MUST wait for user response before proceeding
4. If user asks you to fix it, correct the errors and re-validate until it passes

You MUST NOT start implementation until the spec is valid.

Step 2: Read and Understand the Spec

You MUST read all spec files to understand what needs to be implemented:

1. PRD.md - Understand the problem, requirements, and technical notes
2. tasks.md - Identify all tasks and their order
3. scenarios.md - Understand test scenarios and acceptance criteria

Step 3: Implement According to Tasks

You MUST follow the tasks in the order they appear in tasks.md.

Respect user instructions:
- If the user specifies a particular task: Focus on that task only
- If the user wants only a specific phase (e.g., "just do Phase 1 for now"): Implement only that phase
- If no specific instructions: Implement all tasks in order

As you complete each task:
1. Implement the task according to the spec
2. You MUST mark the task as complete in tasks.md by changing - [ ] to - [x]
3. Move to the next task

You MUST check off tasks as you complete them to maintain accurate progress tracking.

Step 4: Verify Completion

Once all specified tasks are implemented and checked off:

1. Review what was implemented against the PRD requirements
2. Ensure all scenarios from scenarios.md are addressed
3. Verify the implementation matches the spec

Step 5: Notify User and Offer Archive

You MUST notify the user that implementation is complete:

Implementation of spec <spec-name> is complete. All tasks have been finished and checked off.

You MUST then ask:
The spec has been successfully implemented. Would you like to archive this spec now?

Important: You MUST NOT archive the spec yourself unless the user explicitly permits you to do so. Always wait for user confirmation before archiving.

Summary of Requirements:
- MUST use the question tool for user decisions
- MUST validate spec before implementation
- MUST alert user of validation errors and ask if they want to review or let you fix it
- MUST NOT start implementation until spec is valid
- MUST read PRD.md, tasks.md, and scenarios.md
- MUST follow tasks.md order and respect user instructions for specific tasks/phases
- MUST check off tasks in tasks.md as they are completed
- MUST notify user when implementation is complete
- MUST ask user if they want to archive (never archive without explicit permission)
