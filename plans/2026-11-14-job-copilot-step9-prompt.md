Open a session in ~/Projects/job-hunting-copilot and paste everything below the line.

---

Context: the agent-workflow repo just changed how tickets, review and shipping work. The plan is `~/Projects/agent-workflow/plans/2026-11-14-workflow-review.md`. Read items 3, 4, 6 and 9, and step 9 of its Implementation order. Read `docs/kb/index.md` and `docs/agents/issue-tracker.md` before changing anything. Work on a branch `workflow-setup`, one commit per numbered part, and show me the diff before any push.

What changed upstream, so you know what this repo must match:

- `/implement` is now `/ship <n>`. It reads a ticket's **Risks and checks**, **Live check** and **Review tier**, runs the live check, and passes the tier to `/review` as a floor.
- `/review` runs `~/.claude/skills/review/tier.sh`, which reads a `review-tiers` block in the root `REVIEW.md`. The template is `~/Projects/agent-workflow/stacks/ts/REVIEW.md`.
- The ticket form template with the three new fields is `~/Projects/agent-workflow/stacks/ts/.github/ISSUE_TEMPLATE/ticket.yml`.

## 1. Ticket format

Agents write tickets with `gh issue create`, which never renders the YAML form, so the form alone does not reach them. `docs/agents/issue-tracker.md` is the doc they read, so the format lives in two places that must stay in step:

- `.github/ISSUE_TEMPLATE/ticket.yml`: add Risks and checks, Live check and Review tier, between Seams under test and Acceptance, worded as in the stack template but with this repo's examples: env vars and secrets reaching `.env.example`, `compose.yaml` and the workflows; a Job source whose live response may differ from its recorded fixture; data a Prisma migration could lose; the shared test database.
- `docs/agents/issue-tracker.md`: add the three headings to the CLI heading list, in the form's order. Add two or three lines on how to fill them: every risk names the test, live check or manual step that handles it, and a tier is 0 docs only, 1 small and tested, 2 feature work, 3 critical path (the `REVIEW.md` list). Replace `/implement` with `/ship`.

Ask me before writing a KB concept about it. The KB's types are glossary, decision, gotcha, job-source and runbook, and a ticket format is none of them. If the reason behind the fields deserves recording (risks that surfaced late on #31, #35, #37, #38, #73), propose a `decision` concept that links to `issue-tracker.md` and does not copy the field list.

Done when a ticket created from the CLI by following `issue-tracker.md` has the same headings, in the same order, as one created from the web form.

## 2. CLAUDE.md

Write a root `CLAUDE.md` of about 30 lines, holding only what an agent cannot find by looking:

- One line on what the app is.
- The check command and what it runs, the test database rule (one full run at a time, reviewers never run it), and how to run one test file.
- Deploy: the Droplet over Tailscale, `deploy/` and the runbooks, and that the app has no public address.
- Where a new env var must reach.
- Pointers, each worded with its trigger: `docs/kb/index.md` before changing code; `docs/agents/issue-tracker.md` whenever a ticket is written or read; `REVIEW.md` for review.

Leave out what `package.json`, the directory layout or the KB already says. Use the `writing-for-agents` skill.

Done when each line passes this test: would an agent working without it get something wrong?

## 3. Path-scoped rules

Add `.claude/rules/` files with `paths:` frontmatter, only where a rule holds for one area:

- `apps/api/src/ingestion/**`: a changed adapter needs a live check against one real tenant or board before the PR, and its fixture gets re-recorded when the live shape differs.
- Prisma schema and migrations: migrations must not lose data, plus the existing gotchas, linked rather than copied.

Done when each rule names its paths and links the KB gotcha it rests on.

## 4. REVIEW.md

Start from the stack template. Fill in:

- The `review-tiers` block. Critical: auth and the tailnet guard, Prisma schema and migrations, matching and merges, anything that closes or deletes Postings or Sightings, the Trace check and tailoring gate, backups, deploy, infra and the deploy workflow. Low: the CSS, and docs (already a default).
- The failure classes, each linking its gotcha: a missing env var, a fake drifting from the live API, a bulk-edit corruption, a fix that brings in a new bug.

Done when `~/.claude/skills/review/tier.sh <base>` on PR #92's merge (`f092981^1`, run in a checkout of `f092981^2`) prints tier 3 with the matching path, and on PR #99 (`038a3c6`) prints tier 0 or 1.

## 5. Env-var check

A script that compares env var names across `.env.example`, `compose.yaml` and `.github/workflows/*.yml`, wired into `pnpm check`. It exits non-zero on a name missing from any of them, and prints its counts.

Done when deleting one var from `compose.yaml` makes `pnpm check` fail and naming the var, and restoring it makes the check pass.

Report each part's done-when result. Add a skipped line only when a part was skipped.
