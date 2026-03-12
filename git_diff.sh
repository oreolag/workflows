#!/usr/bin/env bash
set -euo pipefail

workflow=""
command=""

# -----------------------------
# Parse flags
# -----------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --workflow)
      workflow="${2:-}"
      shift 2
      ;;
    --command)
      command="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# -----------------------------
# Ensure inside git repo
# -----------------------------
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: not inside a git repository"
  exit 1
}

cd "$(git rev-parse --show-toplevel)"

# -----------------------------
# Interactive prompt
# -----------------------------
if [[ -z "$workflow" ]]; then
  printf "workflow: " > /dev/tty
  read -r workflow < /dev/tty
fi

if [[ -z "$command" ]]; then
  printf "command: " > /dev/tty
  read -r command < /dev/tty
fi

# -----------------------------
# Determine target
# -----------------------------
if [[ -n "$command" ]]; then
  if [[ "$command" == *.sh ]]; then
    file="$workflow/$command"
  else
    file="$workflow/$command.sh"
  fi

  if [[ ! -f "$file" ]]; then
    echo "File not found: $file"
    exit 1
  fi

  if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    git diff -- "$file"
  else
    git diff --no-index /dev/null "$file" || true
  fi

else
  if [[ ! -d "$workflow" ]]; then
    echo "Workflow not found: $workflow"
    exit 1
  fi

  find "$workflow" -type f | while read -r file; do
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
      git diff -- "$file"
    else
      git diff --no-index /dev/null "$file" || true
    fi
  done
fi