#!/bin/bash
# Link this repo into ~/.claude and merge settings.fragment.json into
# ~/.claude/settings.json. Safe to re-run. settings.json itself is never
# symlinked: it holds machine-private config (autoMode.environment).
set -euo pipefail

REPO=$(cd "$(dirname "$0")" && pwd)
CLAUDE="$HOME/.claude"
BACKUP="$CLAUDE/backups/agent-workflow-$(date +%Y%m%d-%H%M%S)"
linked=0 backed_up=0

# Link $1 (repo path) at $2. A real file or dir already there is moved to
# $BACKUP, never deleted.
link() {
  local src=$1 dst=$2
  if [ -L "$dst" ]; then
    [ "$(readlink "$dst")" = "$src" ] && return
    rm "$dst"
  elif [ -e "$dst" ]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/"
    backed_up=$((backed_up + 1))
  fi
  ln -s "$src" "$dst"
  linked=$((linked + 1))
}

mkdir -p "$CLAUDE/skills" "$CLAUDE/agents" "$CLAUDE/logs"

# Drop links whose target is gone (skills renamed or removed from the repo).
pruned=0
for l in "$CLAUDE"/skills/* "$CLAUDE"/agents/*; do
  [ -L "$l" ] && [ ! -e "$l" ] && rm "$l" && pruned=$((pruned + 1))
done

link "$REPO/global/CLAUDE.md" "$CLAUDE/CLAUDE.md"
link "$REPO/statusline.sh" "$CLAUDE/statusline.sh"
for d in "$REPO"/skills/*/; do
  d=${d%/}
  link "$d" "$CLAUDE/skills/$(basename "$d")"
done
for f in "$REPO"/agents/*.md; do
  link "$f" "$CLAUDE/agents/$(basename "$f")"
done
chmod +x "$REPO"/hooks/*.sh "$REPO/statusline.sh"

# Settings: fragment wins on its keys; hooks are replaced wholesale.
settings="$CLAUDE/settings.json"
[ -f "$settings" ] || echo '{}' >"$settings"
mkdir -p "$BACKUP"
cp "$settings" "$BACKUP/settings.json"
fragment=$(sed "s|@REPO@|$REPO|g" "$REPO/settings.fragment.json")
jq --argjson frag "$fragment" '
  (. * ($frag | del(.hooks))) + {hooks: $frag.hooks}
  | del(.modelSettings["claude-opus-5"])
  | del(.extraKnownMarketplaces.mattpocock)
' "$settings" >"$settings.tmp"
mv "$settings.tmp" "$settings"

skills=$(ls -d "$REPO"/skills/*/ | wc -l | tr -d ' ')
agents=$(ls "$REPO"/agents/*.md | wc -l | tr -d ' ')
echo "skills: $skills, agents: $agents, links created: $linked, dangling links pruned: $pruned, existing items backed up: $backed_up"
echo "settings merged; previous copy in $BACKUP/settings.json"
[ "$skills" -gt 0 ] && [ "$agents" -gt 0 ]
