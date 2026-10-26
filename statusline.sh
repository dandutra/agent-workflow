#!/bin/bash
# Claude Code status line: model · context window usage · 5-hour rate-limit window.
# Reads the status line JSON payload on stdin. Field names per Claude Code's
# status line spec: .model.display_name, .context_window.*, .rate_limits.five_hour.*
# Everything is optional: context percentages are null until the first API
# response, and rate_limits is absent entirely for API-key/Bedrock/Vertex sessions.

input=$(cat)

# One jq pass, one field per line, empty string where absent or null.
{
  read -r model
  read -r tokens
  read -r size
  read -r ctxpct
  read -r fivepct
  read -r resets
} <<EOF
$(printf '%s' "$input" | jq -r '
  (.model.display_name // "") ,
  (.context_window.total_input_tokens // "") ,
  (.context_window.context_window_size // "") ,
  (.context_window.used_percentage // "") ,
  (.rate_limits.five_hour.used_percentage // "") ,
  (.rate_limits.five_hour.resets_at // "")
' 2>/dev/null)
EOF

# 48432 -> 48.4k, 200000 -> 200k, 940 -> 940
hum() {
  awk -v n="$1" 'BEGIN{
    if (n >= 1000) { v = n / 1000; printf (v == int(v) ? "%dk" : "%.1fk"), v }
    else printf "%d", n
  }'
}

parts=()
[ -n "$model" ] && parts+=("$model")

if [ -n "$tokens" ]; then
  seg="ctx $(hum "$tokens")"
  [ -n "$size" ] && seg="$seg/$(hum "$size")"
  [ -n "$ctxpct" ] && seg="$seg ($(printf '%.0f' "$ctxpct")%)"
  # Red past 150k: time to offer a handoff (hooks/context-nudge.sh does the same).
  [ "$tokens" -ge 150000 ] 2>/dev/null && seg=$(printf '\033[31m%s\033[0m' "$seg")
  parts+=("$seg")
fi

if [ -n "$fivepct" ]; then
  seg="5h $(printf '%.0f' "$fivepct")%"
  if [ -n "$resets" ]; then
    clock=$(date -r "$resets" +%H:%M 2>/dev/null || date -d "@$resets" +%H:%M 2>/dev/null)
    [ -n "$clock" ] && seg="$seg ↻$clock"
  fi
  # Warn as the session window fills: yellow at 70%, red at 90%.
  color=$(awk -v p="$fivepct" 'BEGIN{ print (p >= 90 ? "31" : (p >= 70 ? "33" : "")) }')
  [ -n "$color" ] && seg=$(printf '\033[%sm%s\033[0m' "$color" "$seg")
  parts+=("$seg")
fi

out=""
for p in "${parts[@]}"; do
  [ -n "$out" ] && out="$out · "
  out="$out$p"
done
printf '%s' "$out"
