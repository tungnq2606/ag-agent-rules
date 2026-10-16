#!/usr/bin/env bash
# Keep my AGENTS.md instead of the team's. Source of truth: .ai/AGENTS.mine.md
#   keep-mine.sh            re-apply my copy + skip-worktree (used by git hooks)
#   keep-mine.sh up [args]  safe `git pull [args]`: park my copy, pull, put it back
set -uo pipefail
root=$(git rev-parse --show-toplevel) && cd "$root" || exit 0
mine=.ai/AGENTS.mine.md
[ -f "$mine" ] || exit 0
gitdir=$(git rev-parse --git-dir)

restore() {
  # never touch the file in the middle of a rebase/merge
  [ -e "$gitdir/rebase-merge" ] || [ -e "$gitdir/rebase-apply" ] || [ -e "$gitdir/MERGE_HEAD" ] && return 0
  cmp -s "$mine" AGENTS.md || cp "$mine" AGENTS.md
  git update-index --skip-worktree AGENTS.md
  now=$(git show HEAD:AGENTS.md 2>/dev/null | shasum | cut -d' ' -f1)
  if [ "$now" != "$(cat .ai/AGENTS.team.sha 2>/dev/null)" ]; then
    echo "keep-mine: team AGENTS.md changed upstream. Review: git diff --no-index $mine <(git show HEAD:AGENTS.md)" >&2
    echo "keep-mine: then run: git show HEAD:AGENTS.md | shasum | cut -d' ' -f1 > .ai/AGENTS.team.sha" >&2
  fi
}

case "${1:-restore}" in
  restore) restore ;;
  up)
    shift
    git update-index --no-skip-worktree AGENTS.md
    git checkout -- AGENTS.md
    git pull "$@"; rc=$?
    restore
    exit $rc ;;
  *) echo "usage: keep-mine.sh [restore|up [git pull args]]" >&2; exit 2 ;;
esac
