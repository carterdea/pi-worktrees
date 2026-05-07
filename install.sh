#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
mkdir -p "$HOME/.local/bin"
ln -sf "$repo_dir/bin/pi-worktree" "$HOME/.local/bin/pi-worktree"
printf 'Installed pi-worktree -> %s/bin/pi-worktree\n' "$repo_dir"
printf 'Add this to ~/.zshrc:\n\n  source "%s/shell/pi.zsh"\n\n' "$repo_dir"
