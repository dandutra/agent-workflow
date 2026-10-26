#!/bin/bash
# Stop: when Go, go.mod/go.sum or a //go:embed'ed file changed (uncommitted or
# untracked), run build, vet and test. gofmt runs per edit; staticcheck runs in CI.
# On failure, block the stop so Claude fixes it. Skips when already
# continuing from this hook, so it can't loop.
input=$(cat)
[ "$(jq -r '.stop_hook_active' <<<"$input")" = "true" ] && exit 0
cd "$CLAUDE_PROJECT_DIR" || exit 0

# Extensions the binary embeds: a broken embedded template fails only at go test.
embedded='sql|html|css|js'
changed=$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | grep -E "\.(go|$embedded)\$|(^|/)go\.(mod|sum)\$")
[ -n "$changed" ] || exit 0

out=$(go build -o /dev/null ./... 2>&1 && go vet ./... 2>&1 && go test ./... 2>&1)
[ $? -eq 0 ] && exit 0

jq -n --arg r "Stop gate failed (go build + vet + test). Fix these before finishing, or tell the user why you can't:
$(printf '%s' "$out" | tail -n 40)" '{decision: "block", reason: $r}'
