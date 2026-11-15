---
name: ship
description: "Ship one ticket: build it test-first, run its live check, review it at its tier, update the KB, push the branch and open the PR."
disable-model-invocation: true
argument-hint: "<issue number>"
model: sonnet
---

Ship ticket `#$ARGUMENTS` from a fresh branch to an open PR. Start the session with `ship <n>` (`claude --model sonnet "/ship <n>"`) so every turn stays on Sonnet, follow-ups included. The repo's `CLAUDE.md` holds its check command, test database rule and live-check commands.

Invoking `/ship` is the user's confirmation to push the ticket branch. It never covers `main`.

## 1. Preflight

- `gh issue view <n>`. If a **Blocked by** issue is still open, stop and report it.
- Read **Read first**, **Seams under test**, **Risks and checks**, **Live check**, **Review tier** and **Acceptance**. An older ticket without the risk fields gets tier 2 and "no live check listed".
- `git fetch` and branch `ticket-<n>-<slug>` from `origin/main`.

Done when the branch exists and you can name every seam and every listed risk.

## 2. Build

Build with `/tdd` at the ticket's seams. Each listed risk gets the test or check the ticket names for it. Run typecheck and single test files while working. Run the repo's full check once at the end, with nothing else using the test database.

Done when the full check passes and every Acceptance line is met.

## 3. Live check

Run each live check the ticket lists and record the command and what came back. When the ticket lists none but `tier.sh` reports **live check required**, say so under Deviations in the PR.

## 4. Review

Run `/review origin/main`, passing the ticket's tier as the floor. Fix each Important finding test-first, then re-review the new commits within the tier's round limit. At tier 3, when the limit runs out, stop and ask the user.

## 5. KB

Dispatch `kb-writer` with the diff command, the ticket, and the lessons: review findings tagged repeatable, a live-check surprise, anything the build taught that the ticket did not say. It writes on the branch. Commit its changes.

## 6. Push and PR

Show `git log --oneline origin/main..HEAD`, push the branch, and open the PR with `Closes #<n>` and these sections:

- **Summary**: what changed, two or three lines.
- **Decisions**: non-obvious choices, alternatives rejected, the reading taken where the ticket was ambiguous, KB decisions touched.
- **Verification**: the check command, the live check and its result.
- **Deviations**: risks the ticket did not list, and anything skipped. "None" when there are none.
- **Review**: the tier, its signals, and the finding counts per round.

Report the PR URL and the Deviations section. Nothing else needs a caveat.
