---
title: oc-create
description: Create a new spec using openclose cli
---
<user-request>
$ARGUMENTS
</user-request>

Create a new spec for the current project.
**Important**: Do not implement anything yet, you can only create the spec the user asked using this command:

```bash
`odin run ./src -- create <epic-name>`
```

This is either the spec name or a desciption of the spec.

Run `odin run ./src -- create <epic-name>` with epic name being the name the user requested or the name you can infer from the description and context the user has provided.

If you cannot infer a name for the spec, you **SHOULD** use the **AskUserQuestion** tool to prompt the user for the name.
> What change do you want to work on?

From the user input infer a name for the spec in kebab-case (lowercase, spaces replaced with dashes, example user-authentication-process).

Once you have the name and you are ready to create the spec, run `odin run ./src -- create <spec-name>`.

Use the TodoWrite tool 

After creating the spec, output to the user the spec name and the path to the new spec.

**Do not start implementing the spec, you only have to create the spec using the cli command**

Wait for the user to ask for the implementation.

Ask the user if everything is okay and if they want to implement the spec.
