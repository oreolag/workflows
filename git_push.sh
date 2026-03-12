#!/usr/bin/env bash
set -euo pipefail

msg="${1:-Update}"

# ensure we are inside a git repository
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: not inside a git repository"
  exit 1
}

cd "$(git rev-parse --show-toplevel)"

# configure git identity if missing
if ! git config user.name >/dev/null; then
  git config user.name "$(gh api user --jq .login)"
fi

if ! git config user.email >/dev/null; then
  git config user.email "$(gh api user --jq .login)@users.noreply.github.com"
fi

# if still on main, create a my_workflows branch 
branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" == "main" ]]; then
  git checkout -b my_workflows
  branch="my_workflows"
fi

git add -A

if git diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

git commit -m "$msg"
git push -u origin "$branch"