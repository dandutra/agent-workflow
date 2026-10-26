#!/bin/bash
# Stop: when TypeScript changed (uncommitted or untracked), run tsc and vitest.
# On failure, block the stop so Claude fixes it. Skips when already
# continuing from this hook, so it can't loop.
input=$(cat)
[ "$(jq -r '.stop_hook_active' <<<"$input")" = "true" ] && exit 0
cd "$CLAUDE_PROJECT_DIR" || exit 0

changed=$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | grep -E '\.(ts|tsx|mts|cts)$')
[ -n "$changed" ] || exit 0

out=$(npx --no-install tsc --noEmit 2>&1 && npx --no-install vitest run --reporter=dot 2>&1)
[ $? -eq 0 ] && exit 0

jq -n --arg r "Stop gate failed (tsc + vitest). Fix these before finishing, or tell the user why you can't:
$(printf '%s' "$out" | tail -n 40)" '{decision: "block", reason: $r}'
