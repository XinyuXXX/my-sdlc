---
name: "tdd"
description: "Test-driven development for every feature and bug fix. Failing test first, watched to fail, minimal code to green, whole suite verified."
license: MIT
metadata:
  pstack-distilled-origin: "cursor/plugins/pstack/skills/tdd"
  my-sdlc-note: "Merged with the superpowers TDD iron law."
---
# Test-Driven Development

Write the test first. Watch it fail. Write the minimal code to pass it. If you
did not watch the test fail, you do not know it tests the right thing.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

This holds for new features, bug fixes, behavior changes, and refactoring that
touches behavior. Wrote code before the test? Delete it and start over. Do not
keep it as reference, do not adapt it while writing tests. Delete means delete.

Violating the letter of the rules is violating the spirit of the rules.

## The narrow exception

Skip a new test only when every practical test path is genuinely impractical:
broad harness setup, brittle mocks, slow end-to-end infrastructure,
production-only state, or large unrelated fixture churn. Then use the closest
executable regression check instead (a targeted script, a manual reproduction
command, browser automation, a log assertion) and say so in the report. Prefer
no new test over a bad test. "It felt inconvenient" is not impractical. When in
doubt, write the test.

## Workflow

1. **Understand the behavior.** Intended behavior, current behavior, affected
   path, smallest observable reproduction. For a bug, reproduce it yourself on
   the real surface first.
2. **RED. Write the failing test.** One behavior, a clear name, real code with
   no mocks unless unavoidable. Encode intended behavior, not the current
   implementation. Assert on behavior, per **principle-test-behavior-not-implementation**.
3. **Verify RED. Watch it fail.** Mandatory, never skip. Run the new test and
   confirm it fails for the intended reason (feature missing), not a typo or an
   unrelated error. A test that passes immediately is testing existing
   behavior. Fix the test.
4. **GREEN. Minimal code.** Write the simplest production change that passes
   the test. No extra features, no speculative options, no "improvements"
   beyond the test.
5. **Verify GREEN.** Run the new test, then run the project's whole test
   command (bare `pytest`, `npm test`, `cargo test`, whatever the repo uses),
   not just your file. A green run of one file is not a green suite. Report any
   failure by name, including one you did not cause. A red test you watched
   scroll past and did not mention is a report falsified by omission.
6. **REFACTOR.** After green only. Remove duplication, improve names, extract
   helpers. Keep tests green. Add no behavior.
7. **Commit in RED-before-GREEN order for bug fixes.** Stage the failing
   repro ahead of the fix in git history when practical, so the history proves
   the bug and its fix.

## Common rationalizations

| Excuse | Reality |
|---|---|
| "Too simple to test" | Simple code breaks. The test takes 30 seconds. |
| "I'll test after" | Tests written after pass immediately, which proves nothing. You never watched them fail, so you never proved they catch the bug. |
| "Already manually tested" | Manual testing is ad-hoc, unrecorded, and unrepeatable. "Worked when I tried it" is not evidence. |
| "Keep it as reference" | You will adapt it. That is testing after. Delete means delete. |
| "Need to explore first" | Explore, throw the exploration away, then start with the test. |
| "TDD slows me down" | Debugging in production is slower. TDD is the pragmatic path. |
| "This is different because..." | That sentence is the rationalization. |

All of these mean: delete the code, start over with the test.

## Final response

Report the evidence, not just the outcome.

- Name the failing-before test or executable check and the failure it produced.
- Name the passing-after run, including the whole-suite result.
- If failing-before evidence could not be demonstrated, state why and name the
  closest regression check used instead.
