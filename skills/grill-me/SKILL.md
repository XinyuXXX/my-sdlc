---
name: "grill-me"
description: "Explicit request or pstack routing only. Interrogate a plan over its design tree in one of two modes: collaborative intake when the tree is unsettled, adversarial thermonuclear when a formed plan must defend every load-bearing assumption."
license: MIT
metadata:
  my-sdlc-origin: "Intake mode ported from mattpocock/skills skills/productivity/grilling. Thermonuclear mode ported from the user-scope grill-me-thermonuclear (upstream author unmarked). Merged into one skill with two modes."
  my-sdlc-activation: "explicit"
---
# Grill me

Both modes work the same object: the plan's **design tree**, where every
decision branches into the decisions that hang off it. Pick the mode by
whether the plan is already formed.

- The tree is mostly unsettled, the request is vague, or the user says
  "grill me" → **Intake mode**.
- A formed plan or design needs stress-testing ("压测", "stress-test",
  "thermonuclear") → **Thermonuclear mode**.
- Intake that converges on a high-stakes plan can escalate to thermonuclear.
  Thermonuclear handed a still-forming idea abstains to intake; explicit
  invocation does not create an attack target.

## Intake mode (collaborative)

Interview the user relentlessly until you reach a shared understanding.

Work the tree in **rounds**. The **frontier** is every decision whose
prerequisites are already settled: the questions you can ask _now_ without
guessing at answers you haven't heard yet. Ask the whole frontier in one
round: number each question and give your recommended answer. Then wait for
the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer.

Each round the user answers reshapes the tree: settled decisions push the
frontier outward and unblock questions that depended on them. Recompute the
frontier and ask the next round. A question whose answer depends on another
question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs
a fact from the environment (filesystem, tools, etc.), dispatch a subagent to
find it; don't ask the user for anything you could look up yourself. Don't
block on it: a running exploration is an unsettled prerequisite, so only the
questions downstream of it wait for the subagent to report; ask the rest of
the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design
tree visited, nothing left silently assumed. Do not act on it until the user
confirms you have reached a shared understanding.

### Leave artifacts, not just conversation

An intake that ends only in chat is lost to the next session. As decisions
settle, write them down in the project's own docs. A hard-to-reverse or
surprising decision gets a short ADR in `docs/adr/` (what was decided, why,
what was rejected). Project vocabulary goes in `GLOSSARY.md` so every later
agent names things the same way. Before proposing anything, read the existing
ADRs in the area you are touching and never re-propose a rejected alternative.
Write only decisions that survive the frontier; scratch thinking stays in the
conversation.

## Thermonuclear mode (adversarial)

**Outcome:** kill a weak plan or earn a hardened one. Default verdict is
reject. Attack the plan, never the person.

### Interrogate

1. **Steelman, then strike.** Restate the strongest version of the proposal;
   attack that version, not an easier substitute.
2. **Build the decision tree.** Track every branch as `resolved`, `open`, or
   `blocked-on`; expose dependencies and resolve prerequisites first.
3. **Ground it.** Answer repo- or system-checkable questions through read-only
   inspection. Verify checkable user claims before accepting them. A
   contradiction is a **BLOCKER** and reopens the branch.
4. **Walk every branch.** Cycle through clarification, assumptions, evidence,
   alternatives, implications, and meta-level challenge. Funnel broad to
   narrow and close each escape before advancing.
5. **Presume failure.** Confidence is a reason to probe harder. Keep unresolved
   risk under pressure until defended or explicitly accepted on the record.

Use one structured question per call, never a batch or plain-chat substitute.
Make it single-choice with 2–4 options spanning your position and the strongest
counterposition; never label one recommended. A real defense belongs in the
free-text option.

### Required pressure tests

**Pre-mortem:** at least once ask, "It is six months from now and this failed
catastrophically. What killed it?" Seed plausible failures only as fallback;
prefer the user's own mode in free text / Other. Open a separate branch for
each surfaced mode and interrogate it. Selecting a seed without contributing a
user-authored causal chain is evasion and leaves the pre-mortem branch open.
Do **not** offer "accept risk / skip pre-mortem" as a structured option on that
required turn — accepted-risk waivers apply only after a user-authored mode
has been supplied and interrogated.

**Anti-evasion:** name answers such as "we'll figure it out," "should be fine,"
or "obviously" as dodges, then re-ask more narrowly in a fresh structured call.
Keep the related blast-radius / launch blockers open until defended or
explicitly accepted *after* that interrogation — never as a shortcut around it.

**Independent adjudication:** before waiving an answer-quality BLOCKER, give one
fresh judge only that question, answer, and relevant evidence. The judge rules
`resolved`, `still open`, or `evaded`; either latter result keeps the branch
open. Judge blockers separately. Never delegate the live interrogation.

### Verdict and handoff

Tag unresolved residue **BLOCKER**, **MAJOR**, or **MINOR**. Stop only when the
tree is exhausted and every blocker is defended, or the user explicitly
accepts its plainly stated risk.

End with **APPROVED**, **APPROVED-WITH-ACCEPTED-RISK**, or **REJECTED**. Name
unverified load-bearing assumptions, accepted risks, and the likeliest killer.

Rejection ends the process; do not manufacture a replacement plan. Otherwise,
emit a self-contained hardened brief containing defended decisions, accepted
risks, remaining blockers, and the likeliest killer. Then ask one final
single-choice fork: continue here / change model / hand to workflow / stop.
Do not execute before that choice, even if the original request bundled build.

## Where it fits in my-sdlc

Grill-me is the intake valve for vague requests, upstream of the playbooks.
When the tree settles, route the outcome to the matching playbook:
Feature for a build, multi-phase-plan for a phased program, Prototype when a
fork still needs an experiment instead of an answer. A fork a run can settle
is not a grill-me question; observe it per poteto-mode's Non-negotiables
instead of asking.
