#!/usr/bin/env bash
# Mechanical hygiene checks for the my-sdlc repo. Run before committing.
# Usage: scripts/self-check.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
problems=0
note() { echo "FAIL: $1"; problems=$((problems + 1)); }

# 1. Every skill has SKILL.md with name and description in frontmatter.
for d in skills/*/; do
  f="$d/SKILL.md"
  [ -f "$f" ] || { note "$d has no SKILL.md"; continue; }
  head -20 "$f" | grep -q "^name:" || note "$f lacks name"
  head -20 "$f" | grep -q "^description:" || note "$f lacks description"
done

# 2. Scripts parse.
node --check skills/poteto-mode/scripts/check-plan.mjs 2>/dev/null || note "check-plan.mjs fails node --check"
for s in skills/execution-ledger/scripts/log.sh skills/poteto-mode/scripts/worktree-audit.sh hooks/session-start install.sh; do
  bash -n "$s" 2>/dev/null || note "$s fails bash -n"
done

# 3. Manifests are valid JSON.
for j in .kimi-plugin/plugin.json .claude-plugin/plugin.json hooks/hooks.json; do
  node -e "JSON.parse(require('fs').readFileSync('$j','utf8'))" 2>/dev/null || note "$j is not valid JSON"
done

# 4. Linked references/, scripts/, playbooks/ files exist somewhere under skills/.
while read -r ref; do
  found=0
  for d in skills/*/; do
    [ -e "$d$ref" ] && found=1 && break
  done
  [ $found -eq 0 ] && note "broken file link: $ref"
done < <(grep -rhoE '\(((references|scripts|playbooks)/[a-z0-9./-]+)\)' skills/ --include="*.md" | tr -d '()' | sort -u)

# 5. Bold skill-name references resolve to real skill directories.
while read -r s; do
  [ -d "skills/$s" ] || note "no such skill: $s"
done < <(grep -rhoE '\*\*[a-z][a-z0-9-]+\*\* skill' skills/ --include="*.md" | sed 's/\*\*//g;s/ skill//' | sort -u)

# 6. Referenced playbook files exist.
while read -r p; do
  [ -f "skills/poteto-mode/$p" ] || note "missing playbook: $p"
done < <(grep -rhoE 'playbooks/[a-z-]+\.md' skills/ --include="*.md" | sort -u)

if [ $problems -eq 0 ]; then
  echo "self-check: clean ($(ls -d skills/*/ | wc -l | tr -d ' ') skills)"
else
  echo "self-check: $problems problem(s)" >&2
  exit 1
fi
