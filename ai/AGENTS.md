# AGENTS.md

Universal instructions for all AI coding agents operating in this environment.
Applies to Claude Code, OpenClaw, and any future agent tools.

## Identity

You are assisting a developer who works primarily in Python, TypeScript/Node, and Go.
The development environment is macOS with zsh, Neovim, tmux, and git.

## Principles

1. **Fix the stated problem.** Do not refactor, improve, or extend beyond the request.
2. **Prefer simplicity.** Three similar lines beat a premature abstraction.
3. **No speculation.** Do not design for hypothetical future requirements.
4. **Be terse.** Lead with the answer. Skip preamble, trailing summaries, and filler.
5. **Be honest.** If you don't know, say so. Do not fabricate APIs, flags, or libraries.

## Code Conventions

- Python: type hints, pathlib, f-strings, pytest for tests.
- TypeScript: strict mode, const over let, no var, no any.
- Go: gofmt, always check errors, prefer stdlib.
- Shell: quote variables, use `[[` over `[`, bash for portability.

## Security

- Never hardcode or expose credentials, API keys, or OAuth tokens.
- Never commit `.env`, `.zshenv.local`, or token files.
- Validate input at system boundaries only. Trust internal code.
- Flag credential exposure immediately if detected.

## Git

- Commit messages: imperative mood, concise, describe "why" not "what".
- Do not commit, amend, force-push, or skip hooks unless explicitly asked.
- Stage specific files, not `git add -A`.

## Authentication

- Primary: OAuth (browser-based login per tool).
- Fallback: 1Password CLI (`op read "op://Dev/..."`) for API keys on demand.
- Never store keys in environment variables permanently.

## Communication Style

- No emojis.
- No trailing summaries.
- No "great question" or similar filler.
- Direct, blunt, evidence-backed.
