# RPI Toolkit

A shareable bundle that adds a `/rpi` slash command to **GitHub Copilot CLI** (and Claude Code, if you have it), backed by a single canonical methodology file. Designed to be copied to a teammate's machine and installed in one step.

---

## What is RPI?

RPI (Research → Plan → Implement) is a four-phase methodology — **Preflight → Research → Plan → Implement** — for working through problems with AI agents. The full ruleset lives in [`RPI.md`](./RPI.md). When you invoke `/rpi`, the agent is told to read that file and follow it strictly.

Modes available:

| Mode | When to use |
|---|---|
| `investigate-only` | Exploration or "how does X work" — no implementation |
| `full-cycle` | Bug, feature, or regression — the default for actionable problems |
| `audit` | Security or quality sweep |
| `test` | Coverage gap |
| `refactor` | Restructure without behavior change |

If you omit `Mode:`, the agent will infer it.

---

## Install

1. Copy this folder to your machine (clone, unzip, scp, whatever).
2. From inside the folder, run:

   ```bash
   ./install.sh
   ```

   If `./install.sh` says "permission denied," use:

   ```bash
   bash install.sh
   ```

3. Open a new terminal (or run `source ~/.zshrc` / `source ~/.bashrc`) so the `rpi-init` and `rpi-refresh` shell functions are loaded.

The installer drops files under `~/.claude/` and adds one `source` line to your shell rc. It's idempotent — re-run it any time to pick up updates.

### What gets installed

| Path | Purpose |
|---|---|
| `~/.claude/RPI.md` | Canonical methodology — the source of truth |
| `~/.claude/rpi.sh` | Defines the `rpi-init` and `rpi-refresh` shell functions |
| `~/.claude/commands/rpi.md` | User-level Claude Code slash command (harmless if you don't use Claude Code) |
| One line in `~/.zshrc` (or `~/.bashrc`) | `source ~/.claude/rpi.sh` |

---

## Using `/rpi` in Copilot CLI (primary)

Copilot CLI's `/rpi` command is wired up **per repo**. For each repo where you want it, run once:

```bash
cd /path/to/your/repo
rpi-init
```

That drops four files into the repo (none of which you need to touch):

| Path | Purpose |
|---|---|
| `RPI.md` | Repo-local copy of the methodology — what `/rpi` reads |
| `.github/prompts/rpi.md` | Powers `/rpi` inside `copilot -i` |
| `.claude/commands/rpi.md` | Project-level Claude Code command (only matters if your teammates use Claude Code too) |
| Block appended to `.github/copilot-instructions.md` | Tells Copilot the framework exists |

`rpi-init` is idempotent — existing files are skipped, never overwritten. Commit these files so the rest of your team gets `/rpi` automatically when they pull the repo.

### Invocation

Open an interactive Copilot session in the repo and use `/rpi`:

```
$ copilot -i
> /rpi Problem: The /api/users endpoint returns 500 when filter is missing. Mode: full-cycle
```

Or with mode inferred:

```
> /rpi Problem: Audit auth middleware for missing CSRF protection
```

The agent will read `RPI.md`, run Preflight (loading the repo's `CLAUDE.md` / `AGENTS.md` / `copilot-instructions.md` / `CONTRIBUTING.md` so it follows your conventions), then proceed through Research → Plan → Implement.

### Sharing with your team

Once you've run `rpi-init` in a repo and committed the four files, **your teammates don't need to do anything per-repo** — `/rpi` just works for them too as long as they've installed this toolkit on their machine. They only need:

1. `./install.sh` once on their machine
2. `git pull` to get the repo's `RPI.md` and prompt files

---

## Using `/rpi` in Claude Code (secondary)

If you happen to use Claude Code as well, you get a bonus: the installer adds a **user-level** `/rpi` command that works in any directory, including repos that have never been touched by `rpi-init`. It reads the canonical `~/.claude/RPI.md` directly.

When a repo *has* been initialized with `rpi-init`, the project-level command takes precedence and reads the repo's local `RPI.md` instead — letting per-repo overrides win.

---

## Updating

### Update an existing repo to pick up methodology changes

The methodology is copied (not symlinked) into each repo at `rpi-init` time. After editing `~/.claude/RPI.md`, run this in any repo where you want the change to apply:

```bash
cd /path/to/repo
rpi-refresh
```

### Update the toolkit itself

Pull the latest version of this folder and re-run `./install.sh`. The installer will overwrite `~/.claude/RPI.md` and `~/.claude/rpi.sh`. Repos won't pick up the change until `rpi-refresh` is run in each.

---

## Customizing the methodology

Edit `~/.claude/RPI.md` to change defaults (branching strategy, commit conventions, mode definitions, etc.). Repo-specific guidance still wins — during the **Preflight** phase the agent loads `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, and `CONTRIBUTING.md`, and treats anything they say as overriding the canonical defaults.

---

## Uninstalling

```bash
rm -f ~/.claude/RPI.md ~/.claude/rpi.sh ~/.claude/commands/rpi.md
```

Then remove the `source ~/.claude/rpi.sh` line from `~/.zshrc` or `~/.bashrc`.

---

## Troubleshooting

**`rpi-init: command not found`**
The shell rc didn't get re-sourced. Open a new terminal, or run `source ~/.zshrc` (or `~/.bashrc`).

**`/rpi` doesn't show up in Copilot CLI**
You're in a repo that hasn't been initialized. Run `rpi-init` from the repo root, then start a new `copilot -i` session.

**`/rpi` shows up but the agent ignores `RPI.md`**
Confirm `RPI.md` is at the repo root (not a subdirectory) and that `.github/prompts/rpi.md` exists. Re-running `rpi-init` is safe and will recreate any missing files.

**My team uses `main`, not `develop` — will RPI force gitflow?**
No. RPI's Preflight phase reads your repo's `CLAUDE.md` / `AGENTS.md` / `CONTRIBUTING.md` and uses whatever branching convention they document. Gitflow is only the fallback when nothing is documented.
