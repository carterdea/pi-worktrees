# Pi worktree integration. Source this from ~/.zshrc.
pi() {
  case "${1:-}" in
    -w|--worktree|w)
      shift
      pi-worktree "$@"
      ;;
    *)
      command pi "$@"
      ;;
  esac
}
