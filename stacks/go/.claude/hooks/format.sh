#!/bin/bash
# PostToolUse on Edit|Write: run gofmt on the Go file Claude just changed.
# Formatting only; build, vet and tests wait for the Stop gate.
file=$(jq -r '.tool_input.file_path // empty')
[ -f "$file" ] || exit 0
case "$file" in
  *.go) gofmt -w "$file" ;;
esac
exit 0
