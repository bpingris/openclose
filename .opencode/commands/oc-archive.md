---
title: oc-archive
description: Archive a given spec
---

<user-request>
$ARGUMENTS
</user-request>

Archive the spec given by the user following these steps:

Step 1: Find the Spec

You MUST locate the spec in the .openclose/specs/ directory (do not look in the archive folder).

- Search for specs matching the user's request
- If multiple specs match: You MUST use the question tool to ask the user which one to archive
- If no spec is found: You MUST inform the user and stop

Step 2: Archive the Spec

Once you have identified the spec, you MUST run the archive command:

    openclose archive <spec-name>

Important: Replace <spec-name> with the actual spec name.

Step 3: Confirm Completion

After the archive command completes successfully, notify the user:

Spec <spec-name> has been archived successfully.

The spec has been moved to .openclose/archive/specs/<spec-name>/.

Summary of Requirements:
- MUST find the spec in .openclose/specs/ only
- MUST use question tool if multiple specs match
- MUST run openclose archive <spec-name> command
- MUST confirm successful completion to the user
