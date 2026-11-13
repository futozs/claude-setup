#!/usr/bin/env bash
# Notification hook: macOS banner when Claude needs input (permission prompt, idle wait).
# Only useful in the terminal CLI; the desktop app has its own notifications.
[ "$(uname)" = "Darwin" ] || exit 0
[ -n "$CLAUDE_CODE_ENTRYPOINT" ] && [ "$CLAUDE_CODE_ENTRYPOINT" != "cli" ] && exit 0
msg="$(jq -r '.message // "Claude Code needs your attention"' 2>/dev/null | tr '"' "'")"
osascript -e "display notification \"${msg:0:180}\" with title \"Claude Code\" sound name \"Glass\"" >/dev/null 2>&1
exit 0
