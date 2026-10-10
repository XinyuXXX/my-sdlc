---
name: "execution-ledger"
description: "Persistent on-disk trail for long, multi-phase, or unattended runs. A progress.md ledger carries execution state for resumption; a decisions.tsv log carries evidence-backed decisions for audit. Work survives context compaction and session loss."
license: MIT
metadata:
  my-sdlc-origin: "progress.md ledger ported from obra/superpowers SDD ledger; decisions.tsv merged from the pstack show-me-your-work skill. One skill, two artifacts."
---
# Execution ledger

Long or multi-phase work must not live only in the conversation. Keep the
trail on disk so a compacted, restarted, or replacement agent resumes from it
plus `git log` instead of redoing work or skipping tasks, and so a reviewer
can audit what happened without trusting a summary.

One skill keeps two artifacts. Both live under
`.my-sdlc/runs/<plan-or-task-slug>/` in the working tree, one directory per
plan or run so a follow-up effort can never read a stale trail as current.
Add `.my-sdlc/` to the project's `.gitignore` (or use a local exclude) on
first use. The trail is a working artifact; commit it only when the work is
ambitious enough that a reviewer needs it to trust the result. Sibling files
in the same directory hold bulky evidence: per-task test logs, implementer
reports, review diffs. Both artifacts carry pointers, not dumps.

- **progress.md** is the execution state for resumption. Every long or
  unattended run keeps it.
- **decisions.tsv** is the evidence-backed decision log for audit. Keep it for
  any run the operator steps away from, and for any run whose stakes need an
  auditable record.

Both are append-only. A wrong entry gets a superseding entry, never an edit.

## progress.md: what goes in it

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

## Resuming

On session pickup after compaction or restart, read the ledger and `git log`
before doing anything. Reconcile them: a task the ledger calls complete must
have its commits in the log. Trust the ledger for what is done; trust the
ledger plus the plan for what is next. Never re-execute a completed task, and
never skip a task because the conversation summary claims it happened.

## decisions.tsv: the format

A single TSV file, one row per decision. Cells stay single-line. Evidence is a
pointer, not prose. Copy `references/decision-log-template.tsv` (the header
row) to start a clean log. Columns:

- **ts.** ISO8601 timestamp.
- **phase.** The phase or workstream.
- **decision.** What was chosen or done, one line.
- **why.** The reason in plain words. If a principle drove it, say it plainly,
  not as a jargon tag.
- **evidence.** A link or path that proves it: commit SHA, PR number,
  `file:line`, or an artifact, trace, or screenshot path. Never a paragraph.
- **result.** The outcome or predicate state: `tests green`, `reverted`,
  `pixel-diff 0`, `INCONCLUSIVE`, `open`.

An example, plain-spoken so a reviewer reads it at a glance.

```
ts	phase	decision	why	evidence	result
2026-05-24T09:02:00Z	frame	counted the work first, about 100 components and roughly 75 hours	wanted to know the size before starting a long run	commit 3a9f1c2	found 5 things to sort out before starting
2026-05-24T11:15:00Z	widget	moved the widget styles over without changing how it looks	keep the change small and the result identical	commit 7c21e0a, pixel-diff 0	looks identical, tests pass
```

## Logging a row

Write each entry the way you'd tell a teammate what you did. Plain words,
concrete actions, no AI speak or abstract jargon (the **unslop** skill applies
to log text too).

Use the helper `scripts/log.sh <logfile> <phase> <decision> <why> <evidence> <result>`.
It stamps `ts`, writes the header on first use, strips stray tabs/newlines,
and prefixes any cell starting with `=`, `+`, `-`, or `@` with a single quote.
A bare `printf` appending a row works too, but mind those same bytes if cells
come from generated or user-supplied text.

Log decision points and checkpoints, not every action: a fork chosen, a unit
completed with its verification result, a pivot or revert with its trigger, a
blocker surfaced, a gate fixed. For loop runs, one row per iteration. Skip the
trivial and self-evident.

A run is one agent conversation, including its later turns and any summary of
it. A pickup, a replacement agent, or a new chat starts a new run. When a run
adds to a log that already has rows, its first row has phase `start`, and so
does its first row after another run's `start` row. A run that comes back to a
log in a later turn first reads the log's last rows to see whether another run
wrote since. A `start` row names the `ts` range of the rows before it that
this run did not write, and its evidence names this run, such as its session
or conversation ID. Use phase `start` for nothing else.

Prefer evidence produced by committed scripts over hand-made one-offs (the
**encode-lessons-in-structure** principle skill).

## Audit the log against the conversation record

At the end of the run, before handing back, check the log told the truth. Read
this run's conversation record when the host exposes it. Never probe private
storage or another workspace's history. Walk this run's rows against what
actually happened. Each stretch of them begins at one of this run's `start`
rows, or at the first row if this run created the log, and ends at the next
`start` row of another run:

- Check that every row maps to a real decision or action.
- Check that each row's evidence resolves and shows what the row claims.
- A fork, pivot, or abandoned approach that shaped the work but isn't logged
  is a gap. Add it.

Correct the log, not the story. The audit never edits or removes a row, even
an invented one. When a row records neither a real decision nor a real action,
or its claim or evidence is wrong, add a row that supersedes it with what
actually happened and a pointer that resolves. This audit does not check rows
outside this run's stretches. If this run's own work shows one of them is
wrong, supersede it like any wrong call.

## Cross-model review of the trail

Before handing back, seek an independent review of the audit trail and
conversation record when the host supports delegation. Prefer a reviewer on a
different model family for genuinely fresh eyes. When independent review is
unavailable, perform the same structured risk scan inline and disclose that it
was self-review. This is not a redo of the work; it flags what the user should
scrutinize.

- Decisions logged with weak or absent evidence.
- Verification steps skipped or claimed without proof in the conversation
  record.
- Choices that look risky in hindsight (premature, scope-creeping, papering
  over a symptom).
- Gaps the user would otherwise miss on a casual skim.

## Final report

When the run hands back, the reply includes a **Rulings I made** list and a
**Parked findings** list compiled from progress.md, plus an **Attention**
section for any run that produced decisions.tsv. When an independent review
ran, lead with `reviewed by <model-or-role>`; otherwise lead with
`self-review only (independent reviewer unavailable)`. Then list each flag
with specific evidence. "No flags" is valid. Nothing the trail records stays
invisible to the operator.

## Reviewing the trail

Read top to bottom, follow the evidence pointers, spot-check. GitHub renders a
committed TSV as a table. `column -s$'\t' -t decisions.tsv` renders it in a
terminal.

## Composing this skill

Other skills route their run trail here instead of inventing one. Reference it
by name and let it own the formats. Don't restate the columns.
