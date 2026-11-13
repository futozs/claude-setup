#!/usr/bin/env bash
# Install this Claude Code setup into ~/.claude.
#   ./install.sh            full install (links, settings, skills, plugins, language servers)
#   ./install.sh --links    only (re)create symlinks + settings, skip network steps
# Safe to re-run. Anything it replaces is moved to ~/claude-backups/<timestamp>/ first.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/claude-backups/$STAMP"
LINKS_ONLY=0; [ "${1:-}" = "--links" ] && LINKS_ONLY=1

say() { printf '\033[1m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!!\033[0m %s\n' "$*"; }

need() { command -v "$1" >/dev/null 2>&1 || { warn "missing dependency: $1"; return 1; }; }
need git; need jq || { echo "Install jq first: brew install jq"; exit 1; }

mkdir -p "$CLAUDE_DIR" "$CLAUDE_DIR/skills"

backup() { # move an existing non-symlink path out of the way
  local p="$1"
  if [ -e "$p" ] && [ ! -L "$p" ]; then
    mkdir -p "$BACKUP"
    mv "$p" "$BACKUP/"
    warn "backed up $(basename "$p") -> $BACKUP/"
  elif [ -L "$p" ]; then
    rm "$p"
  fi
}

link() { # link <repo-relative> <target>
  backup "$2"
  ln -s "$REPO/$1" "$2"
  echo "   linked $2"
}

say "Linking config from $REPO"
link CLAUDE.md "$CLAUDE_DIR/CLAUDE.md"
link statusline.sh "$CLAUDE_DIR/statusline.sh"
link hooks "$CLAUDE_DIR/hooks"
link rules "$CLAUDE_DIR/rules"
link agents "$CLAUDE_DIR/agents"
for s in "$REPO"/skills/*/; do
  name="$(basename "$s")"
  link "skills/$name" "$CLAUDE_DIR/skills/$name"
done

say "Writing settings.json"
if [ -f "$CLAUDE_DIR/settings.json" ] && ! cmp -s "$REPO/settings.json" "$CLAUDE_DIR/settings.json"; then
  mkdir -p "$BACKUP"; cp "$CLAUDE_DIR/settings.json" "$BACKUP/settings.json"
  warn "previous settings.json saved to $BACKUP/"
fi
cp "$REPO/settings.json" "$CLAUDE_DIR/settings.json"

[ "$LINKS_ONLY" = 1 ] && { say "Done (links only)."; exit 0; }

say "Installing standalone skills (git)"
clone_skill() { # clone_skill <repo> <subdir-or-.> <name>
  local repo="$1" sub="$2" name="$3" tmp
  tmp="$(mktemp -d)"
  if git clone -q --depth 1 "https://github.com/$repo.git" "$tmp/r"; then
    backup "$CLAUDE_DIR/skills/$name"
    cp -R "$tmp/r/$sub" "$CLAUDE_DIR/skills/$name"
    rm -rf "$CLAUDE_DIR/skills/$name/.git"
    echo "   $name <- $repo/$sub"
  else
    warn "could not clone $repo"
  fi
  rm -rf "$tmp"
}
clone_skill hardikpandya/stop-slop . stop-slop
clone_skill emilkowalski/skills skills/emil-design-eng emil-design-eng
clone_skill emilkowalski/skills skills/review-animations review-animations

if command -v claude >/dev/null 2>&1; then
  say "Installing plugins"
  for mp in anthropics/claude-plugins-official vercel/vercel-plugin pbakaus/impeccable Nutlope/hallmark AgriciDaniel/claude-seo cloudflare/skills; do
    claude plugin marketplace add "$mp" >/dev/null 2>&1 || true
  done
  claude plugin marketplace update >/dev/null 2>&1 || true
  jq -r '.enabledPlugins | to_entries[] | select(.value == true) | .key' "$REPO/settings.json" | while read -r p; do
    if claude plugin install "$p" --scope user >/dev/null 2>&1; then echo "   $p"; else warn "plugin install failed: $p"; fi
  done
else
  warn "claude CLI not found; plugins will install on first launch from settings.json"
fi

say "Language servers for the LSP plugins"
if ! command -v typescript-language-server >/dev/null 2>&1 || ! command -v pyright-langserver >/dev/null 2>&1; then
  if command -v bun >/dev/null 2>&1; then bun add -g typescript-language-server typescript pyright >/dev/null 2>&1 || warn "bun global install failed"
  elif command -v npm >/dev/null 2>&1; then npm i -g typescript-language-server typescript pyright >/dev/null 2>&1 || warn "npm global install failed"
  fi
fi
command -v rust-analyzer >/dev/null 2>&1 || warn "rust-analyzer missing (rustup component add rust-analyzer)"
command -v sourcekit-lsp >/dev/null 2>&1 || xcrun --find sourcekit-lsp >/dev/null 2>&1 || warn "sourcekit-lsp missing (install Xcode)"

say "Done. Start a new Claude Code session and run /context to check the baseline."
