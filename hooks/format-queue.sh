#!/usr/bin/env bash
# Two-phase formatter.
#   PostToolUse(Edit|Write|MultiEdit): `format-queue.sh add`   -> remember the edited path (~3 ms)
#   Stop:                              `format-queue.sh flush` -> format the queued files once
# Formatting at Stop instead of after every edit avoids "file modified since read" errors
# on Claude's next Edit, and costs one formatter run per turn instead of one per edit.
# Uses the project's own formatter only (biome or prettier from node_modules). Never installs anything.
# Disable per session: CLAUDE_FORMAT=0
[ "${CLAUDE_FORMAT:-1}" = "0" ] && exit 0
mode="${1:-add}"
input="$(cat)"
sid="$(printf '%s' "$input" | jq -r '.session_id // "default"' 2>/dev/null)"
queue="${TMPDIR:-/tmp}/claude-format-${sid}.txt"

if [ "$mode" = add ]; then
  f="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
  case "$f" in
    *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.md|*.mdx|*.html|*.vue|*.svelte|*.astro|*.yml|*.yaml) printf '%s\n' "$f" >>"$queue" ;;
  esac
  exit 0
fi

# flush
[ -s "$queue" ] || exit 0
files="$(sort -u "$queue")"
rm -f "$queue"

# Group files by project root (nearest package.json) and run that project's formatter.
printf '%s\n' "$files" | while IFS= read -r f; do
  [ -f "$f" ] || continue
  d="$(dirname "$f")"
  while [ "$d" != "/" ] && [ ! -f "$d/package.json" ]; do d="$(dirname "$d")"; done
  [ -f "$d/package.json" ] && printf '%s\t%s\n' "$d" "$f"
done | sort | awk -F'\t' '{a[$1]=a[$1] "\t" $2} END {for (k in a) print k a[k]}' |
while IFS=$'\t' read -r root rest; do
  IFS=$'\t' read -r -a list <<<"$rest"
  if [ -x "$root/node_modules/.bin/biome" ] && ls "$root"/biome.json* >/dev/null 2>&1; then
    (cd "$root" && ./node_modules/.bin/biome format --write "${list[@]}" >/dev/null 2>&1)
  elif [ -x "$root/node_modules/.bin/prettier" ]; then
    (cd "$root" && ./node_modules/.bin/prettier --write --log-level silent --ignore-unknown "${list[@]}" >/dev/null 2>&1)
  fi
done
exit 0
