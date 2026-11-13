#!/usr/bin/env bash
# Status line: model · effort-free context % · dir · git branch(+dirty) · session cost
# Pure bash + jq, runs in a few ms.
in="$(cat)"
model="$(jq -r '.model.display_name // .model.id // "?"' <<<"$in")"
dir="$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$in")"
cost="$(jq -r '.cost.total_cost_usd // empty' <<<"$in")"
used="$(jq -r '.context_window.used_percentage // empty' <<<"$in")"

dim=$'\e[2m'; rst=$'\e[0m'; ylw=$'\e[33m'; red=$'\e[31m'; grn=$'\e[32m'
out="${model}"

if [ -n "$used" ]; then
  pct="${used%.*}"
  col="$grn"; [ "$pct" -ge 50 ] 2>/dev/null && col="$ylw"; [ "$pct" -ge 80 ] 2>/dev/null && col="$red"
  out="$out ${dim}·${rst} ${col}ctx ${pct}%${rst}"
fi

[ -n "$dir" ] && out="$out ${dim}·${rst} ${dir/#$HOME/~}"

if [ -n "$dir" ] && branch="$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null)"; then
  dirty=""; [ -n "$(git -C "$dir" status --porcelain 2>/dev/null | head -n1)" ] && dirty="*"
  out="$out ${dim}·${rst} ${branch}${dirty}"
fi

[ -n "$cost" ] && out="$out ${dim}· \$$(printf '%.2f' "$cost")${rst}"
printf '%s' "$out"
