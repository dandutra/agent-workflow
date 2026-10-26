#!/bin/bash
# PreToolUse on Bash: deny `git push` that targets main or master.
# Stands in for branch protection, which private repos on GitHub Free lack.
# Catches an explicit main/master refspec, and a bare `git push` (or one
# naming only the remote) while the current branch is main/master.

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")

deny() {
  jq -n --arg r "$1" '{hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $r
  }}'
  exit 0
}

# Each `git push` subcommand, split on shell separators.
printf '%s\n' "$cmd" | tr ';&|' '\n\n\n' | grep -E '(^|[[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push\b' |
while IFS= read -r part; do
  args=$(printf '%s' "$part" | sed -E 's/.*[[:space:]]push([[:space:]]|$)//')
  if printf '%s' "$args" | grep -qE '(^|[[:space:]:+])(refs/heads/)?(main|master)([[:space:]]|$)'; then
    echo "explicit"
    break
  fi
  # Positional args, ignoring flags. 0 or 1 positional, or a HEAD refspec,
  # means "push the current branch".
  positional=$(printf '%s' "$args" | tr ' ' '\n' | grep -vE '^-|^$' | wc -l | tr -d ' ')
  if { [ "$positional" -le 1 ] || printf '%s' "$args" | grep -qE '(^|[[:space:]])\+?HEAD([[:space:]]|$)'; } &&
    ! printf '%s' "$args" | grep -qE -- '--(all|tags|mirror|delete)\b'; then
    branch=$(git -C "${cwd:-.}" symbolic-ref --short -q HEAD 2>/dev/null)
    case "$branch" in main | master) echo "current:$branch"; break ;; esac
  fi
done | {
  read -r verdict || exit 0
  case "$verdict" in
    explicit) deny "Pushing to main/master is blocked. Push a feature branch and open a PR." ;;
    current:*) deny "The current branch is ${verdict#current:}; pushing it is blocked. Create a feature branch and push that." ;;
  esac
}
exit 0
