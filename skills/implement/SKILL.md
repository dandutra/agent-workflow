---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
model: sonnet
---

Implement the work described by the user in the spec or tickets.

1. Read the ticket in full. Its **Seams under test** section names where tests go; its **Read first** section names what to read before touching code.
2. Build it with /tdd at those seams. Run typechecking and single test files as you go, and the full suite once at the end.
3. Run /review against the branch's fixed point.
4. Fix every Important finding. Then re-run /review on the new diff only (`git diff <last-reviewed-commit>...HEAD`). Stop after 2 re-review rounds; list any Important finding still open in your report rather than looping further.
5. Commit to the current branch.
