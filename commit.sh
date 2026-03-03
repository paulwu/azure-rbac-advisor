#!/usr/bin/env bash
# One-shot commit + push for pending agent instruction changes.
# Run: bash commit.sh
set -e
cd "$(git rev-parse --show-toplevel)"

git add .github/agents/azure-rbac-advisor.agent.md \
        log/.gitkeep answer/.gitkeep \
        .gitignore setup.sh Makefile README.md 2>/dev/null || true

if git diff --cached --quiet; then
  echo "Nothing to commit — already up to date."
  exit 0
fi

git commit -m "Add multi-resource table format to agent instructions

- Add Multi-Resource Table Format section with 3-column table layout
  (Resource | Least-Privileged Role to Create | Cross-Resource Access Required)
- Column 3 lists each dependency with role + access type per dependency
- Handles read-vs-write split for same dependency (e.g., AKV Secrets User vs Officer)
- Pre-create log/ and answer/ runtime directories with .gitkeep
- Update .gitignore to pattern-based exclusion (log/*.md, answer/*.md)
- Add setup.sh and Makefile for post-clone directory setup
- Update README with First-Time Setup section

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

git push origin main
echo "✅ Pushed to origin/main"

# Self-remove after successful run
rm -f "$0"
