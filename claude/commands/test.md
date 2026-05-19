Analyze the current project and generate tests for recently changed code (use `git diff` to identify changes).

Rules:
- Use the project's existing test framework (pytest for Python, vitest/jest for TS, go test for Go)
- Test behavior, not implementation details
- No mocks unless explicitly needed for external dependencies
- Include edge cases: empty input, boundary values, error paths
- Follow existing test file naming and location conventions
