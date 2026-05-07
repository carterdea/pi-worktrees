#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
test_tmp=""

cleanup() {
  [[ -z "$test_tmp" ]] || rm -rf "$test_tmp"
}

assert_eq() {
  local expected="$1" actual="$2" message="$3"
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL: %s\nexpected: %s\nactual:   %s\n' "$message" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_match() {
  local value="$1" pattern="$2" message="$3"
  if [[ ! "$value" =~ $pattern ]]; then
    printf 'FAIL: %s\nvalue:   %s\npattern: %s\n' "$message" "$value" "$pattern" >&2
    exit 1
  fi
}

make_fake_pi() {
  local bin_dir="$1"
  mkdir -p "$bin_dir"
  cat >"$bin_dir/pi" <<'FAKE_PI'
#!/usr/bin/env bash
printf 'FAKE_PI_CWD=%s\n' "$PWD"
printf 'FAKE_PI_ARGS=%s\n' "$*"
FAKE_PI
  chmod +x "$bin_dir/pi"
}

make_repo() {
  local dir="$1" branch="$2"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" config user.email test@example.com
  git -C "$dir" config user.name 'Test User'
  printf 'hello\n' >"$dir/file.txt"
  git -C "$dir" add file.txt
  git -C "$dir" commit -q -m init
  git -C "$dir" switch -q -c "$branch"
}

run_with_fake_pi() {
  local cwd="$1"
  shift
  (cd "$cwd" && PATH="$repo_dir/bin:$fake_bin:$PATH" PI_WORKTREE_CLEANUP=remove "$@" 2>&1)
}

extract_value() {
  local key="$1" input="$2"
  printf '%s\n' "$input" | awk -F= -v key="$key" '$1 == key { print $2; exit }'
}

main() {
  local repo fake_bin output worktree_path args_line base
  test_tmp="$(mktemp -d)"
  trap cleanup EXIT

  fake_bin="$test_tmp/bin"
  repo="$test_tmp/repo"
  make_fake_pi "$fake_bin"
  make_repo "$repo" feature/test-wrapper

  # shell integration should pass normal pi calls through to real pi on PATH.
  # shellcheck source=/dev/null
  source "$repo_dir/shell/pi.zsh"
  output="$(PATH="$repo_dir/bin:$fake_bin:$PATH" pi --version)"
  assert_match "$output" '^FAKE_PI_CWD=' 'normal pi calls are delegated'

  output="$(run_with_fake_pi "$repo" pi -w --foo 'bar baz')"
  printf '%s\n' "$output"
  worktree_path="$(extract_value FAKE_PI_CWD "$output")"
  args_line="$(extract_value FAKE_PI_ARGS "$output")"
  assert_eq 'feature-test-wrapper' "$(basename "$worktree_path")" 'branch worktree uses clean branch slug'
  assert_eq '--foo bar baz' "$args_line" 'pi args are forwarded into the worktree'
  [[ ! -e "$worktree_path" ]] || {
    printf 'FAIL: worktree was not removed: %s\n' "$worktree_path" >&2
    exit 1
  }

  output="$(run_with_fake_pi "$repo" pi -w)"
  printf '%s\n' "$output"
  worktree_path="$(extract_value FAKE_PI_CWD "$output")"
  base="$(basename "$worktree_path")"
  assert_match "$base" '^feature-test-wrapper-[a-z]+-[a-z]+$' 'collision adds random suffix'

  git -C "$repo" checkout -q --detach HEAD
  output="$(run_with_fake_pi "$repo" pi -w)"
  printf '%s\n' "$output"
  worktree_path="$(extract_value FAKE_PI_CWD "$output")"
  base="$(basename "$worktree_path")"
  assert_match "$base" '^[a-z]+-[a-z]+$' 'detached HEAD uses random name'

  set +e
  output="$(run_with_fake_pi "$test_tmp" pi -w)"
  status=$?
  set -e
  assert_eq '1' "$status" 'outside git repo exits with failure'
  assert_match "$output" 'pi -w: not inside a git repository' 'outside git repo prints clear error'

  printf 'PASS: pi-worktree tests\n'
}

main "$@"
