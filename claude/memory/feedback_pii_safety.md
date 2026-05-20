---
name: PII safety — never trust, always verify
description: Critical lesson from incident where anonymization SQL silently failed, leaving real emails and phone numbers exposed on dev database
type: feedback
---

Never combine database restore and anonymization into a single step. Always run them as separate, verified steps.

**Why:** On 2026-03-23, anonymization SQL was appended to a pg_dump file with `--clean` flag. The `--clean` flag generates DROP/CREATE TABLE statements mid-file, causing the appended anonymization SQL to silently fail. Real user emails and phone numbers were left exposed on the dev database. The script reported "Done!" without error.

**How to apply:**
1. When handling PII (emails, phone numbers, names), ALWAYS verify the actual data after any operation — never trust script output or exit codes alone.
2. Run database operations as separate steps: restore → verify restore → anonymize → verify anonymization.
3. Always do a dry run against a local/test database before running against any remote database.
4. When there's a trade-off between theoretical risk (e.g., cron timing window) and concrete risk (e.g., silent failure), prioritize preventing the concrete risk.
5. After any destructive or sensitive database operation, immediately query the database to confirm the expected state — SELECT before declaring success.
