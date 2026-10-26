#!/bin/bash
# Stop (async): offer KB candidates from Claude's final message to the
# project's docs/kb/.inbox.md. Runs only where docs/kb/index.md exists and
# JEV_API_URL + JEV_API_KEY are set; otherwise exits quietly.
# It never writes concepts and never touches log.md (reserved by OKF).
# Promotion from the inbox is manual, via /handoff or /retro.

[ -n "$JEV_API_URL" ] && [ -n "$JEV_API_KEY" ] || exit 0

input=$(cat)
cwd=$(jq -r '.cwd // empty' <<<"$input")
root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$cwd")
index="$root/docs/kb/index.md"
inbox="$root/docs/kb/.inbox.md"
[ -f "$index" ] || exit 0
# The inbox holds raw session text; never write it where git would pick it up.
git -C "$root" check-ignore -q "$inbox" 2>/dev/null || exit 0

msg=$(jq -r '.last_assistant_message // empty' <<<"$input")
[ "${#msg}" -ge 200 ] || exit 0
# Trim: drop fenced code, keep the first 4000 characters.
msg=$(printf '%s\n' "$msg" | awk '/^[[:space:]]*```/{f=!f; next} !f' | head -c 4000)

# Local secret scan. Any hit skips the message entirely; nothing leaves the machine.
if printf '%s' "$msg" | grep -qE \
  'AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36,}|sk-[A-Za-z0-9_-]{20,}|xox[abpr]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.|(password|passwd|secret|api[_-]?key|token)[[:space:]]*[:=][[:space:]]*[^[:space:]]{6,}'; then
  exit 0
fi

# Types from the root index's Types table: first column of rows after "## Types".
types=$(awk '/^## Types/{t=1; next} /^## /{t=0} t && /^\|/' "$index" |
  awk -F'|' 'NR>2 {gsub(/[[:space:]`]/, "", $2); if ($2 != "") print $2}' | jq -R . | jq -s -c .)
[ "$types" != "[]" ] || exit 0

# Jev call: the request and response shapes below are placeholders until
# TypeSafe API access arrives. Check them against Jev's docs before relying
# on this hook; only this function should need to change.
ask_jev() { # text, types-json -> {"score": 0..1, "type": "<one of types>"}
  curl -sS --max-time 30 "$JEV_API_URL" \
    -H "Authorization: Bearer $JEV_API_KEY" -H 'Content-Type: application/json' \
    -d "$(jq -n --arg text "$1" --argjson types "$2" '{
      input: $text,
      tasks: [
        {kind: "noul", question: "Does this contain a decision, gotcha or rule worth keeping in the project knowledge base?"},
        {kind: "choice", question: "Which knowledge type is it?", options: $types}
      ]
    }')" | jq -c '{score: .results[0].score, type: .results[1].choice}'
}

result=$(ask_jev "$msg" "$types" 2>/dev/null) || exit 0
score=$(jq -r '.score // 0' <<<"$result")
type=$(jq -r '.type // "unknown"' <<<"$result")
awk -v s="$score" 'BEGIN{ exit !(s >= 0.7) }' || exit 0

excerpt=$(printf '%s' "$msg" | head -c 600 | sed 's/^/> /')
{
  printf '\n## %s · %s · score %s\n\n' "$(date +%Y-%m-%d)" "$type" "$score"
  printf '%s\n' "$excerpt"
} >>"$inbox"
exit 0
