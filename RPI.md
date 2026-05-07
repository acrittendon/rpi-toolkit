# RPI Agent Methodology

The RPI framework has four ordered phases: **Preflight → Research → Plan → Implement**.

---

## Modes

| Mode | Description | When to pick |
|---|---|---|
| `investigate-only` | Research phase only; produce a findings report, no implementation | Open-ended question, exploration, "how does X work" |
| `full-cycle` | Preflight → Research → Plan → Implement → PR | Bug, feature, regression — the default for actionable problem statements |
| `audit` | Findings inventory drives plan and implementation | Security review, quality sweep, dependency review |
| `test` | Coverage baseline drives plan and implementation | Missing or insufficient test coverage |
| `refactor` | Behavior map preserved; structure changed | Restructuring with no intended behavior change |

If mode is unspecified, infer it from the problem statement using the table above before starting Preflight.

---

## Phase 0: Preflight

**Goal:** load repo-specific context so the rest of the framework defers to local conventions instead of overriding them.

Read whatever exists, in this order:
- `CLAUDE.md`, `AGENTS.md`, and any nested variants (`apps/*/CLAUDE.md`, package-level overrides, etc.)
- `.github/copilot-instructions.md`, `.github/prompts/*.md`
- `CONTRIBUTING.md`
- The contributor / dev sections of `README.md`
- Root config files that imply tooling: `package.json` scripts, `Makefile`, `justfile`, `pyproject.toml`, `.editorconfig`

Extract and record (in conversation context — no scratch files):
- **Branching convention:** trunk-based on `main`, gitflow on `develop`, other? What's the PR target?
- **Commit conventions:** Conventional Commits? Custom prefix? Co-author trailer policy?
- **Test / lint / typecheck commands:** the exact commands the repo uses for CI (`npm test`, `pytest`, `cargo test`, `make check`, etc.)
- **Any explicit AI-agent guidance** that would override the Universal Rules below

If repo guidance conflicts with the Universal Rules in this document, **repo guidance wins** — note the override explicitly so subsequent phases respect it.

**STOP WHEN:** the four items above are recorded (or explicitly marked "not documented") and any overrides are noted.

---

## Phase 1: Research

**Goal:** fully understand the problem before proposing solutions.

Gather mode-appropriate evidence and produce concrete proof artifacts:
- `full-cycle` (bug/regression): reproduction case + stack trace or failing assertion
- `audit`: annotated findings inventory with severity
- `test`: coverage report highlighting uncovered paths
- `refactor`: behavior map (inputs → outputs, call graph, or equivalent)
- `investigate-only`: structured findings report answering the question

Do NOT propose solutions during this phase.

**STOP WHEN:** the problem is fully understood and the mode-appropriate proof artifact exists.

---

## Phase 2: Plan

**Goal:** design an implementation strategy grounded in research findings and the conventions captured in Preflight.

- Translate findings into a discrete, ordered task list (use the agent's task tracker; do not file GitHub issues for in-cycle work)
- For each task define: what will be done, the acceptance condition, and the exact command(s) that will prove it (using the test/lint/typecheck commands recorded in Preflight)
- For non-trivial work (refactors, audits, multi-file features), produce a small proof of concept validating the approach before committing to it. For trivial fixes (single-file, low-risk), the PoC step may be skipped — note the skip explicitly with a one-line justification.
- Surface and resolve risks before implementation begins

**STOP WHEN:** an ordered plan exists with acceptance conditions and required PoC (if any) has confirmed the approach.

---

## Phase 3: Implement

**Goal:** execute the plan.

- Each task produces proof of completion matching its acceptance condition
- Branching and PR target follow the convention recorded in Preflight; default to gitflow (feature branches off `develop`, PRs target `develop`) only if no convention is documented
- Commit messages follow the convention recorded in Preflight; default to Conventional Commits without co-author trailers only if no convention is documented
- Implementation is not "done" until the repo's existing test, lint, and typecheck commands (recorded in Preflight) pass on the changed code
- Newly discovered issues outside the current scope are logged separately (file a GitHub issue, or use whatever tracker the repo prefers) — never absorbed into the current cycle

**STOP WHEN:**
- `full-cycle` / `audit` / `test` / `refactor`: PR is open with proof of completion attached and all repo checks pass
- `investigate-only`: findings report is finalized

---

## Universal Rules

These are defaults. Anything contradicted by repo guidance loaded in Preflight takes precedence.

- Phase order is strict: Preflight → Research → Plan → Implement. No exceptions.
- Proof is required at every phase gate, not just at completion.
- If a phase produces a finding that invalidates earlier work, restart that phase. Preflight findings can invalidate Research; Research findings can invalidate the Plan.
- When multiple issues exist: merge or unblock any open PRs before starting new work, then proceed to the highest-priority unstarted issue and complete the full RPI cycle before starting the next.
- Never weaken or skip the repo's existing CI checks to ship faster — no `--no-verify`, no disabling pre-commit hooks, no commenting out failing tests.

---

## Invocation

| Agent | Command |
|---|---|
| Claude Code | `/rpi Problem: [statement]. Mode: [mode]` |
| Copilot CLI | `/rpi Problem: [statement]. Mode: [mode]` |
| Direct prompt | Paste the problem statement and mode into any agent context that has read RPI.md |
