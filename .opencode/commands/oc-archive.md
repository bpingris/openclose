---
title: oc-foobar
description: Archive a given spec
---

<user-request>
$ARGUMENTS
</user-request>

Archive the spec given by the user.

Find the spec that matches the user's request inside the .openclose folder, do not look into the archive folder.

If you find multiple matches, ask the user to select one using the `AskUserQuestion` tool.

Run `odin run ./src -- archive <spec-name>` to archive the spec.

