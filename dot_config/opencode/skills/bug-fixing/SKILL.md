---
name: bug-fixing
description: Diagnose and fix software bugs through reproduction, root-cause analysis, minimal justified changes, regression testing, and complete verification.
---

# Bug Fixing

Use this skill when investigating incorrect behavior, crashes, regressions, failing tests, performance anomalies, or unexpected output.

## Workflow

1. Understand the bug precisely:
   - Identify expected behavior.
   - Identify actual behavior.
   - Gather reproduction steps, errors, logs, stack traces, environment details, and relevant inputs.
   - Separate confirmed facts from assumptions.

2. Reproduce before modifying code whenever practical:
   - Use the smallest reliable reproduction.
   - Run existing failing tests if available.
   - If the bug cannot be reproduced, investigate why before making speculative changes.

3. Trace the execution path:
   - Find the code responsible for the observed behavior.
   - Inspect callers, callees, data transformations, state changes, configuration, and boundary conditions.
   - Use logs, debugger output, targeted instrumentation, tests, or git history when useful.

4. Identify the root cause:
   - Explain why the bug occurs, not merely where the symptom appears.
   - Check whether the same root cause affects other paths.
   - Distinguish implementation defects from configuration, environment, dependency, or usage problems.

5. Write or update a regression test when appropriate:
   - Make the test fail for the original bug.
   - Keep it focused on externally meaningful behavior or the smallest stable unit.
   - Avoid tests that merely mirror implementation details.

6. Apply the smallest complete fix:
   - Fix the root cause.
   - Preserve existing behavior outside the bug's scope.
   - Avoid broad rewrites and unrelated cleanup.
   - Follow existing architecture and style.

7. Verify:
   - Confirm the original reproduction now succeeds.
   - Run the regression test.
   - Run related tests and then the broader relevant suite.
   - Run configured linting and type checking.
   - Check nearby edge cases and likely regressions.

8. Review the diff:
   - Ensure every changed line contributes to the fix or its verification.
   - Remove temporary instrumentation and debug output.
   - Confirm no errors are merely suppressed.

## Rules

- Do not guess and patch blindly when reproduction or investigation is possible.
- Do not treat a symptom as the root cause.
- Do not silence exceptions, warnings, type errors, lint failures, or failing tests merely to make the output green.
- Avoid broad `except Exception` handlers unless the architecture genuinely requires them.
- Do not weaken tests to accommodate broken behavior.
- Do not introduce unrelated refactors during a bug fix.
- Never claim a bug is fixed without verifying the original failure path when practical.
- If reproduction is impossible, clearly state what was verified and what remains uncertain.
- Prefer a small, well-understood fix over a large speculative rewrite.
