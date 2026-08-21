#!/usr/bin/env bash
#
# Fail when an agent-facing document points at a file that does not exist.
#
# A dead pointer is worse than a missing one: the agent reaches for the material,
# finds nothing, and invents a replacement.
#
# Usage:
#   bash scripts/validate-pointers.sh [repo-root]     # default: repo containing this script
#
# Scans every .md under the repo root (excluding .git/, legacy/, node_modules/) for:
#   1. markdown links            [text](some/file.md)
#   2. backtick-quoted paths     `.ai/rules/code-style.md`
#
# A candidate counts as resolved if it exists in any of these, in order:
#   the owner's directory, owner/references/, owner/rules/, the repo root.
# That mirrors how an agent actually looks for the file, so a pass here means
# the agent finds something — not necessarily the right something. A bare name
# in a nested document that resolves only at the root is reported as WEAK,
# because a same-named neighbour could just as easily win.
#
# Written for bash 3.2 (macOS system bash): no mapfile, no associative arrays.

set -uo pipefail

ROOT="$(cd "${1:-$(dirname "${BASH_SOURCE[0]}")/..}" && pwd)"
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[0;33m'; CYAN=$'\033[0;36m'; NC=$'\033[0m'

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

: > "$TMP/dead"
: > "$TMP/weak"

# Placeholders, URLs, and absolute paths are not pointers into this repo.
is_placeholder() {
  case "$1" in
    *'<'*|*'>'*|*'*'*|*'$'*|*' '*|*'{'*|*'|'*) return 0 ;;
    http*|'#'*|/*|'~'*) return 0 ;;
    '') return 0 ;;
  esac
  return 1
}

# Prints the resolution kind: "owner", "root", or "" when nothing exists.
resolve_kind() {
  candidate="$1"
  owner_dir="$2"

  case "$candidate" in
    .ai/*|.agents/*|.claude/*|scripts/*|legacy/*)
      if [ -f "$ROOT/$candidate" ]; then printf 'owner'; else printf ''; fi
      return ;;
  esac

  stripped="${candidate#./}"
  for p in "$owner_dir/$stripped" "$owner_dir/references/$stripped" "$owner_dir/rules/$stripped"; do
    if [ -f "$p" ]; then printf 'owner'; return; fi
  done

  # A path containing a slash must not fall back to the repo root.
  case "$stripped" in
    */*) printf ''; return ;;
  esac

  if [ -f "$ROOT/$stripped" ]; then printf 'root'; else printf ''; fi
}

find "$ROOT" -name '*.md' \
  -not -path '*/.git/*' -not -path '*/legacy/*' -not -path '*/node_modules/*' \
  | sort > "$TMP/files"

file_count=$(wc -l < "$TMP/files" | tr -d ' ')

while IFS= read -r file; do
  owner_dir="$(dirname "$file")"
  rel_file="${file#"$ROOT"/}"

  {
    grep -oE '\]\([^)]+\.md\)' "$file" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//'
    grep -oE '`[^`]+\.md`' "$file" 2>/dev/null | tr -d '`'
  } | sort -u > "$TMP/candidates"

  while IFS= read -r candidate; do
    candidate="${candidate%%#*}"
    is_placeholder "$candidate" && continue
    case "$(resolve_kind "$candidate" "$owner_dir")" in
      owner) : ;;
      root)
        case "$rel_file" in
          */*) printf '%sWEAK%s %s → %s (resolves only at repo root)\n' \
                 "$YELLOW" "$NC" "$rel_file" "$candidate" >> "$TMP/weak" ;;
        esac
        ;;
      *) printf '%sDEAD%s %s → %s\n' "$RED" "$NC" "$rel_file" "$candidate" >> "$TMP/dead" ;;
    esac
  done < "$TMP/candidates"
done < "$TMP/files"

cat "$TMP/dead" "$TMP/weak"

dead_count=$(wc -l < "$TMP/dead" | tr -d ' ')
weak_count=$(wc -l < "$TMP/weak" | tr -d ' ')

echo
if [ "$dead_count" -eq 0 ]; then
  printf '%s✓%s %s documents scanned, every pointer resolves' "$GREEN" "$NC" "$file_count"
  [ "$weak_count" -gt 0 ] && printf ' (%s weak)' "$weak_count"
  printf '.\n'
  exit 0
fi

printf '%s✗%s %s dead pointer(s), %s weak, across %s documents.\n' \
  "$RED" "$NC" "$dead_count" "$weak_count" "$file_count"
printf '%sFix each dead one: write the missing file, or delete the pointer. Never leave it dangling.%s\n' \
  "$CYAN" "$NC"
exit 1
