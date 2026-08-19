---
name: fastapi-development
description: Develops, debugs, reviews, and tests Python FastAPI applications using modern FastAPI, Pydantic v2, SQLite, Ruff, BasedPyright, pytest, and available MCP tools.
---

# FastAPI Development

Use this skill when implementing, modifying, debugging, reviewing, or testing a FastAPI application.

## General principles

- Use modern Python type annotations.
- Follow Pydantic v2 conventions.
- Keep route handlers thin.
- Separate HTTP concerns from business logic.
- Avoid unnecessary abstraction.
- Prefer dependency injection for shared application dependencies.
- Use async functions only when performing genuinely asynchronous I/O.
- Never use blocking I/O inside async routes without appropriate handling.

## Before modifying code

1. Inspect the existing project structure.
2. Understand existing conventions before introducing new patterns.
3. Use Context7 when current FastAPI, Pydantic, SQLAlchemy, or other library documentation is needed.
4. Do not guess library APIs when documentation can be checked.

## API development

When creating or modifying endpoints:

1. Define explicit request and response models.
2. Use appropriate HTTP status codes.
3. Handle expected errors explicitly.
4. Avoid leaking internal implementation details in error responses.
5. Preserve backward compatibility unless breaking changes are explicitly requested.
6. Ensure the generated OpenAPI schema accurately represents endpoint behavior.

## API testing

After changing an endpoint:

1. Run relevant automated tests.
2. Use the OpenAPI MCP when available to inspect and call affected endpoints.
3. Test the happy path.
4. Test malformed and invalid input.
5. Test missing resources.
6. Test boundary values.
7. Test authentication and authorization when applicable.
8. Verify database side effects when applicable.
9. Retest after fixing failures.

## SQLite

When working with SQLite:

- Inspect the existing schema before modifying database code.
- Do not perform destructive operations without understanding their consequences.
- Use transactions where atomicity matters.
- Avoid relying on SQLite behavior that differs significantly from the production database, if another production database is used.
- Verify database state after API operations that modify data.

## Code quality

After meaningful Python changes:

1. Run Ruff.
2. Run BasedPyright.
3. Run relevant pytest tests.
4. Fix errors caused by the changes.
5. Do not silence type errors or lint rules merely to make checks pass unless justified.

## Verification

Never claim a change works merely because the code looks correct.

When possible:

1. Run the application or relevant tests.
2. Exercise affected API endpoints.
3. Inspect actual responses.
4. Verify expected database state.
5. Report any validation that could not be performed.

## Safety

- Never expose secrets or API keys.
- Never modify production data without explicit authorization.
- Prefer read-only database inspection when debugging.
- Do not run destructive database commands unless explicitly necessary and authorized.
