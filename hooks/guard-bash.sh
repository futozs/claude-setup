#!/usr/bin/env bash
# PreToolUse(Bash): block a short list of catastrophic or policy-breaking commands.
# Fast path (~5 ms): pure bash + jq, no node. Exit 2 = block, stderr goes back to Claude.
cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

block() { echo "Blocked by guard-bash.sh: $1" >&2; exit 2; }

# Normalize whitespace for matching.
c="$(printf '%s' "$cmd" | tr -s '[:space:]' ' ')"

# Recursive delete of root, home, or the whole config dir.
if printf '%s' "$c" | grep -Eq 'rm +(-[a-zA-Z]*[rR][a-zA-Z]*f?|-[a-zA-Z]*f[a-zA-Z]*[rR]|--recursive)[a-zA-Z -]* +(/|~|\$HOME|/Users/[^/ ]+|~/\.claude|\$HOME/\.claude)/?( |$|\*)'; then
  block "recursive delete of /, home, or ~/.claude."
fi

# Skipping git hooks.
printf '%s' "$c" | grep -Eq 'git (commit|push|merge|rebase)\b.*--no-verify' && block "--no-verify is not allowed; fix the hook failure instead."

# Force push (plain --force; --force-with-lease is allowed, teamflow needs it).
if printf '%s' "$c" | grep -Eq 'git push\b' && printf '%s' "$c" | grep -Eq '(--force( |$)|--force=|(^| )-f( |$)|\+[A-Za-z0-9_./-]+:)' ; then
  block "force push. Use --force-with-lease on your own branch only, and only when asked."
fi

# Direct push to main/master in teamflow repos.
if printf '%s' "$c" | grep -Eq 'git push\b.*\b(main|master)\b' && [ "$(git config --bool --get claude.teamflow 2>/dev/null)" = "true" ]; then
  block "teamflow repo: never push to main directly; push your own branch (the hook merges)."
fi

# Piping remote scripts into a shell.
printf '%s' "$c" | grep -Eq '(curl|wget)[^|]*\| *(sudo +)?(ba|z)?sh\b' && block "piping a downloaded script into a shell. Download, read, then run."

# Destructive disk / permission operations.
printf '%s' "$c" | grep -Eq '(^| )(mkfs|diskutil +(erase|zero|reformat))' && block "disk formatting."
printf '%s' "$c" | grep -Eq 'chmod +-R +777 +(/|~)' && block "recursive chmod 777 on / or home."

exit 0
