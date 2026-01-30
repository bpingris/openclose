---
title: oc-archive
description: Archive a given spec
---

<user-request>
$ARGUMENTS
</user-request>

Archive the spec given by the user following these steps:

## Step 1: Find the Spec

**You must** locate the spec in the `.openclose/specs/` or `.openclose/epics/` directories (do not look in the archive folder).

- Search for specs matching the user's request
- **If multiple specs match**: **You must** use the **question** tool to ask the user which one to archive
  > Multiple specs match your request. Which one would you like to archive?
- **If no spec is found**: **You must** inform the user and stop

## Step 2: Confirm Archive Action

Before archiving, **you must** confirm with the user using the **question** tool:

> You are about to archive the spec `<spec-name>`. This will move it to the archive folder.
>
> Do you want to proceed with archiving this spec?

**You must not** archive the spec without explicit user confirmation.

## Step 3: Archive the Spec

Once the user confirms, **you must** run the archive command:

```bash
openclose archive <spec-name>
```

**If the archive command fails**:
1. **You must** read the error message
2. **You must** inform the user of the failure and the specific error
3. **You must** ask if they want you to try fixing the issue or handle it manually

## Step 4: Verify and Notify

After the archive command succeeds:

1. **You must** verify the spec has been moved to `.openclose/archive/`
2. **You must** notify the user:
   > Spec `<spec-name>` has been successfully archived to `.openclose/archive/`
   >
   > The spec and all its files have been preserved.

---

**Summary of Requirements:**
- **Must** search in specs/ and epics/ directories (not archive/)
- **Must** use the **question** tool (not AskUserQuestion) for user decisions
- **Must** confirm with user before archiving (never archive without permission)
- **Must** run `openclose archive <spec-name>` command
- **Must** handle archive command failures gracefully
- **Must** verify and notify user of successful archive