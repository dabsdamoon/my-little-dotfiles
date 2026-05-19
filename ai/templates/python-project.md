# Project Instructions

## Overview

<!-- Brief description of this Python project. -->

## Code Style

### Python

- Type hints on all public functions.
- Use pathlib over os.path.
- Use f-strings over `.format()` or `%`.
- Prefer dataclasses or Pydantic models over raw dicts.
- Tests: pytest. No mocks unless needed for external dependencies.
- Formatter/linter: follow project config (ruff/black/isort).

## Dependencies

- Add new dependencies to pyproject.toml (or requirements.txt if that's what the project uses).
- Pin major versions. Do not upgrade existing deps without being asked.

## Git

- Commit messages: imperative mood, concise, describe "why".
- Do not commit unless asked.
- Stage specific files, not `git add -A`.

## Rules

- Fix the stated problem. Do not refactor beyond the request.
- Prefer simplicity over abstraction.
- No emojis. No trailing summaries.
