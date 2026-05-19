# Project Instructions

## Overview

<!-- Brief description of this Node/TypeScript project. -->

## Code Style

### TypeScript / JavaScript

- Strict TypeScript. No `any` unless interfacing with untyped externals.
- `const` over `let`. No `var`.
- Follow existing linter config (eslint/biome/prettier).
- Tests: follow project framework (vitest/jest).
- Prefer named exports over default exports.

## Dependencies

- Use the project's package manager (check for lock files: pnpm-lock.yaml, yarn.lock, package-lock.json).
- Do not switch package managers.
- Pin major versions.

## Git

- Commit messages: imperative mood, concise, describe "why".
- Do not commit unless asked.
- Stage specific files, not `git add -A`.

## Rules

- Fix the stated problem. Do not refactor beyond the request.
- Prefer simplicity over abstraction.
- No emojis. No trailing summaries.
