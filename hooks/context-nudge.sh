#!/bin/bash
# UserPromptSubmit: once per session, when the transcript shows context over
# 150k tokens, tell Claude to offer a handoff at the next natural break.
# Hooks don't get live context size, so read the latest assistant usage from
# the transcript. It may lag by a turn, which is fine for a nudge.

THRESHOLD=${CLAUDE_CONTEXT_NUDGE_TOKENS:-150000}
input=$(cat)
session=$(jq -r '.session_id // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")
transcript=${transcript/#\~/$HOME}
[ -n "$session" ] && [ -f "$transcript" ] || exit 0

marker_dir="$HOME/.claude/logs/context-nudge"
[ -e "$marker_dir/$session" ] && exit 0

tokens=$(tail -n 200 "$transcript" | jq -r '
  select(.type == "assistant" and .message.usage != null)
  | .message.usage
  | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)
' 2>/dev/null | tail -n 1)
[ -n "$tokens" ] && [ "$tokens" -gt "$THRESHOLD" ] || exit 0

mkdir -p "$marker_dir" && touch "$marker_dir/$session"
jq -n --arg k "$((tokens / 1000))" '{hookSpecificOutput: {
  hookEventName: "UserPromptSubmit",
  additionalContext: "Context is over 150k tokens (\($k)k). Finish the current step, then at the next natural break offer the user a /handoff."
}}'
