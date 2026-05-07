#!/usr/bin/env bash
# RPI Toolkit installer.
#
# Drops the canonical RPI methodology + shell helpers under ~/.claude/
# and adds one source line to your shell rc so `rpi-init` and `rpi-refresh`
# are available in new shells.
#
# Idempotent — safe to re-run to upgrade.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"

SRC_RPI="$SCRIPT_DIR/RPI.md"
SRC_SH="$SCRIPT_DIR/rpi.sh"
DST_RPI="$CLAUDE_DIR/RPI.md"
DST_SH="$CLAUDE_DIR/rpi.sh"
DST_CMD="$COMMANDS_DIR/rpi.md"

[ -f "$SRC_RPI" ] || { echo "install.sh: missing $SRC_RPI" >&2; exit 1; }
[ -f "$SRC_SH" ]  || { echo "install.sh: missing $SRC_SH"  >&2; exit 1; }

mkdir -p "$CLAUDE_DIR" "$COMMANDS_DIR"

copy_if_changed() {
  local src="$1" dst="$2"
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    echo "unchanged: $dst"
  else
    cp "$src" "$dst"
    echo "installed: $dst"
  fi
}

# 1. Canonical methodology
copy_if_changed "$SRC_RPI" "$DST_RPI"

# 2. Shell helpers (rpi-init / rpi-refresh)
copy_if_changed "$SRC_SH" "$DST_SH"

# 3. User-level Claude Code slash command (harmless if Claude Code isn't installed)
TMP_CMD="$(mktemp)"
cat > "$TMP_CMD" <<'EOF'
---
description: Apply the RPI (Research -> Plan -> Implement) methodology to a problem statement
---

Read `~/.claude/RPI.md` and follow that methodology strictly for the request below. Determine the mode from the input (default to `full-cycle` if unspecified) and begin with the Preflight phase — do not skip ahead.

Request:

$ARGUMENTS
EOF
copy_if_changed "$TMP_CMD" "$DST_CMD"
rm -f "$TMP_CMD"

# 4. Source line in shell rc
SOURCE_LINE='source ~/.claude/rpi.sh'

case "${SHELL:-}" in
  *zsh*)  RC="$HOME/.zshrc" ;;
  *bash*) if [ -f "$HOME/.bashrc" ]; then RC="$HOME/.bashrc"; else RC="$HOME/.bash_profile"; fi ;;
  *)      RC="$HOME/.zshrc" ;;
esac

[ -f "$RC" ] || touch "$RC"

if grep -qF "$SOURCE_LINE" "$RC"; then
  echo "unchanged: $RC (already sources rpi.sh)"
else
  printf '\n# RPI toolkit\n%s\n' "$SOURCE_LINE" >> "$RC"
  echo "appended:  $RC"
fi

cat <<EOF

RPI toolkit installed.

Next steps:
  1. Open a new terminal, or run:  source $RC
  2. cd into any git repo and run: rpi-init
  3. In an interactive Copilot CLI session (\`copilot -i\`), invoke:
       /rpi Problem: <one-sentence description>. Mode: <mode>

See README.md for the full guide.
EOF
