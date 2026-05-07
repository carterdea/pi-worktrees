# Pi worktree integration. Source this from ~/.bashrc.
pi() {
  case "${1:-}" in
  -w | --worktree | w)
    shift
    pi-worktree "$@"
    ;;
  *)
    command pi "$@"
    ;;
  esac
}
