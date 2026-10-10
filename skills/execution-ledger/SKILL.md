---
name: "execution-ledger"
description: "Persistent on-disk progress ledger for multi-phase or unattended runs. Records completed tasks, test evidence, rulings, and parked findings so work survives context compaction and session loss."
license: MIT
metadata:
  my-sdlc-origin: "Ported from obra/superpowers SDD ledger, adapted for my-sdlc."
---
# Execution ledger

Long or multi-phase work must not live only in the conversation. Keep a ledger
on disk so a compacted, restarted, or replacement agent resumes from the ledger
plus `git log` instead of redoing work or skipping tasks.

## Where it lives

`.my-sdlc/runs/<plan-or-task-slug>/progress.md` in the working tree. One
directory per plan or run so a follow-up effort can never read a stale ledger
as current. Add `.my-sdlc/` to the project's `.gitignore` (or use a local
exclude) on first use. The ledger is a working artifact, never committed.

Sibling files in the same directory hold bulky evidence: per-task test logs,
implementer reports, review diffs. The ledger carries pointers, not dumps.

## What goes in it

Append a line or short block when any of these happens.

- **Task complete.** `Task N: complete (commits <base>..<head>, tests: <command> → <last line>)`.
  Record it only after the test command actually ran and passed. A failing run
  records nothing as complete.
- **Ruling.** Any decision you made without asking: what, why, and the cost if
  wrong. `Ruling: <what> — <why> (cost if wrong: <cost>)`. Silent decisions
  are forbidden; stalled questions are forbidden. Decide, record, report at
  the end.
- **Parked finding.** A real issue you deliberately did not fix now, with the
  reason and where it lives. `Parked: <finding> at <file:line> — <why deferred>`.
- **Fix round.** Each review-fix iteration and its scoped re-review verdict.

Append-only. A wrong entry gets a superseding entry, never an edit.

## Resuming

On session pickup after compaction or restart, read the ledger and `git log`
before doing anything. Reconcile them: a task the ledger calls complete must
have its commits in the log. Trust the ledger for what is done; trust the
ledger plus the plan for what is next. Never re-execute a completed task, and
never skip a task because the conversation summary claims it happened.

## Final report

When the run hands back, the reply includes a **Rulings I made** list and a
**Parked findings** list compiled from the ledger. Nothing the ledger records
stays invisible to the operator.

## Companion

The **show-me-your-work** skill's `decisions.tsv` is the evidence-backed
decision trail for audit; this ledger is the execution state for resumption.
Long unattended runs keep both.
