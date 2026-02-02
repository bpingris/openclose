<user-request>
$ARGUMENTS
</user-request>

Create a new spec for the current project following these steps:

## Step 1: Determine the Spec Name

**You must** identify or generate the spec name before proceeding.

- **If the user provided a spec name**: Use it as-is (ensure it's in kebab-case)
- **If the user provided a feature description**: **You must** infer a spec name from the description and convert it to **kebab-case** (lowercase with dashes)
  - Example: "User authentication process" -> `user-authentication-process`
  - Example: "Add payment system" -> `add-payment-system`
- **If you cannot infer a meaningful spec name from the description**: **You must** use the **question** tool to ask the user:
  > What change do you want to work on? Please provide either the spec name in kebab-case or a clear description of the feature.

## Step 2: Create the Spec

**You must** create the spec using the following command:

    openclose create <spec-name>

**Important**: Replace `<spec-name>` with the actual spec name you determined in Step 1.

**Do not** start implementing the spec at this stage. Only create the spec structure.

## Step 3: Update Spec Files with Context

After the spec is created, **you must** edit all three spec files to add meaningful content based on the user's request. **Do not** leave the default placeholder values.

The spec files are located at `.openclose/specs/<spec-name>/`:
- `PRD.md` - Product Requirements Document
- `tasks.md` - Implementation tasks
- `scenarios.md` - Test scenarios

**You must**:
1. Read the user's request carefully
2. Extract key requirements, features, and context
3. Update each file with relevant, specific information
4. Remove generic placeholder text

**If you do not have enough information** to complete the files meaningfully, **you must** ask the user for more details before editing. Example questions:
- "What specific requirements should this feature have?"
- "What are the acceptance criteria?"
- "Can you provide more context about the technical approach?"

## Step 4: Validate and Fix the Spec (Iterative Process)

Once all files are updated, **you must** validate the spec:

    openclose validate <spec-name>

**You must** follow this validation loop until the spec passes:

1. **Run the validation command**
2. **If validation fails**:
   - Read the error messages carefully
   - **You must** fix all reported issues in the spec files
   - **You must** re-run the validation command
   - **Repeat this process until validation passes**
3. **If validation passes**: Proceed to Step 5

**Important**: **You must not** proceed to Step 5 until the spec is fully valid. Continue iterating between fixing errors and validating until all checks pass.

## Step 5: Confirm Implementation Readiness

After validation passes, **you must** ask the user:

> The spec `<spec-name>` has been created and validated successfully. Everything is ready for implementation.
> 
> Do you want to implement this spec now?

**Wait for the user to explicitly ask for implementation** before proceeding.

---

**Summary of Requirements:**
- **Must** get or infer spec name in kebab-case
- **Must** use **question** tool if spec name cannot be determined
- **Must** create spec with `openclose create <spec-name>`
- **Must not** start implementing immediately
- **Must** update all spec files with meaningful content
- **Must** ask for more information if context is unclear
- **Must** validate the spec after editing and **iteratively fix until validation passes**
- **Must not** proceed to implementation until spec is fully valid
- **Must** ask user for implementation confirmation after validation
