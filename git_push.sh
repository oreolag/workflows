#!/usr/bin/env bash
set -euo pipefail

msg="Update"
if [[ $# -gt 0 && "$1" != --* ]]; then
  msg="$1"
  shift
fi

# get GITHUB_PUSH_BRANCH
github_branch=$(cat ./GITHUB_PUSH_BRANCH)

workflow=""
file=""

# format
bold=$(tput bold)
italic=$(tput sitm 2>/dev/null || true)
normal=$(tput sgr0)

print_help() {
  echo "Commit and push git changes for a workflow."
  echo
  echo "${bold}USAGE:${normal}"
  echo "  git_push.sh [flags]"
  echo
  echo "${bold}FLAGS:${normal}"
  echo "    --workflow   Workflow name"
  echo "    --file       File name"
  echo "    --comment    Commit subject"
  echo 
  echo "${bold}INHERITED FLAGS:${normal}"
  echo "  -h, --help       Show this help"
}

# parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
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

# interactive prompts
printf "workflow: " > /dev/tty
read -r workflow < /dev/tty

printf "file: " > /dev/tty
read -r file < /dev/tty

printf "comment: " > /dev/tty
read -r msg < /dev/tty

# resolve file
if [[ "$file" == *.sh ]]; then
  file="$workflow/$file"
  file_name="${file%.sh}"
else
  file="$workflow/$file.sh"
  file_name="$file"
fi

# validate workflow + file together (odev style)
if [[ ! -d "$workflow" ]] || [[ ! -f "$file" ]]; then
  echo "File not found: $workflow/$file_name"
  exit 1
fi

# configure git identity if missing
if ! git config user.name >/dev/null; then
  git config user.name "$(gh api user --jq .login)"
fi

if ! git config user.email >/dev/null; then
  git config user.email "$(gh api user --jq .login)@users.noreply.github.com"
fi

# create branch if needed
branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" == "main" ]]; then
  git checkout -b my_workflows
  branch="my_workflows"
fi

git add "$file"

if git diff --cached --quiet; then
  echo "Nothing to commit."
  exit 0
fi

git commit -m "$msg"
git push -u origin "$branch"