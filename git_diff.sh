#!/usr/bin/env bash
set -euo pipefail

workflow=""
command=""

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

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: not inside a git repository"
  exit 1
}

cd "$(git rev-parse --show-toplevel)"

if [[ ! -r /dev/tty || ! -w /dev/tty ]]; then
  echo "git_dif.sh: not interactive"
  exit 1
fi

if [[ -z "$workflow" ]]; then
  printf 'workflow: ' > /dev/tty
  read -r workflow < /dev/tty
fi

if [[ -z "$command" ]]; then
  printf 'command: ' > /dev/tty
  read -r command < /dev/tty
fi

if [[ -z "$workflow" ]]; then
  echo "Missing required flag: --workflow"
  exit 1
fi

if [[ -z "$command" ]]; then
  git diff -- "$workflow/"
else
  git diff -- "$workflow/$command.sh"
fi