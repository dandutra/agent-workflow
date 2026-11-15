#!/usr/bin/env bash
# Pick a review tier (0-3) for the diff <fixed-point>...HEAD and print the signals behind it.
#   tier.sh <fixed-point> [ticket-tier]
# Path globs come from the ```review-tiers block in REVIEW.md (override with REVIEW_FILE).
# Run from the repo root. Exits non-zero when the diff is empty.
set -euo pipefail

base=${1:?usage: tier.sh <fixed-point> [ticket-tier]}
floor=${2:-0}
review_file=${REVIEW_FILE:-REVIEW.md}

is_test() { [[ $1 == *test* || $1 == *spec* || $1 == *__tests__* || $1 == *fixtures* ]]; }
is_source() { [[ $1 == *.ts || $1 == *.tsx || $1 == *.js || $1 == *.mjs || $1 == *.go || $1 == *.py ]]; }

globs() { # globs listed under "<key>:" in the review-tiers block
  [ -f "$review_file" ] || return 0
  awk -v key="$1:" '
    /^```review-tiers/ {inblock=1; next}
    inblock && /^```/ {inblock=0}
    inblock && $1 == key {grab=1; next}
    inblock && /^[a-z]+:/ {grab=0}
    inblock && grab && $1 == "-" {print $2}' "$review_file"
}

matches() { # matches <path> <glob>...; * spans slashes inside [[ ]]
  local f=$1 g; shift
  for g in "$@"; do [[ $f == $g ]] && return 0; done
  return 1
}

critical=(); while IFS= read -r g; do critical+=("$g"); done < <(globs critical)
low=('*.md' 'docs/*' 'LICENSE'); while IFS= read -r g; do low+=("$g"); done < <(globs low)

files=(); while IFS= read -r f; do files+=("$f"); done < <(git diff --name-only "$base"...HEAD)
[ ${#files[@]} -gt 0 ] || { echo "empty diff against $base"; exit 1; }

lines=$(git diff --numstat "$base"...HEAD | awk '$1 != "-" {print $1 + $2 "\t" $3}' |
  while IFS=$'\t' read -r n f; do is_test "$f" || echo "$n"; done | awk '{s += $1} END {print s + 0}')

all_low=1; crit_hits=(); untested=(); fanin_hits=(); external=()
tests=$(git ls-files | while IFS= read -r t; do is_test "$t" && echo "$t"; done || true)
for f in "${files[@]}"; do
  matches "$f" "${low[@]}" || all_low=0
  [ ${#critical[@]} -gt 0 ] && matches "$f" "${critical[@]}" && crit_hits+=("$f")
  is_source "$f" && ! is_test "$f" && [ -f "$f" ] || continue
  name=$(basename "$f"); name=${name%%.*}; [ "$name" = index ] && name=$(basename "$(dirname "$f")")
  if [ -n "$tests" ] && ! grep -qw -- "$name" $tests 2>/dev/null; then untested+=("$f"); fi
  importers=$(git grep -lE "(from|require\(|import) .*['\"][^'\"]*/$name(\.[a-z]+)?['\"]" -- . 2>/dev/null | wc -l | tr -d ' ' || true)
  [ "$importers" -ge 8 ] && fanin_hits+=("$f ($importers importers)")
  grep -qE '\bfetch\(|axios|http\.(Get|Post|NewRequest)|requests\.(get|post)|httpx\.' "$f" && external+=("$f")
done

signals=()
[ "$lines" -gt 300 ] && signals+=("size: $lines non-test lines (>300)")
[ "$lines" -gt 800 ] && signals+=("size: over 800 non-test lines")
[ ${#untested[@]} -gt 0 ] && signals+=("no test names the module: ${untested[*]}")
[ ${#fanin_hits[@]} -gt 0 ] && signals+=("fan-in: ${fanin_hits[*]}")

if [ ${#crit_hits[@]} -gt 0 ]; then tier=3
elif [ $all_low = 1 ]; then tier=0
else tier=$((1 + ${#signals[@]})); [ $tier -gt 3 ] && tier=3
fi
computed=$tier
[ "$floor" -gt "$tier" ] && tier=$floor

echo "tier $tier"
[ "$floor" -gt "$computed" ] && echo "- ticket floor $floor raised it from $computed"
[ "$floor" -gt 0 ] && [ "$computed" -gt "$floor" ] && echo "- computed tier $computed is above the ticket's tier $floor"
[ ${#crit_hits[@]} -gt 0 ] && echo "- critical paths: ${crit_hits[*]}"
[ $all_low = 1 ] && echo "- every file is on a low path"
for s in ${signals[@]+"${signals[@]}"}; do echo "- $s"; done
[ ${#external[@]} -gt 0 ] && echo "- live check required (calls an external API): ${external[*]}"
echo "files=${#files[@]} non_test_lines=$lines"
