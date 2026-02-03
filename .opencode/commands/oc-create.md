---
title: oc-create
description: Create a new spec using openclose cli
---

<user-request>
$ARGUMENTS
</user-request>

Create a new spec for the current project following these steps:

Step 1: Determine the Spec Name

You MUST identify or generate the spec name before proceeding.

- If the user provided a spec name: Use it as-is (ensure it is in kebab-case)
- If the user provided a feature description: You MUST infer a spec name from the description and convert it to kebab-case (lowercase with dashes)
  - Example: "User authentication process" -> user-authentication-process
  - Example: "Add payment system" -> add-payment-system
- If you cannot infer a meaningful spec name from the description: You MUST use the question tool to ask the user:
  What change do you want to work on? Please provide either the spec name in kebab-case or a clear description of the feature.

Step 2: Create the Spec

You MUST create the spec using the following command:

    openclose create <spec-name>

Important: Replace <spec-name> with the actual spec name you determined in Step 1.

You MUST NOT start implementing the spec at this stage. Only create the spec structure.

Step 3: Update Spec Files with Context

After the spec is created, you MUST edit all three spec files to add meaningful content based on the user's request. You MUST NOT leave the default placeholder values.

The spec files are located at .openclose/specs/<spec-name>/:
- PRD.md - Product Requirements Document
- tasks.md - Implementation tasks
- scenarios.md - Test scenarios

You MUST:
1. Read the user's request carefully
2. Extract key requirements, features, and context
3. Update each file with relevant, specific information
4. Remove generic placeholder text

If you do not have enough information to complete the files meaningfully, you MUST ask the user for more details before editing. Example questions:
- "What specific requirements should this feature have?"
- "What are the acceptance criteria?"
- "Can you provide more context about the technical approach?"

Step 4: Validate and Fix the Spec (Iterative Process)

Once all files are updated, you MUST validate the spec:

    openclose validate <spec-name>

You MUST follow this validation loop until the spec passes:

1. Run the validation command
2. If validation fails:
   - Read the error messages carefully
   - You MUST fix all reported issues in the spec files
   - You MUST re-run the validation command
   - Repeat this process until validation passes
3. If validation passes: Proceed to Step 5

Important: You MUST NOT proceed to Step 5 until the spec is fully valid. Continue iterating between fixing errors and validating until all checks pass.

Step 5: Confirm Implementation Readiness

After validation passes, you MUST ask the user:

The spec <spec-name> has been created and validated successfully. Everything is ready for implementation.

Do you want to implement this spec now?

Wait for the user to explicitly ask for implementation before proceeding.

Summary of Requirements:
- MUST get or infer spec name in kebab-case
- MUST use question tool if spec name cannot be determined
- MUST create spec with openclose create <spec-name>
- MUST NOT start implementing immediately
- MUST update all spec files with meaningful content
- MUST ask for more information if context is unclear
- MUST validate the spec after editing and iteratively fix until validation passes
- MUST NOT proceed to implementation until spec is fully valid
- MUST ask user for implementation confirmation after validation
