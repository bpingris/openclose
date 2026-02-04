<user-request>
$ARGUMENTS
</user-request>

Implement the specified phase of the current spec following these steps:

Step 1: Identify the Phase Number

You MUST extract the phase number from the arguments provided by the user.

- The phase number should be the first argument after `oc-phase`
- If no argument is provided: You MUST ask the user to provide a phase number using question tool
- If the argument is not a valid number: You MUST ask for a valid phase number

Step 2: Identify the Active Spec

You MUST find the currently active spec:

- Look for a `.openclose/specs/` directory in the current working directory or parent directories
- Find the spec that is currently being worked on (typically the most recent or marked as active)
- If no active spec is found: You MUST output an error message and stop execution
- If multiple specs are found and can't decide which one to use: You MUST use the question tool to ask the user to select the spec

Step 3: Parse the Tasks File

You MUST read and parse the `.openclose/specs/<spec-name>/tasks.md` file:

- Parse the phase structure from the tasks.md file
- Identify the tasks belonging to the specified phase number
- If the specified phase does not exist: you MUST output an error message and stop execution

Step 4: Implement the Spec

You MUST implement only the specified phase of the spec following the tasks.md file:

- Implement each task in the specified phase, checking them off as completed (- [x] for completed)
- After completing all tasks in the phase, update the tasks.md file to mark them as complete
- Only implement tasks for the specified phase number
- DO NOT continue to subsequent phases after completing this phase
- DO NOT perform any git operations (add, commit, push) after implementing
- DO NOT automatically proceed to implement additional phases
- Stop implementation after completing the specified phase

Step 5: Stop Execution

After implementing the phase, you MUST:

- NOT automatically continue to subsequent phases
- NOT perform any git operations
- NOT modify any files beyond the implementation
- Wait for the user to explicitly ask for next steps

Summary of Requirements:
- MUST extract phase number from arguments
- MUST find the active spec
- MUST parse tasks.md to identify the specified phase
- MUST implement only the specified phase
- MUST NOT continue to subsequent phases
- MUST NOT perform git operations
- MUST stop execution after completing the phase
