# Efficient Debugging & Test Creation Rules

## Core Principle: Investigate First, Code Second

**Every iteration costs time.** A test run, build, or deployment takes 60-120 seconds. Minimize iterations by understanding the problem fully BEFORE making changes.

```
❌ WRONG: Code → Run → Fail → Fix one thing → Run → Fail → Fix...
✅ RIGHT: Code → Run → Fail → INVESTIGATE ALL FAILURES → Fix ALL → Run once
```

---

## Rule 1: Screenshot-First Debugging

When any automated test fails:
1. **READ THE SCREENSHOT FIRST** before looking at error messages
2. Screenshots show actual page state - "element not found" often means "wrong page"
3. Compare expected vs actual screenshots before changing selectors

---

## Rule 2: Verify Navigation Before Testing Elements

Before writing tests for UI elements:
1. Write a 3-line test that navigates and screenshots
2. Verify you reached the correct page
3. THEN write element interaction tests

```python
# Always verify navigation works FIRST
def test_navigation():
    page.goto(url)
    screenshot(page, "verify_page")
    # CHECK THIS before writing more tests
```

---

## Rule 3: Don't Guess Selectors from Source Code

- React/Vue component props ≠ rendered HTML attributes
- Radix UI, shadcn, MUI render different HTML than their API suggests
- **Get real selectors from**: Browser DevTools, or test one selector first

---

## Rule 4: Batch Fixes, Don't Iterate

When multiple tests fail:
1. Analyze ALL failures first
2. Identify root causes (often 1-2 issues cause multiple failures)
3. Fix ALL issues in one edit
4. Run tests once

**Bad**: Fix test 1 → run → fix test 2 → run → fix test 3 → run (3 iterations)
**Good**: Analyze all → fix all → run once (1 iteration)

---

## Rule 5: Test Isolation

Each test must:
- Re-establish its required page state (don't assume previous test left it correctly)
- Clean up any state it modifies (filters, modals, localStorage)
- Be runnable independently

---

## Time Cost Reference

| Action | Time Cost |
|--------|-----------|
| Playwright test run | 60-120s |
| npm build | 30-60s |
| Read a screenshot | 2s |
| Ask user to check DevTools | 30s |

**Insight**: One screenshot check (2s) can save 3 unnecessary test runs (180s).
