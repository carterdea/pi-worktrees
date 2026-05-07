#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$repo_dir"

shell_files=(
  bin/pi-worktree
  install.sh
  test.sh
  shell/pi.bash
  shell/pi.zsh
)

printf 'Checking shell syntax...\n'
bash -n bin/pi-worktree install.sh test.sh shell/pi.bash
zsh -n shell/pi.zsh

if command -v shfmt >/dev/null; then
  printf 'Formatting shell files with shfmt...\n'
  shfmt -w -i 2 "${shell_files[@]}"
else
  printf 'Skipping shfmt: not installed\n' >&2
fi

if command -v shellcheck >/dev/null; then
  printf 'Linting shell files with shellcheck...\n'
  shellcheck -x -s bash bin/pi-worktree install.sh test.sh shell/pi.bash
  shellcheck -x -s bash shell/pi.zsh
else
  printf 'Skipping shellcheck: not installed\n' >&2
fi

printf 'Running tests...\n'
./test.sh

printf 'PASS: checks\n'
