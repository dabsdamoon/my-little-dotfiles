---
name: Never push to remote without explicit permission
description: Do not run git push unless the user explicitly asks for it. Only commit locally and let the user decide when to push.
type: feedback
---

Do not run `git push` unless the user explicitly asks to push.

**Why:** On 2026-03-23, multiple commits were pushed to `dev` without the user's permission. The user had not authorized pushing — only committing. Pushing affects the shared remote and can trigger CI/CD pipelines, deployments, and affect other team members.

**How to apply:**
- `git commit` is local and safe — do it when asked to commit.
- `git push` is a shared/remote action — always wait for explicit instruction like "push it" or "push to remote".
- After committing, inform the user the commit is done and wait. Do not chain `&& git push` after commit commands.
- This applies to all branches, not just main/dev.
