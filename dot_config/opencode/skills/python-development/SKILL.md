---
name: python-development
description: Develop, modify, test, and maintain Python projects while respecting existing tooling, architecture, environments, and project conventions.
---

# Python Development

Use this skill when implementing, modifying, reviewing, debugging, or testing Python code.

## Workflow

1. Inspect the repository before editing:
   - Read `pyproject.toml`, `uv.lock`, `requirements*.txt`, `Pipfile`, `poetry.lock`, `setup.py`, or `setup.cfg` when present.
   - Inspect the source layout, tests, CI configuration, and existing conventions.
   - Identify the Python version and dependency manager actually used by the project.

2. Detect and use the existing environment:
   - Prefer an existing `.venv` or project-specific virtual environment.
   - Respect `uv`, Poetry, PDM, Hatch, pip, or other configured tooling.
   - Do not create a second environment or change dependency managers without justification.
   - Run tools through the project's environment when required.

3. Follow existing architecture:
   - Match naming, typing, module organization, error handling, logging, and API patterns already present.
   - Prefer existing abstractions over new ones.
   - Avoid unrelated refactors.

4. Implement the smallest complete change that satisfies the task.
   - Keep functions focused.
   - Use precise type annotations where consistent with the project.
   - Do not add dependencies when the standard library or existing dependencies are sufficient.

5. Test and validate:
   - Run the relevant tests first when practical.
   - Run the complete test suite after substantial changes.
   - Use the project's configured commands rather than inventing alternatives.

6. Run quality checks when configured:
   - Ruff for linting and formatting.
   - BasedPyright or Pyright for static type checking.
   - pytest or the project's actual test runner.
   - Respect configuration in `pyproject.toml` and other project files.

7. Review the diff before declaring completion:
   - Check for accidental changes.
   - Check for debug prints, dead code, unused imports, temporary files, and exposed secrets.
   - Confirm the implementation actually satisfies the original request.

## Rules

- Never assume a virtual environment name when it can be detected.
- Never silently ignore lint, type-check, or test failures caused by your changes.
- Do not weaken type-checker, linter, or test configuration merely to make failures disappear.
- Do not use `# type: ignore`, `noqa`, broad exception handling, or similar suppressions unless justified.
- Do not add unnecessary dependencies.
- Do not rewrite working code solely to impose personal style preferences.
- Preserve backward compatibility unless a breaking change is explicitly required.
- Prefer root-cause fixes over symptom masking.
- Keep secrets, tokens, credentials, and local environment values out of source control.
