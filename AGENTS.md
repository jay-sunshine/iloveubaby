# Project Agent Rules

## Session Bootstrap (Required)
For every new Codex window/session in this repository, do these steps before changing code:

1. Read `docs/codex/PROJECT_MEMORY.md`.
2. Read `docs/codex/TASK_BOARD.md`.
3. Read the latest entry in `docs/codex/SESSION_HANDOFF.md`.
4. Return a short "Current understanding / Plan / Risks" summary before edits.

## During Work
1. Keep changes scoped to the active task in `docs/codex/TASK_BOARD.md`.
2. Update the task status if scope or priority changes.
3. Keep temporary probes in `tmp/` or `tools/_tmp_*`; do not mix them into core runtime scripts.
4. Do not force-create missing runtime nodes, config entries, or UI hookups just to make a feature appear; if something is absent, assume there may be a deliberate reason and verify the root cause first.

## End of Work
1. Append one handoff entry to `docs/codex/SESSION_HANDOFF.md`.
2. Include: what changed, unresolved risks, and exact next step.
3. If architecture assumptions changed, update `docs/codex/PROJECT_MEMORY.md` in the same turn.
