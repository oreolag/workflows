#!/usr/bin/env bash
set -euo pipefail

msg="Update"
if [[ $# -gt 0 && "$1" != --* ]]; then
  msg="$1"
  shift
fi

workflow=""
command=""
interactive="0"

# format
bold=$(tput bold)
italic=$(tput sitm 2>/dev/null || true)
normal=$(tput sgr0)

print_help() {
  echo "Commit and push git changes for a workflow or workflow command."
  echo
  echo "${bold}USAGE:${normal}"
  echo "  git_push.sh [comment] [flags]"
  echo
  echo "${bold}FLAGS:${normal}"
  echo "    --workflow   Workflow name"
  echo "    --command    Command name (new, build, ${italic}program,${normal} run, validate)"
  echo "    --comment    Commit subject"
  echo
  echo "${bold}INHERITED FLAGS:${normal}"
  echo "  -h, --help       Show this help"
}

# parse flags
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
    --comment)
      interactive="1"
      shift
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

# ensure we are inside a git repository
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: not inside a git repository"
  exit 1
}

cd "$(git rev-parse --show-toplevel)"

# interactive prompt
if [[ "$interactive" == "1" ]]; then
  if [[ -z "$workflow" ]]; then
    printf "workflow: " > /dev/tty
    read -r workflow < /dev/tty
  fi

  if [[ -z "$command" ]]; then
    printf "command: " > /dev/tty
    read -r command < /dev/tty
  fi

  printf "comment: " > /dev/tty
  read -r msg < /dev/tty
fi

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

# stage changes
if [[ -n "$workflow" ]]; then
  if [[ ! -d "$workflow" ]]; then
    echo "Workflow not found: $workflow"
    exit 1
  fi

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

    git add "$file"
  else
    git add "$workflow"
  fi
else
  git add -A
fi

if git diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

git commit -m "$msg"
git push -u origin "$branch"