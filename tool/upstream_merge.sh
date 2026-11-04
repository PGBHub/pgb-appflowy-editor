#!/usr/bin/env bash
# Modified by PGBHub: PGBHub's own script (not from upstream). MPL-2.0.
#
# Brings a newer upstream appflowy_editor release into this fork as a
# three-way merge: the pristine 6.2.0 archive (or whatever PGB_FORK.md names
# as the base) is the common ancestor, this package is "ours", the new
# release is "theirs". PGBHub's changes (the files marked "Modified by
# PGBHub") are carried over; conflicts are left with markers to resolve by
# hand. Nothing is committed.
#
#   tool/upstream_merge.sh <new-version> [<base-version>]
#   tool/upstream_merge.sh 6.3.0          # base defaults to 6.2.0
#
# Afterwards: resolve conflicts (grep -rn '<<<<<<<' lib), update PGB_FORK.md
# (base version, version x.y.z+pgb.1, the table of changes), then run
# `flutter pub get && flutter analyze && flutter test` here and the app's
# test/features/docs_edit tests.
set -euo pipefail

NEW="${1:?usage: tool/upstream_merge.sh <new-version> [<base-version>]}"
BASE="${2:-6.2.0}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fetch() { # version dir
  mkdir -p "$2"
  curl -fsSL "https://pub.dev/api/archives/appflowy_editor-$1.tar.gz" | tar -xz -C "$2"
}

echo "Fetching appflowy_editor $BASE (base) and $NEW (upstream)…"
fetch "$BASE" "$WORK/base"
fetch "$NEW" "$WORK/new"

# Only what the fork carries (no example/, test/, documentation/).
merged=0
conflicts=0
added=0
cd "$WORK/new"
while IFS= read -r -d '' f; do
  rel="${f#./}"
  case "$rel" in example/*|test/*|documentation/*) continue ;; esac
  ours="$HERE/$rel"
  base="$WORK/base/$rel"
  if [ ! -e "$ours" ]; then
    mkdir -p "$(dirname "$ours")"
    cp "$f" "$ours"
    added=$((added + 1))
    continue
  fi
  if [ ! -e "$base" ]; then base=/dev/null; fi
  if cmp -s "$ours" "$base"; then
    # Unchanged by PGBHub: take upstream's.
    cp "$f" "$ours"
    continue
  fi
  # Changed by PGBHub: three-way merge into ours.
  if git merge-file -L pgb -L "upstream-$BASE" -L "upstream-$NEW" "$ours" "$base" "$f"; then
    merged=$((merged + 1))
  else
    conflicts=$((conflicts + 1))
    echo "CONFLICT: $rel"
  fi
done < <(find . -type f -print0)

# Files upstream removed (and PGBHub never changed) go too.
cd "$WORK/base"
while IFS= read -r -d '' f; do
  rel="${f#./}"
  case "$rel" in example/*|test/*|documentation/*) continue ;; esac
  if [ ! -e "$WORK/new/$rel" ] && [ -e "$HERE/$rel" ] && cmp -s "$HERE/$rel" "$f"; then
    rm "$HERE/$rel"
    echo "removed upstream: $rel"
  fi
done < <(find . -type f -print0)

echo "Done: $merged PGBHub-modified files merged, $added new, $conflicts with conflicts."
echo "Next: resolve conflicts, update PGB_FORK.md and pubspec.yaml (version $NEW+pgb.1), run the checks."
