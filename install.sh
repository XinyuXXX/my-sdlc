#!/usr/bin/env bash
# Install my-sdlc skills for a given host and scope, optionally with the
# session-start hook where the host supports one.
# Usage: install.sh <kimi|claude|copilot|opencode|all> <user|project> [project-dir] [--with-hook]
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$PLUGIN_ROOT/skills"

usage() {
  cat >&2 <<'EOF'
Usage: install.sh <host> <scope> [project-dir] [--with-hook]

  host          kimi | claude | copilot | opencode | all
  scope         user | project
  project-dir   required when scope=project (defaults to current directory)
  --with-hook   also install the session-start hook (claude and copilot only)
EOF
  exit 2
}

[ $# -ge 2 ] || usage
HOST="$1"; SCOPE="$2"; shift 2
case "$SCOPE" in user|project) ;; *) echo "unknown scope: $SCOPE" >&2; usage ;; esac
WITH_HOOK=0
PROJECT="$PWD"
for arg in "$@"; do
  case "$arg" in
    --with-hook) WITH_HOOK=1 ;;
    *) PROJECT="$arg" ;;
  esac
done

skills_target() {
  case "$1" in
    kimi)     [ "$SCOPE" = user ] && echo "$HOME/.kimi/skills"                || echo "$PROJECT/.kimi/skills" ;;
    claude)   [ "$SCOPE" = user ] && echo "$HOME/.claude/skills"              || echo "$PROJECT/.claude/skills" ;;
    copilot)  [ "$SCOPE" = user ] && echo "$HOME/.copilot/skills"             || echo "$PROJECT/.github/skills" ;;
    opencode) [ "$SCOPE" = user ] && echo "$HOME/.config/opencode/skills"     || echo "$PROJECT/.opencode/skills" ;;
    *) echo "unknown host: $1" >&2; exit 2 ;;
  esac
}

link_skills() {
  local target="$1"
  mkdir -p "$target"
  local n=0
  for d in "$SKILLS_DIR"/*/; do
    ln -sfn "$d" "$target/$(basename "$d")"
    n=$((n + 1))
  done
  echo "linked $n skills -> $target"
}

install_hook() {
  local host="$1"
  case "$host" in
    claude)
      local settings
      [ "$SCOPE" = user ] && settings="$HOME/.claude/settings.json" || settings="$PROJECT/.claude/settings.json"
      mkdir -p "$(dirname "$settings")"
      [ -f "$settings" ] && cp "$settings" "$settings.bak-my-sdlc"
      if ! SETTINGS="$settings" PLUGIN_ROOT="$PLUGIN_ROOT" node -e '
        const fs = require("fs");
        const p = process.env.SETTINGS;
        const s = fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, "utf8")) : {};
        s.hooks = s.hooks || {};
        s.hooks.SessionStart = [{
          matcher: "startup|clear|compact",
          hooks: [{ type: "command", command: `CLAUDE_PLUGIN_ROOT=1 bash "${process.env.PLUGIN_ROOT}/hooks/session-start"` }],
        }];
        fs.writeFileSync(p, JSON.stringify(s, null, 2) + "\n");
      '; then
        echo "failed to update $settings (invalid JSON?)" >&2
        exit 1
      fi
      echo "hook registered in $settings (backup: $settings.bak-my-sdlc)"
      ;;
    copilot)
      local hooks_dir
      [ "$SCOPE" = user ] && hooks_dir="$HOME/.copilot/hooks" || hooks_dir="$PROJECT/.github/hooks"
      mkdir -p "$hooks_dir"
      cat > "$hooks_dir/my-sdlc.json" <<EOF
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      { "type": "command", "bash": "bash \\"$PLUGIN_ROOT/hooks/session-start\\"", "timeoutSec": 10 }
    ]
  }
}
EOF
      echo "hook written to $hooks_dir/my-sdlc.json"
      ;;
    *)
      echo "note: $host has no session-start hook support; activate with the poteto-mode skill by name" >&2
      ;;
  esac
}

hosts="$HOST"
[ "$HOST" = all ] && hosts="kimi claude copilot opencode"
for h in $hosts; do
  link_skills "$(skills_target "$h")"
  [ "$WITH_HOOK" = 1 ] && install_hook "$h"
done

echo "done. activate poteto-mode per host: kimi '/skill:poteto-mode', copilot/opencode 'use the poteto-mode skill', claude auto-injects when the hook is installed"
