---
title: oc-impl
description: Implement a given spec
---
<user-request>
$ARGUMENTS
</user-request>

Implement the spec given by the user.

Find the spec that matches the user's request inside the .openclose folder, do not look into the archive folder.
If you find multiple matches, ask the user to select one using the `AskUserQuestion` tool.

Run `odin run ./src -- validate <spec-name>` to be sure the spec is valid.

If the spec is valid, start implementing it.

Else, try to fix the specs yourself. If you cannot fix it, ask the user for more information so that you can fix it.


