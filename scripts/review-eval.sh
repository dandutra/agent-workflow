#!/usr/bin/env bash
# Replay /review on past first drafts with known bugs. See evals/review/README.md.
#   scripts/review-eval.sh [case-prefix]
set -euo pipefail

here=$(cd "$(dirname "$0")/.." && pwd)
prefix=${1:-}
out="$here/evals/review/runs/$(date +%F)"
mkdir -p "$out"
found=0 passed=0 failed=0

while IFS=$'\t' read -r name repo base head tier expect bug; do
  [[ -z $name || $name == \#* ]] && continue
  [[ $name == "$prefix"* ]] || continue
  found=$((found + 1))
  src="$HOME/Projects/$repo"
  wt=$(mktemp -d /tmp/rev-eval.XXXX)
  git -C "$src" worktree add -q --detach "$wt" "$head"
  echo "== $name (tier $tier): $bug"
  (cd "$wt" && claude -p "/review $base tier=$tier" \
      --allowedTools "Read Grep Glob Agent Skill Bash(git *) Bash(gh *) Bash(*tier.sh*)" \
      > "$out/$name.md" 2>&1) || echo "claude exited non-zero, see $out/$name.md"
  git -C "$src" worktree remove --force "$wt"
  if grep -qiE "$expect" "$out/$name.md"; then
    passed=$((passed + 1)); echo "PASS (regex matched; read $out/$name.md)"
  else
    failed=$((failed + 1)); echo "FAIL: no match for /$expect/ in $out/$name.md"
  fi
done < "$here/evals/review/cases.tsv"

echo "found=$found passed=$passed failed=$failed"
[ "$found" -gt 0 ] && [ "$failed" -eq 0 ]
