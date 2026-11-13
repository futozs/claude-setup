#!/usr/bin/env bash
# Copy the live ~/.claude/settings.json back into the repo (after /model, /plugin install, etc.)
# and show what changed. Commit afterwards if the diff is what you want.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIVE="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
jq -S . "$REPO/settings.json" >/tmp/claude-settings-repo.json
jq -S . "$LIVE" >/tmp/claude-settings-live.json
if diff -u /tmp/claude-settings-repo.json /tmp/claude-settings-live.json; then
  echo "settings.json already in sync"
else
  cp "$LIVE" "$REPO/settings.json"
  echo "Copied live settings into the repo. Review with: git -C \"$REPO\" diff settings.json"
fi
