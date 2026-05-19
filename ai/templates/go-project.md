# Project Instructions

## Overview

<!-- Brief description of this Go project. -->

## Code Style

### Go

- Follow gofmt and go vet. Run `golangci-lint` if configured.
- Always check errors. No `_` for error returns unless justified.
- Prefer stdlib over third-party when reasonable.
- Tests: go test. Table-driven tests preferred.
- Use `context.Context` for cancellation and deadlines.

## Dependencies

- Add dependencies via `go get`. Keep go.mod tidy (`go mod tidy`).
- Prefer stdlib. Justify third-party additions.

## Git

- Commit messages: imperative mood, concise, describe "why".
- Do not commit unless asked.
- Stage specific files, not `git add -A`.

## Rules

- Fix the stated problem. Do not refactor beyond the request.
- Prefer simplicity over abstraction.
- No emojis. No trailing summaries.
