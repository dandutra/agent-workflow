---
name: review
description: 'Review the diff since a fixed point (commit, branch, tag, merge-base) on three axes in parallel subagents: Standards, Spec, Correctness, then verify the Important findings. Use when the user wants a branch, PR or work-in-progress reviewed, or asks to "review since X".'
---

Three-axis review of the diff between `HEAD` and a fixed point:

- **Standards**: does the code follow this repo's documented standards and the smell baseline?
- **Spec**: does the code do what the originating issue asked?
- **Correctness**: bugs, security holes and downstream breakage.

Each axis runs as its own subagent so one axis's context never colours another's. A fresh verifier then checks every Important finding against the code.

## Process

### 1. Pin the fixed point

Use the fixed point the user gave (SHA, branch, tag, `main`, `HEAD~5`). If they gave none, ask.

The diff command is `git diff <fixed-point>...HEAD` (three dots: against the merge-base). The commit list is `git log <fixed-point>..HEAD --oneline`.

Confirm the ref resolves (`git rev-parse <fixed-point>`) and the diff is non-empty before dispatching anything.

### 2. Find the spec

In this order:

1. Issue references in commit messages or the branch name (`#123`, `Closes #45`), fetched as `docs/agents/issue-tracker.md` describes (GitHub Issues: `gh issue view <n>`).
2. A path the user passed.
3. A spec under `docs/`, `specs/` or `.scratch/` matching the branch.
4. Otherwise ask. If there is none, Spec reports "no spec available".

### 3. Find the standards sources

`REVIEW.md` at the repo root first, then `CODING_STANDARDS.md`, `CONTRIBUTING.md`, the root and touched-directory `CLAUDE.md` files, and `docs/kb/index.md` with any `gotcha` or `decision` concepts in the touched area. Note which tools already run in CI or hooks (linter, formatter, typechecker): findings those tools catch are skipped.

### 4. Dispatch the three axes in parallel

One message, three Agent calls. Each gets the diff command, the commit list, and the brief below.

| Axis | `subagent_type` | `model` | Extra input |
|---|---|---|---|
| Standards | `reviewer-standards` | `sonnet` | the standards files from step 3, the tooling list |
| Spec | `reviewer-spec` | `sonnet` | the spec path or fetched body |
| Correctness | `reviewer-correctness` | `opus` | the touched area's KB gotchas, if any |

Skip Spec when there is no spec. If the diff touches auth, sessions, CSRF, file uploads or database migrations, also run `/security-review` and fold its findings into Correctness.

Every finding comes back tagged:

- **Important**: should block the merge. A real defect, a hard standards breach, a missing requirement.
- **Nit**: worth fixing, not blocking. Every smell-baseline hit is a Nit at most.
- **Pre-existing**: a real problem on lines the diff did not change. Reported, never counted against the change.

### 5. Verify

Dispatch one `verifier` agent (`model: opus`) with every Important finding, the diff command, and the file:line each finding cites. It reads the code fresh and returns each finding as **confirmed**, **downgraded** (to Nit or Pre-existing, with the reason) or **false positive**. Drop the false positives. Nits and Pre-existing skip verification.

### 6. Report

First line: the counts, e.g. `3 Important · 5 Nit · 1 Pre-existing (2 false positives dropped)`.

Then `## Standards`, `## Spec` and `## Correctness`, each listing its findings Important first, every one with file:line. Keep the axes separate and do not rerank across them: a change can pass one axis and fail another, and merging them lets one mask the other.

End with the worst finding per axis, or "clean" for an axis with none.
