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
pi -w -p "fix the bug"
pi -w branch-name
pi -w branch-name -p "fix the bug"
```

`pi -w` creates a git worktree, starts real Pi inside it, then asks whether to remove the worktree when Pi exits.

## Naming

By default, it uses a random Claude-style name:

```text
quiet-river
pi/quiet-river
```

Pass a name immediately after `-w` to use that worktree and branch name:

```text
pi -w feature-paywall
feature-paywall
pi/feature-paywall
```

Arguments starting with `-` are forwarded to Pi, so prompts use normal Pi flags:

```text
pi -w -p "fix the bug"
pi -w feature-paywall -p "fix the bug"
```

If the name is taken, it adds a random suffix:

```text
feature-paywall-quiet-river
pi/feature-paywall-quiet-river
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

## Check

```bash
./check.sh
```

Runs shell syntax checks, `shfmt`, `shellcheck`, and tests.

## Test

```bash
./test.sh
```
