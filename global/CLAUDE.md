# Global instructions

## Before coding

- Name your assumptions. In a conversation, ask when two readings of the request lead to different code. In a delegated run (`/ship`, a ticket), take the reading the ticket supports, carry on, and list it under Decisions in the PR.
- When a simpler approach than the requested one exists, say so before building.
- Turn the task into a check that goes red, then green, before calling it done.

## Change scope

- Before writing, list every place the change must reach: callers, tests, fixtures, config, env vars, exports. Reach all of them and touch nothing else.
- Every changed line traces to the request. Match the surrounding style. Mention unrelated dead code or smells and leave them in place.
- Remove what your change orphaned (imports, helpers, variables). Pre-existing dead code stays.
- Before fixing a bug, grep every caller of the code you touch and fix the root cause once, in the shared code.
- Edit code with the Edit tool. Use a script edit only for one mechanical change across many files, then read its `git diff`.

## Simplicity

- Write the least code that meets the ticket: options, abstractions and config arrive when a second caller needs them.
- Handle the errors that can happen. Validation at trust boundaries, error handling that prevents data loss, security and accessibility always stay.

## Comments

Comments carry the why: intent, a constraint, the reason for a non-obvious choice, a link to the KB concept or issue. Use the lines the why needs. A public module or function may carry a short doc comment stating what it promises. Code that reads plainly gets none. A long gotcha lives in the KB, with a one-line pointer in the code.

## Reports

Lead with the outcome. Add a skipped-or-unverified line only when something was skipped, and a risk only when it is new: absent from the ticket or plan.

## Writing (unslop-lite)

In reports, chat and commit messages. Numbers are the `unslop` skill's rule ids.

- 3: no trailing "-ing" phrases ("ensuring...", "highlighting..."). Say the consequence as its own sentence.
- 7: plain words over AI vocabulary (crucial, delve, enhance, intricate, pivotal, showcase, tapestry, testament, underscore).
- 8: "is" and "has", not "serves as", "stands as", "boasts".
- 9: state the point; no "not just X, but Y".
- 13: no em dashes. Use a period or a comma.
- 16: no bold-label-colon lists that restate the line.
- 20, 21: no chatbot openers or closers, no praise of the question.
- 23: "to", not "in order to"; "because", not "due to the fact that".
- 24: one hedge at most, and only when the uncertainty is real.
- 27: name the mechanism or the number, not the feeling.
- 28: write connected prose. Join related clauses with "because", "so", "which". A paragraph makes one point.
- 33: whole sentences with articles and verbs; no arrow-speak or unexplained abbreviations.

## Environment (macOS, zsh)

- No `timeout`; use `gtimeout`.
- An unmatched glob is an error in zsh. Quote patterns passed to tools (`--include='*.md'`).
- Unix socket paths are limited to about 104 bytes; keep them short (e.g. under `/tmp`).
- A multi-line or `$`-heavy command for a remote host goes in a script file that you copy over or pipe to `ssh -T`. Never inline it.

## Data scripts

A scan, backup or move that processes 0 items exits non-zero and prints its counts (found, processed, skipped, failed).

## Git

- Before describing a push, run `git fetch && git log --oneline origin/<branch>..HEAD` and report the exact commits that will go.
- Confirm with the user before every `git push`. The one exception: invoking `/ship` confirms the push of its ticket branch.

## Knowledge

- If the repo has `docs/kb/index.md`, read it before changing code. Use only the types it declares. The `domain-modeling` skill's KB-FORMAT.md is the format.
- Auto-memory holds facts about the user only: preferences and feedback. Project status lives in the issue tracker and the KB, never in memory.
