#!/usr/bin/env bash
# Installs the Claude starter kit into a project (macOS, Linux, Git Bash).
#
#   ./install.sh [target-dir] [--update]
#
# Existing files are never overwritten, except kit-managed files (agents, skills,
# hooks) with --update. An existing CLAUDE.md or .claude/settings.json is kept; the
# kit's version is written next to it for /kit-setup to merge.

set -euo pipefail

KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$KIT_ROOT/template"
TARGET="."
UPDATE=0

for arg in "$@"; do
  case "$arg" in
    --update) UPDATE=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) TARGET="$arg" ;;
  esac
done

TARGET="$(cd "$TARGET" && pwd)"
[ "$TARGET" = "$KIT_ROOT" ] && { echo "Target is the kit itself. Pass a project folder." >&2; exit 1; }

sidecar_for() {
  case "$1" in
    CLAUDE.md) echo ".claude/CLAUDE.kit-template.md" ;;
    .claude/settings.json) echo ".claude/settings.kit.json" ;;
    *) echo "" ;;
  esac
}

new=0; updated=0; skipped=0; merge=0
first_install=1
[ -f "$TARGET/.claude/kit-version" ] && first_install=0

while IFS= read -r -d '' src; do
  rel="${src#"$TEMPLATE"/}"
  dest="$TARGET/$rel"
  if [ -e "$dest" ]; then
    side="$(sidecar_for "$rel")"
    if [ -n "$side" ] && [ "$first_install" -eq 0 ]; then
      echo "  [keep]    $rel (yours; compare with template/$rel for new kit changes)"
      skipped=$((skipped + 1))
    elif [ -n "$side" ]; then
      mkdir -p "$(dirname "$TARGET/$side")"
      cp "$src" "$TARGET/$side"
      echo "  [merge]   $rel exists -> kit version saved as $side"
      merge=$((merge + 1))
    elif [ "$UPDATE" -eq 1 ]; then
      cp "$src" "$dest"
      echo "  [update]  $rel"
      updated=$((updated + 1))
    else
      echo "  [skip]    $rel (exists; use --update to refresh kit files)"
      skipped=$((skipped + 1))
    fi
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "  [new]     $rel"
    new=$((new + 1))
  fi
done < <(find "$TEMPLATE" -type f -print0)

version="$(tr -d '[:space:]' < "$KIT_ROOT/VERSION")"
printf '%s\n' "$version" > "$TARGET/.claude/kit-version"

gitignore="$TARGET/.gitignore"
touch "$gitignore"
added=()
for entry in CLAUDE.local.md .claude/settings.local.json; do
  grep -qxF "$entry" "$gitignore" || added+=("$entry")
done
if [ "${#added[@]}" -gt 0 ]; then
  { echo ""; echo "# Claude Code (personal, not shared)"; printf '%s\n' "${added[@]}"; } >> "$gitignore"
  echo "  [gitignore] added: ${added[*]}"
fi

command -v node >/dev/null 2>&1 || echo "WARNING: Node.js not found. The command guard hook needs Node 18+ on PATH." >&2

echo ""
echo "Kit $version installed into $TARGET"
echo "  new: $new  updated: $updated  skipped: $skipped  to merge: $merge"
echo ""
echo "Next: open Claude Code in that folder and run /kit-setup"
