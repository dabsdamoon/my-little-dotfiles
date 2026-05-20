# Package Install Safety Rule

## MANDATORY: Before running ANY package install command (pip install, npm install, yarn add, pnpm add, conda install), you MUST:

1. **Verify the package name** — Check for typosquatting (e.g., `requests` vs `requets`, `litellm` vs `liteIIm`)
2. **Check the package on PyPI/npm** — Verify the publisher, download count, age, and recent version history
3. **Check for known vulnerabilities** — Search for recent CVEs or supply chain advisories
4. **Review transitive dependencies** — List what the package pulls in transitively
5. **Pin to a specific version** — Never install without a version pin in production environments
6. **Report findings to the user** — Present a brief safety summary before proceeding

## Red flags to watch for:
- Package ownership recently transferred
- Sudden version bump with no clear changelog
- Very few downloads but recommended by AI/tutorials
- Package name is similar to a popular package (typosquatting)
- Post-install scripts that access network, filesystem, or env vars
- Dependencies that seem unrelated to the package's purpose

## If ANY red flag is found:
- STOP and warn the user explicitly
- Do NOT proceed with installation until user confirms

## This rule applies even when:
- Installing as a dependency of another package
- The user explicitly asks to install (still report findings)
- Running in a conda environment or virtualenv
