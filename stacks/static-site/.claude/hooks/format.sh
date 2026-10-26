#!/bin/bash
# PostToolUse on Edit|Write: run prettier on the file Claude just changed.
# Formatting only; lint and tests wait for the Stop gate.
file=$(jq -r '.tool_input.file_path // empty')
[ -f "$file" ] || exit 0
case "$file" in
  *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs | *.json | *.css | *.scss | *.html | *.md | *.yml | *.yaml)
    cd "$CLAUDE_PROJECT_DIR" && npx --no-install prettier --write --log-level warn "$file" ;;
esac
exit 0
