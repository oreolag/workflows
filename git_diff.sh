#!/usr/bin/env bash
set -euo pipefail

workflow=""
command=""

# format
bold=$(tput bold)
italic=$(tput sitm 2>/dev/null || true)
normal=$(tput sgr0)

print_help() {
  echo "Show git differences for a workflow or workflow command."
  echo
  echo "${bold}USAGE:${normal}"
  echo "  git_diff.sh [flags]"
  echo
  echo "${bold}FLAGS:${normal}"
  echo "    --workflow   Workflow name"
  echo "    --command    Command name (new, build, ${italic}program,${normal} run, validate)"
  echo
  echo "${bold}INHERITED FLAGS:${normal}"
  echo "  -h, --help       Show this help"
}

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
    --help|-h)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# -----------------------------
# Ensure inside git repository
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
# Validate workflow
# -----------------------------
if [[ ! -d "$workflow" ]]; then
  echo "Workflow not found: $workflow"
  exit 1
fi

# -----------------------------
# Determine file
# -----------------------------
if [[ -n "$command" ]]; then
  if [[ "$command" == *.sh ]]; then
    file="$workflow/$command"
    command_name="${command%.sh}"
  else
    file="$workflow/$command.sh"
    command_name="$command"
  fi

  if [[ ! -f "$file" ]]; then
    echo "Command not found: $command_name $workflow"
    exit 1
  fi

  # tracked file
  if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    git diff -- "$file"
  else
    # untracked file
    git diff --no-index /dev/null "$file" || true
  fi

else
  # diff entire workflow
  find "$workflow" -type f | while read -r file; do
    if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
      git diff -- "$file"
    else
      git diff --no-index /dev/null "$file" || true
    fi
  done
fi