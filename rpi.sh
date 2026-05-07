# RPI tooling — canonical methodology lives in ~/.claude/RPI.md.
# Sourced from ~/.zshrc.
#
# rpi-init: drop /rpi support files into the current git repo so that both
# Claude Code and Copilot CLI can invoke the RPI framework. Idempotent;
# existing files are left untouched.

rpi-init() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "rpi-init: not inside a git repository. cd into a repo and retry." >&2
    return 1
  }

  if [ ! -f "$HOME/.claude/RPI.md" ]; then
    echo "rpi-init: canonical methodology missing at ~/.claude/RPI.md" >&2
    return 1
  fi

  # 1. RPI.md at repo root (copy of canonical so the repo is self-contained)
  if [ -f "$root/RPI.md" ]; then
    echo "skip:    $root/RPI.md (exists)"
  else
    cp "$HOME/.claude/RPI.md" "$root/RPI.md"
    echo "created: $root/RPI.md"
  fi

  # 2. Claude Code project-level slash command
  mkdir -p "$root/.claude/commands"
  if [ -f "$root/.claude/commands/rpi.md" ]; then
    echo "skip:    $root/.claude/commands/rpi.md (exists)"
  else
    cat > "$root/.claude/commands/rpi.md" <<'EOF'
---
description: Apply the RPI (Research -> Plan -> Implement) methodology to a problem statement
---

Read `RPI.md` from the repo root, then execute the RPI framework using the
following inputs:

$ARGUMENTS

If no Mode is specified, infer the most appropriate mode from the problem
description before beginning the Research phase.
EOF
    echo "created: $root/.claude/commands/rpi.md"
  fi

  # 3. Copilot CLI prompt file (powers /rpi inside `copilot -i`)
  mkdir -p "$root/.github/prompts"
  if [ -f "$root/.github/prompts/rpi.md" ]; then
    echo "skip:    $root/.github/prompts/rpi.md (exists)"
  else
    cat > "$root/.github/prompts/rpi.md" <<'EOF'
Read RPI.md from the repo root, then execute the RPI framework using the
following inputs:

$ARGUMENTS

If no Mode is specified, infer the most appropriate mode from the problem
description before beginning the Research phase.
EOF
    echo "created: $root/.github/prompts/rpi.md"
  fi

  # 4. Reference block in .github/copilot-instructions.md
  local instructions="$root/.github/copilot-instructions.md"
  local marker="<!-- rpi-init: managed section -->"
  if [ -f "$instructions" ] && grep -qF "$marker" "$instructions"; then
    echo "skip:    $instructions (already references /rpi)"
  else
    mkdir -p "$root/.github"
    cat >> "$instructions" <<EOF

$marker
## RPI Framework

This repo includes the RPI (Research -> Plan -> Implement) methodology in \`RPI.md\`.

Invoke via \`/rpi\` in either agent:
- Claude Code: \`/rpi Problem: [statement]. Mode: [mode]\`
- Copilot CLI:  \`/rpi Problem: [statement]. Mode: [mode]\`

Modes: investigate-only | full-cycle | audit | test | refactor.
Phases are strictly ordered (Research -> Plan -> Implement). See \`RPI.md\` for full rules.
EOF
    echo "append:  $instructions"
  fi

  echo "rpi-init: done."
}

# rpi-refresh: re-copy ~/.claude/RPI.md over the current repo's RPI.md so
# methodology updates propagate. Leaves slash-command stubs alone (they
# reference RPI.md by path and don't change). Run from any repo that was
# previously initialized with rpi-init.
rpi-refresh() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "rpi-refresh: not inside a git repository. cd into a repo and retry." >&2
    return 1
  }

  if [ ! -f "$HOME/.claude/RPI.md" ]; then
    echo "rpi-refresh: canonical methodology missing at ~/.claude/RPI.md" >&2
    return 1
  fi

  if [ ! -f "$root/RPI.md" ]; then
    echo "rpi-refresh: $root/RPI.md does not exist; run rpi-init instead." >&2
    return 1
  fi

  if cmp -s "$HOME/.claude/RPI.md" "$root/RPI.md"; then
    echo "rpi-refresh: $root/RPI.md already matches canonical."
    return 0
  fi

  cp "$HOME/.claude/RPI.md" "$root/RPI.md"
  echo "refreshed: $root/RPI.md"
}
