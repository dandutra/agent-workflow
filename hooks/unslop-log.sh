#!/bin/bash
# Stop: log unslop tells in Claude's final message. Never blocks; it only
# measures. Covers the regex-checkable rules from skills/unslop: 3, 7, 8, 9.
# Strips fenced code blocks and inline code first so code doesn't count.

LOG="$HOME/.claude/logs/unslop-hits.jsonl"
input=$(cat)
msg=$(jq -r '.last_assistant_message // empty' <<<"$input")
[ -n "$msg" ] || exit 0

prose=$(printf '%s\n' "$msg" | awk '/^[[:space:]]*```/{f=!f; next} !f' | sed -E 's/`[^`]*`//g')

hits() { # rule, extended regex
  printf '%s\n' "$prose" | grep -oiE "$2" | tr '[:upper:]' '[:lower:]' \
    | jq -R --arg r "$1" '{rule: ($r | tonumber), match: .}'
}

found=$(
  {
    hits 3 ', (highlighting|ensuring|reflecting|showcasing|fostering|underscoring|emphasizing|demonstrating)\b'
    hits 7 '\b(additionally|crucial|delve[sd]?|delving|enduring|enhance[sd]?|enhancing|fostering|garner(s|ed)?|interplay|intricate|pivotal|showcase[sd]?|showcasing|tapestry|testament|underscore[sd]?|underscoring|vibrant)\b'
    hits 8 '\b(serves as|serve as|stands as|boasts)\b'
    hits 9 "\bnot (just|only|merely) [^.;:!?]{1,60}, but\b"
  } | jq -s -c '.'
)
[ "$found" = "[]" ] || [ -z "$found" ] && exit 0

mkdir -p "$(dirname "$LOG")"
jq -n -c \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson input "$input" \
  --argjson hits "$found" \
  --arg words "$(printf '%s' "$prose" | wc -w | tr -d ' ')" \
  '{ts: $ts, session: $input.session_id, cwd: $input.cwd, words: ($words | tonumber), hits: $hits}' >>"$LOG"
exit 0
