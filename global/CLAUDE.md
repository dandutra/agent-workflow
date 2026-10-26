# Global instructions

## Change scope

- Before writing, list every place the change must reach: callers, tests, fixtures, config, exports.
- Before fixing a bug, grep every caller of the code you touch and fix the root cause once, in the shared code.
- Never cut validation at trust boundaries, error handling that prevents data loss, security, or accessibility.
- End every task report with one or two lines: what you skipped or did not check, and any risk the user must know.

## Comments

Comment only the why the code cannot show, in one line. Never narrate what the code does. A gotcha goes in the KB (or the repo's gotchas file), with a one-line pointer in the code if a reader needs it there.

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
- 28: one idea per sentence.
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
- Confirm with the user before every `git push`.

## Knowledge

- If the repo has `docs/kb/index.md`, read it before changing code. Use only the types it declares. The `domain-modeling` skill's KB-FORMAT.md is the format.
- Auto-memory holds facts about the user only: preferences and feedback. Project status lives in the issue tracker and the KB, never in memory.
