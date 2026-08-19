---
name: roadmap-implementation
description: Implement a complete roadmap milestone or version while preserving architecture, compatibility, code quality, and every stated requirement.
---

# Roadmap Implementation

Use this skill when asked to implement a roadmap milestone, release, version, phase, or group of planned features.

## Workflow

1. Read the complete roadmap before modifying code.
   - Locate the requested milestone or version.
   - Identify every explicit requirement, subtask, acceptance criterion, dependency, and constraint.
   - Read surrounding milestones when they clarify sequencing or architectural intent.

2. Inspect the repository deeply:
   - Understand the source layout and major abstractions.
   - Read relevant documentation, tests, configuration, interfaces, schemas, and public APIs.
   - Inspect git history when it materially helps explain architectural decisions or previous implementations.
   - Do not start coding from the roadmap alone.

3. Establish the implementation scope:
   - Build a checklist containing every requirement in the requested milestone.
   - Order work by dependency.
   - Identify compatibility constraints and likely affected components.
   - Distinguish required work from optional improvements.

4. Implement incrementally:
   - Follow existing architecture and conventions.
   - Prefer existing abstractions.
   - Avoid unrelated refactoring and speculative features.
   - Complete prerequisite changes before dependent features.
   - Keep the implementation coherent across code, tests, configuration, and documentation.

5. Validate continuously:
   - Add or update tests for new behavior.
   - Run focused tests during implementation.
   - Run the full relevant test suite after integration.
   - Run configured formatter, linter, and type checker.
   - Fix regressions caused by the implementation.

6. Verify the milestone explicitly:
   - Re-read the original roadmap section after implementation.
   - Check every requirement one by one.
   - Search for TODOs, placeholders, stubs, temporary workarounds, and silently skipped items.
   - Verify user-facing behavior rather than relying only on code inspection.

7. Update documentation:
   - Update README, CLI help, examples, configuration docs, API docs, changelog, or migration notes when behavior changes.
   - Keep examples consistent with the final implementation.

8. Report completion accurately:
   - Summarize what was implemented.
   - State which validation commands were run and their results.
   - Disclose unresolved failures, environmental limitations, ambiguities, or intentionally deferred work.

## Rules

- Never claim a milestone is complete while known required items are missing.
- Never silently skip roadmap requirements.
- Never fabricate test, lint, type-check, build, or runtime results.
- Do not perform unrelated refactoring unless required to implement the milestone safely.
- Do not add speculative features beyond the requested roadmap scope.
- Preserve backward compatibility unless the roadmap explicitly requires a breaking change.
- Do not introduce dependencies without justification.
- If a requirement is ambiguous, infer intent from architecture, tests, documentation, git history, and adjacent roadmap entries before asking for clarification.
- If blocked by an actual external dependency or missing information, clearly identify the blocker instead of pretending completion.
- Before finishing, perform a final requirement-by-requirement audit.
