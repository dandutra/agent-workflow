---
name: review
description: 'Review the diff since a fixed point (commit, branch, tag, merge-base) at a tier picked from its risk: from CI-only up to Standards, Spec and Correctness in parallel subagents plus a verifier. Use when the user wants a branch, PR or work-in-progress reviewed, or asks to "review since X".'
---

Review of the diff between `HEAD` and a fixed point, at a depth set by its **tier**:

- **Standards**: does the code follow this repo's documented standards and the smell baseline?
- **Spec**: does the code do what the originating issue asked?
- **Correctness**: bugs, security holes and downstream breakage.

Each axis runs as its own subagent so one axis's context never colours another's. A fresh verifier then checks Important findings against the code. A reviewer asked to find problems always finds something, so the tier spends review where risk is, not evenly.

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

### 3. Pick the tier

Run `~/.claude/skills/review/tier.sh <fixed-point> <ticket-tier>` from the repo root, where `<ticket-tier>` is the ticket's **Review tier** field (omit it when the ticket has none). It prints the tier and the signals behind it. `tier=N` in the user's request overrides the script.

| Tier | When | Review |
|---|---|---|
| 0 | Every file on a low path: docs, KB, copy, version pins | CI only. Report "tier 0, no review" and stop. |
| 1 | Small (under 300 non-test lines), tested at its seams, no critical path | One `reviewer-correctness` with `model: sonnet`, also given the spec to check its Acceptance lines. No verifier. One re-review at most. |
| 2 | Default for feature work, or one raising signal | Correctness (`opus`) and Spec (`sonnet`). Standards only when the repo has `REVIEW.md` or a standards doc. The verifier only when Important findings exist. Two re-review rounds. |
| 3 | A critical path in `REVIEW.md`, or two raising signals | All three axes, the verifier, and `/security-review` where it applies. Re-review until clean. After 3 rounds, stop and ask the user. End the report with a decision brief, and say the user should read the diff. |

When the script reports **live check required**, the review does not cover that risk: put it in the report so the caller runs the ticket's live check.

### 4. Find the standards sources

Tiers 2 and 3. `REVIEW.md` at the repo root first, then `CODING_STANDARDS.md`, `CONTRIBUTING.md`, the root and touched-directory `CLAUDE.md` files, and `docs/kb/index.md` with any `gotcha` or `decision` concepts in the touched area. Note which tools already run in CI or hooks (linter, formatter, typechecker): findings those tools catch are skipped.

### 5. Dispatch the axes in parallel

One message with every Agent call the tier asks for. Each gets the diff command, the commit list, and its extra input.

| Axis | `subagent_type` | `model` | Extra input |
|---|---|---|---|
| Standards | `reviewer-standards` | `sonnet` | the standards files from step 4, the tooling list |
| Spec | `reviewer-spec` | `sonnet` | the spec path or fetched body |
| Correctness | `reviewer-correctness` | `opus` (tier 1: `sonnet`) | the touched area's KB gotchas, if any; at tier 1, also the spec |

Skip Spec when there is no spec. If the repo's `CLAUDE.md` or `REVIEW.md` limits the review to certain axes, dispatch only those.

Every finding comes back tagged:

- **Important**: should block the merge. A real defect, a hard standards breach, a missing requirement.
- **Nit**: worth fixing, not blocking. Every smell-baseline hit is a Nit at most.
- **Pre-existing**: a real problem on lines the diff did not change. Reported, never counted against the change.

### 6. Verify

Tiers 2 and 3, when there is at least one Important finding. Dispatch one `verifier` agent with every Important finding, the diff command, and the file:line each finding cites. It reads the code fresh and returns each finding as **confirmed**, **downgraded** (to Nit or Pre-existing, with the reason) or **false positive**. Drop the false positives. Nits and Pre-existing skip verification.

### 7. Report

First line: the tier and the counts, e.g. `Tier 2 · 3 Important · 5 Nit · 1 Pre-existing (2 false positives dropped)`. Then the signals `tier.sh` printed, one line.

Then one section per axis that ran, each listing its findings Important first, every one with file:line. Keep the axes separate and do not rerank across them: a change can pass one axis and fail another, and merging them lets one mask the other.

Tag each Important finding **one-off** or **repeatable**. Repeatable means the same class of mistake could recur on another ticket (a missing env var, a fake that drifts from the live API). The caller files repeatable ones in the KB inbox.

End with the worst finding per axis, or "clean" for an axis with none.

## Re-review

After the caller fixes Important findings, re-review only the new commits (`git diff <last-reviewed-commit>...HEAD`) at the same tier, within the tier's round limit. A fix that is itself unreviewed when the limit runs out is listed as such in the report.
