---
name: Verify before answering — never assume, always check
description: Critical pattern of acting before verifying and explaining before understanding. Applies to all tasks — database operations, debugging, answering questions.
type: feedback
---

Do not construct plausible-sounding answers from assumptions. When you don't know something, say "let me check" and actually check.

**Why:** On 2026-03-23, multiple failures in a single session shared the same root cause:
1. Ran a database anonymization script and trusted the "Done!" output without querying the actual data — real PII was left exposed.
2. When asked "how could I be logged in as 수수?", jumped to proposing solutions (TEST_SECRET, curl commands) instead of investigating what was actually happening.
3. Called a perfectly normal scenario "unlikely" without checking the facts.

Each time, the mistake was the same: acting/answering before verifying the actual state.

**How to apply:**
- When asked "why does X happen?" — check the actual state first (query the DB, read the logs, inspect the data), then answer.
- When a script/operation completes — verify the result by checking the actual data, not the exit code or output message.
- When uncertain — say "let me check" instead of constructing an explanation from assumptions.
- Never use words like "unlikely" or "probably" without evidence. Either check, or say you don't know.
- Do not propose solutions before understanding the problem.
