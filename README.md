# pi-worktrees

Claude-style git worktrees for Pi without forking Pi.

## Install

```bash
git clone git@github.com:carterdea/pi-worktrees.git ~/.local/share/pi-worktrees
~/.local/share/pi-worktrees/install.sh
echo 'source "$HOME/.local/share/pi-worktrees/shell/pi.zsh"' >> ~/.zshrc
```

Open a new shell or run:

```bash
source ~/.zshrc
```

## Usage

```bash
pi -w
pi --worktree
pi w
pi -w "fix the bug"
```

`pi -w` creates a git worktree, starts real Pi inside it, then asks whether to remove the worktree when Pi exits.

## Naming

If you are on a branch, it uses the branch name:

```text
feature-paywall
pi/feature-paywall
```

If that name is taken, it adds a random suffix:

```text
feature-paywall-quiet-river
pi/feature-paywall-quiet-river
```

If you are detached, it uses a random Claude-style name:

```text
quiet-river
pi/quiet-river
```

## Environment

```bash
PI_WORKTREE_ROOT=/some/path pi -w
PI_WORKTREE_CLEANUP=keep pi -w
PI_WORKTREE_CLEANUP=remove pi -w
```

Default worktree root:

```text
../.pi-worktrees/<repo>
```

## Test

```bash
./test.sh
```
