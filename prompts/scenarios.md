# Scenarios for {name}

## Happy Path

Scenario 1: Basic Success

Given the system is in initial state
When the user performs the primary action
Then the expected outcome SHOULD occur
And any side effects MUST be correct

## Edge Cases

Scenario 2: Invalid Input

Given the system is ready
When the user provides invalid input
Then an appropriate error MUST be shown
And the system MUST remain stable

## Error Cases

Scenario 3: System Failure

Given the system is operating normally
When an external dependency fails
Then the system MUST handle the error gracefully
And the failure MUST be logged for debugging
