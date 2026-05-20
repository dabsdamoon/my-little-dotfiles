#!/usr/bin/env bash
# Claude Code pre-command hook: audit package installs before execution
# Blocks pip/npm/yarn/pnpm install commands and requires explicit user review
#
# This hook reads the command from the tool_input JSON via stdin.
# Exit 0 = allow, exit 2 = block (non-blocking soft error)

set -euo pipefail

# Read the JSON input from stdin
INPUT=$(cat)

# Extract the command from tool_input
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null || echo "")

# If we can't parse the command, allow it (don't break other tools)
if [ -z "$COMMAND" ]; then
    exit 0
fi

# Check if this is a package install command
IS_INSTALL=false
PKG_MANAGER=""

# pip install (but not pip install -e . which is local)
if echo "$COMMAND" | grep -qE '(^|\s|&&|\|)(pip|pip3|python3?\s+-m\s+pip)\s+install\s' ; then
    # Allow local installs (pip install -e . or pip install .)
    if echo "$COMMAND" | grep -qE 'pip3?\s+install\s+(-e\s+)?\.(\s|$)'; then
        exit 0
    fi
    IS_INSTALL=true
    PKG_MANAGER="pip"
fi

# npm/yarn/pnpm install with package names
if echo "$COMMAND" | grep -qE '(^|\s|&&|\|)(npm|yarn|pnpm)\s+(install|add|i)\s+[a-zA-Z@]' ; then
    IS_INSTALL=true
    PKG_MANAGER="npm/yarn/pnpm"
fi

# conda install
if echo "$COMMAND" | grep -qE '(^|\s|&&|\|)conda\s+(install|run\s+.*install)\s' ; then
    IS_INSTALL=true
    PKG_MANAGER="conda"
fi

if [ "$IS_INSTALL" = false ]; then
    exit 0
fi

# Block with an informative message on stderr so Claude Code surfaces it
cat >&2 <<EOF

===================================================================
  PACKAGE INSTALL INTERCEPTED ($PKG_MANAGER)
===================================================================

Command: $COMMAND

BEFORE APPROVING, Claude must verify:

1. PACKAGE LEGITIMACY
   - Is this the correct package name? (typosquatting check)
   - Who is the publisher/maintainer?
   - How many downloads / how old is the package?

2. RECENT CHANGES
   - Any ownership transfers recently?
   - Any suspicious recent version bumps?
   - Check: https://snyk.io/advisor/ or https://socket.dev/

3. DEPENDENCY TREE
   - What transitive dependencies does this pull in?
   - Run: pip download --no-binary :all: --no-deps <pkg> (dry run)
   - Or: npm info <pkg> dependencies

4. ALTERNATIVES
   - Is there a more established alternative?
   - Can we pin to a known-good version?

===================================================================
  Ask the user to confirm after reviewing the above.
===================================================================
EOF

# Exit 2 = soft block (shows message but doesn't crash)
exit 2
