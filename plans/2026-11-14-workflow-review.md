# Workflow review, 2026-11-14

Answers to the nine questions from the 2026-11-14 session, with the evidence behind each, then one ordered implementation plan. Nothing here is applied yet. Mark each proposal **yes / no / change** and the implementation session works from your marks.

Sources:

- The 2026-11-14 `/insights` report and its per-session `facets/` and `session-meta/`.
- 116 transcripts under `~/.claude/projects/` (13,264 assistant messages, which carry model, effort and thinking tokens).
- `git blame` and `gh pr list` on job-hunting-copilot.
- The Claude Code best-practices and model-config docs.

**Your marks (2026-11-14).** Yes: 1a, 1b, 2, 3, 4, 5, 6a, 6b, 6c, 7a, 7b, 7c, 8a, 8b, 8c, 9. No: 6d (rules 3, 7, 8, 9 stay in CLAUDE.md), 6e. Item 9 decision: invoking `/ship N` counts as push confirmation for the ticket branch. Item 4 adds job-copilot `CLAUDE.md` and `REVIEW.md`, written in a session opened in that repo.

The mining scripts are in the session scratchpad. Step 1 of the plan turns them into `scripts/usage-trend.py`, so these numbers can be re-run.

---

## 1. Did Opus get worse after the Fable launch?

The local data shows no decline. Fable 5.2 launched on 2026-11-09 ([9to5Mac](https://9to5mac.com/2026/11/09/anthropic-upgrades-claude-with-new-fable-5-2-model-details-here/)). The week that started that day looks like the week before it:

| Week of | Sessions | Fully achieved | Dissatisfied | Wrong approach | Buggy code (caught by review) |
|---|---|---|---|---|---|
| 10-12 | 13 | 7 (54%) | 6 | 5 | 8 (1) |
| 10-19 | 8 | 3 (38%) | 0 | 3 | 10 (0) |
| 11-02 | 28 | 19 (68%) | 3 | 8 | 16 (7) |
| 11-09 (Fable launch) | 22 | 14 (64%) | 3 | 4 | 22 (11) |

- Review rounds per ticket did not grow. Correctness-reviewer dispatches per `/implement` session were 2 to 3 in the first week (11-02 to 11-04) and 2 to 3 in the last (11-11).
- Buggy code per session went up, but half of the 11-09 week's cases are bugs the review caught before you saw them. That category grows with review volume and does not mean worse code.

I can't see server-side changes, so I can't rule one out. What did change on your machine is effort:

| Main-loop model and effort | Messages | Thinking tokens per message |
|---|---|---|
| Opus 5.5, high (10-26 to 11-02 only) | 1,299 | 577 |
| Opus 5.5, medium (every other day) | 6,878 | 269 |
| Sonnet 5.5, medium | 1,551 | 322 |

The job-copilot planning sessions (`/grill-with-docs` and the first `/wayfinder` runs, 10-29 to 11-02) ran at `high`. From 11-02 on, everything ran at `medium`, the Opus 5.5 default. The sessions that felt best and the sessions that felt worse differ by effort, not by model version. Two other local changes also altered how replies read. The caveat rule (item 6) quadrupled closing caveats. The review loop ran on every ticket regardless of size (item 3).

**Proposals**

- 1a. Set effort by the kind of work instead of one global level.
  - `effort: high` goes in the frontmatter of the `reviewer-correctness` and `verifier` agents. Agent effort lasts for the whole subagent run.
  - Planning sessions start with `/effort high`. A skill's `effort:` only lasts until the end of its turn, and grilling spans many turns, so frontmatter on `grilling` or `wayfinder` would not hold.
  - Implementation stays at `medium`.
- 1b. Add `scripts/usage-trend.py`, which prints the two tables above per week. Run it before deciding that a model got worse.

---

## 2. Merging the pasted CLAUDE.md into ours

| Pasted section | Verdict | Why |
|---|---|---|
| Tradeoff preamble, "working if" footer | Drop | Neither changes behaviour. |
| Think before coding | Adapt | "If uncertain, ask" stalls a delegated `/ship` run. Ask in a conversation. In a delegated run, pick the reading the ticket supports and record it under Decisions in the PR. |
| Simplicity first | Adopt, shortened | Our file has no rule against speculative code. "No error handling for impossible scenarios" gets our trust-boundary line as its limit. |
| Surgical changes | Adopt, merged into Change scope | Ours says reach every place, theirs says touch nothing else. Together they define the right diff. The orphan-cleanup rule is new. |
| Goal-driven execution | One line | `tdd` and the Stop gate already make it concrete. The best-practices docs list "loop until done" prompting as advice current models no longer need. |

Proposed `global/CLAUDE.md` (items 5 and 6 are folded in; Environment, Data scripts, Git and Knowledge are unchanged and left out here):

```markdown
# Global instructions

## Before coding

- Name your assumptions. In a conversation, ask when two readings of the request lead to different code. In a delegated run (/ship, a ticket), take the reading the ticket supports, carry on, and list it under Decisions in the PR.
- When a simpler approach than the requested one exists, say so before building.
- Turn the task into a check that goes red, then green, before calling it done.

## Change scope

- Before writing, list every place the change must reach: callers, tests, fixtures, config, env vars, exports. Reach all of them and touch nothing else.
- Every changed line traces to the request. Match the surrounding style. Mention unrelated dead code or smells; leave them in place.
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
(see item 6)
```

At about 50 lines with the unchanged sections, it stays under the 60-line target.

---

## 3. Review tiers

The problem is misallocation more than overuse. Every ticket got the same three axes plus the verifier, whatever its size or risk:

- In `/implement` sessions, the Opus Correctness reviewer and verifier wrote 1.67M output tokens. Sonnet wrote 1.63M implementing the same tickets, so review cost more than the code.
- #99 (+20/−3, CI install) and #100 (+279, web shell) went through the same pipeline as #88 (+3,207, the tailoring API with the Trace check).
- On the riskiest tickets the two-round cap cut review short. #57 (tailoring API) and #73 (Workday adapter) both shipped a last fix nobody reviewed. #73's open Important finding reached production and needed hotfix #93.
- Anthropic's best-practices page warns: "A reviewer that's asked to find problems will always find *something*. If you fix every finding, you end up with extra abstraction layers and tests for cases that can't happen."

**Proposed tiers**

| Tier | When | Review |
|---|---|---|
| 0 | Docs, KB, comments, copy, version pins, CI tweaks with no logic | CI only |
| 1 | Low-risk paths, under ~300 non-test lines, seams covered by tests | One Sonnet reviewer for spec and correctness together, no verifier, one re-review at most |
| 2 | Default for feature work | Correctness (Opus, high effort) and Spec (Sonnet). Standards runs only when the repo has `REVIEW.md` or a standards doc. The verifier runs only when Important findings exist. Two re-review rounds. |
| 3 | Critical paths (below), or two tier-2 signals together | All three axes, the verifier, and `/security-review` where it applies. Re-review until clean, and after 3 rounds stop and ask you. Ends with a decision brief, and you read the diff. |

**How the tier is picked.** I recommend a new step 0 inside `/review` backed by `skills/review/tier.sh`, not a separate skill. The only caller would be `/review`, and a separate model-invoked skill adds a description to every session. The script reports a tier and the signals behind it:

1. A path risk map. Each repo's `REVIEW.md` lists `critical:` and `low:` globs. For job-copilot, critical means auth and the tailnet guard, Prisma migrations, matching and merges, anything that closes or deletes Postings or Sightings, the Trace check and tailoring gate, backups, and deploy and Terraform.
2. Fan-in. Changed exported symbols with many importers raise the tier by one.
3. Seam coverage. A changed module with no test at its seam, in this diff or already on main, raises the tier by one. A module that talks to an external API and is tested only through fakes does not get more review. It gets a required live check (item 9) instead, because review did not catch the Workday bugs and the live run did.
4. Size. More than ~800 non-test lines raises the tier by one.
5. The ticket's declared tier, set during planning (item 6), is a floor. When the computed tier is higher, the report says so.

You can override it with `/review tier=1`.

**Job-copilot PRs, re-tiered for illustration**

| Tier | PRs |
|---|---|
| 0 | #48, #99 |
| 1 | #79, #80, #89, #94, #100, #104 |
| 2 | #45, #51, #53, #54, #55, #56, #87, #90, #96, #98, #102, #103 |
| 3 | #46, #52, #81, #84, #85, #86, #88, #91, #92, #93, #95, #97, #101 |

---

## 4. Self-improvement for agents and workflows

**What Anthropic recommends** ([best practices](https://code.claude.com/docs/en/best-practices)):

- Put "anything you've had to correct twice already" in CLAUDE.md, and keep the file short.
- A line Claude keeps missing belongs in a hook, not under more emphasis.
- Use path-scoped `.claude/rules/` for rules that matter in one area of the code.
- Use skills for procedures.
- Run `/doctor prompt-audit` to find stale or contradictory instructions.
- Give Claude a pass/fail check, and use a fresh reviewer.

**What the community does.** Every's [compound engineering](https://every.to/guides/compound-engineering) loop is Plan, Work, Review, Compound: every bug or review comment becomes a rule the agent reads next time.

**Where job-copilot stands**

- The KB side compounds well: 23 gotcha files, most written in the same PR as the fix.
- The process side does not compound. `/retro` ran zero times. The repo has no `CLAUDE.md`, no `REVIEW.md` and no `.claude/rules/`.
- The same failure classes repeat across tickets:

| Repeated failure | Tickets | Fix, cheapest first |
|---|---|---|
| A new env var or secret missing from CI, deploy or Compose | #35, #37, #38 | A check script that compares env names across `.env.example`, `compose.yaml` and the workflows, run in `pnpm check` |
| A sed or Python bulk edit corrupting code or skipping files | #26, #37, #63, #72 | The global Edit-tool line (item 2) |
| Fakes passing while the live API differs | #29, #72, #73 | A Live check field on the ticket, and a `/ship` step |
| A fix introducing a new Important bug | #24, #57, #58, #71 | Tier 3 has no round cap, and fixes are built test-first |
| A review agent running tests on the shared test DB | #31 | Reviewer agents are read-only and run no test suites |

**Proposed loop**

1. Capture. `/ship` tags each Important finding *one-off* or *repeatable*. Repeatable ones go to `docs/kb/.inbox.md`.
2. Compound, weekly. `/retro` learns to read the project's `facets/` and `session-meta/` from the latest `/insights` run plus the inbox, and to cluster repeats. It proposes fixes in this order: an automated check, then a `.claude/rules/` file, then a `REVIEW.md` line, then a KB gotcha, then a CLAUDE.md line. You approve each one.
3. Measure. Every adopted change gets an `experiments.md` row with a metric from `usage-trend.py`. The existing two-week rule removes a change that shows no effect.
4. Prune, monthly. Run `/doctor prompt-audit` on the global CLAUDE.md and the skills.
5. Replay evals for the review pipeline. Keep 3 to 5 past first-draft diffs with known bugs, for example #57's lost Tailored resumes and #73's early-ending paging walk. A changed `/review` or tier rubric must still catch them before it is trusted. Run them with `claude -p`, or with `claude plugin eval` if it fits. I have not tried the latter yet.

---

## 5. Comments

The new rule is in item 2. It allows multi-line whys and short doc comments on public interfaces, and it is phrased positively, because a ban ("never narrate") keeps the banned behaviour in front of the model. The KB pointer for long gotchas stays.

---

## 6. Unslop, caveats, and risks found late

**How unslop is used today**

- It reaches every project through the 12 unslop-lite lines in the global CLAUDE.md. The model loaded the `unslop` skill 17 times, and the portfolio spec cites it. No repo overrides it.
- Since 10-27 there were zero regex hits across 779 final replies (178,322 words) and zero em dashes. The rules are followed completely.
- Because the hook writes nothing on a zero-hit reply, `~/.claude/logs/unslop-hits.jsonl` never existed. A silent zero breaks your own data-scripts rule. I tested the hook with a fake message to confirm it works, then deleted the test line.

**Why replies read worse.** Two causes show in the data:

- The caveat rule. "End every task report with what you skipped and any risk" went live on 10-26. Replies of 60+ words that end in a skipped/risk/caveat line went from 5% (9 of 189) before it to 21% (114 of 556) after. The rule produces the caveats, not the model.
- Choppy prose. Rule 28 (one idea per sentence), together with no em dashes and few colons, gives a median of 13 words per sentence. Each sentence is clean, but the links between ideas are cut, so a paragraph reads as a list of facts.

**Risks found too late.** I agree, and the job-copilot sessions support it. The ticket form has Source, Touches, Seams and Acceptance, but no place for risks. The risks that surfaced late were all predictable at planning time:

- the live Workday behaviour (#73)
- a new env var missing from deploy (#37, #38)
- the B2 endpoint var (#35)
- the shared test DB (#31)

**Proposals**

- 6a. Replace the closing rule with the Reports section in item 2: caveats only when something was skipped or a risk is new.
- 6b. Add a **Risks and checks** field to the ticket form, filled by `/wayfinder` and grilling when a ticket is written. Each risk gets the test, live check or manual step that handles it, plus the review tier. `/ship` then reports only *Deviations*: risks the ticket did not list.
- 6c. Replace rule 28 with "Write connected prose: join related clauses with *because*, *so*, *which*. A paragraph makes one point." Keep 13 (em dashes), 16, 20/21, 23, 24 and 27.
- 6d. Trial: take rules 3, 7, 8 and 9 out of CLAUDE.md for two weeks, and let the hook watch. They are regex-checkable and at zero hits. Before the rules existed (all replies before 10-26, 63,050 words) the same regexes found 3 hits, about 0.05 per 1,000 words, so the model rarely used these patterns even without the rules. Put the rules back if hits pass 0.15 per 1,000 words, three times that baseline. That frees 4 lines of always-loaded context.
- 6e. Dropped.

---

## 7. Where Sonnet could have replaced Opus in job-copilot

You did not use Opus for everything. `/implement` already pins Sonnet, and Sonnet wrote 1.63M output tokens of implementation. The leak was elsewhere:

| Work in `/implement` sessions | Model | Output tokens | Could be Sonnet? |
|---|---|---|---|
| Implementation (`/implement`, `/tdd`, `/review` turns) | Sonnet | 1.63M | Already is |
| Turns after the skill's turn ended (fix rounds, KB edits, push, PR text, follow-up questions) | Opus | 2.05M | Yes, almost all of it |
| Correctness reviewer and verifier | Opus | 1.67M | Yes on tiers 0 and 1, which is 8 of the 34 merged PRs |
| Research subagents (`/wayfinder` research tickets) | Opus, inherited | 0.57M | Yes, reading and summarizing |
| Spec and Standards reviewers | Sonnet | 0.36M | Already is |

The 2.05M is a mechanism, not a choice. A skill's `model:` lasts only until its turn ends. In 31 of 34 sessions the switch back to Opus happened on your next message ("push it and open a PR", "fix the remaining finding"). The other 3 happened when a background `pnpm check` notification opened a new turn.

PRs that could have run on Sonnet end to end, review included, are the tier 0 and 1 rows in item 3: #48, #79, #80, #89, #94, #99, #100 and #104. Opus earned its cost in two places: the planning sessions (grill and wayfinder), and the Correctness review on the tier 3 PRs.

**Proposals**

- 7a. Start ship sessions on Sonnet. A shell function `ship() { claude --model sonnet "/ship $1"; }` keeps every turn on Sonnet, including your follow-ups. Agents with a pinned `model:` (Correctness, verifier) stay on Opus.
- 7b. Research subagents: `/wayfinder` step 5 passes `model: sonnet`.
- 7c. Tier 1 review runs entirely on Sonnet (item 3).

---

## 8. Who wrote the job-copilot KB

Surviving lines in `docs/kb/`, credited to the model in the `Co-Authored-By` trailer of the commit that last touched each line:

| Folder | Opus | Sonnet |
|---|---|---|
| decisions | 283 | 0 |
| gotchas | 166 | 351 |
| runbooks | 120 | 188 |
| job-sources | 20 | 71 |
| index and glossary | 187 | 26 |
| **Total** | **776 (55%)** | **636 (45%)** |

Opus also made 104 of the 133 commits that touched the KB.

The trailer names the model of the turn that committed, which is not always the model that drafted the text. Most Opus gotcha and runbook lines come from the turn leak in item 7, so fixing 7a moves them to Sonnet with no other change.

I disagree with part of the premise. A decision file is the written result of an Opus grilling session. The reasoning is the expensive part, and the session that did it writes the file cheaply and accurately. Moving that writing to Sonnet saves little and risks losing nuance. The index and glossary upkeep is where Opus is wasted.

**Proposals**

- 8a. Fix 7a. This alone should move gotchas, runbooks and job-sources to about 100% Sonnet.
- 8b. Add a `kb-writer` agent (Sonnet, with Read, Edit and Write limited to `docs/kb/` by its prompt). `/ship` uses it for the gotcha and index updates. `domain-modeling` uses it for index and glossary lines.
- 8c. Decisions stay with the session that made them.
- Measure: re-run the blame count after 10 tickets.

---

## 9. `/ship`

It replaces `/implement`, so there aren't two overlapping skills. It is user-invoked (`disable-model-invocation: true`) and runs on Sonnet through the 7a function.

1. **Preflight.** Run `gh issue view N`. If a blocker is still open, stop and report it. Read Risks and checks and the Review tier. Branch `ticket-N-<slug>` from a freshly fetched `main`.
2. **Build.** Use `/tdd` at the ticket's seams. Run typecheck and single test files while working. Run the repo's full check once, with nothing else using the test DB.
3. **Live check.** Run each live check the ticket lists (dev API, real endpoint, real screen), and record the command and what came back. When the ticket lists none and the code calls an external API, say so in the PR.
4. **Review.** Run `/review` at the tier. Fix Important findings test-first and re-review by the tier's rules.
5. **KB.** `kb-writer` moves lasting lessons into `docs/kb/` on the branch. Repeatable findings go to `.inbox.md`.
6. **Push and PR.** Show `git log origin/main..HEAD`, push, and open the PR. The body has these sections:
   - Summary
   - Decisions: non-obvious choices, rejected alternatives, KB decisions touched. This is the pre-merge brief the insights report asked for.
   - Verification: tests, and whether the live check ran
   - Deviations: risks the ticket did not list
   - Review: tier and finding counts

Repo-specific facts, such as the check command, the test DB rule and live-check commands, go in a short job-copilot `CLAUDE.md` that the stack profile can seed, not in the skill.

**Push confirmation (decided).** Invoking `/ship N` counts as push confirmation for the ticket branch only. The skill says so in its own text, and the global Git rule gets the exception: "Confirm with the user before every `git push`, except a ticket branch pushed by `/ship`." The push-to-main hook still blocks `main`.

**Later.** The overnight worktree run in `experiments.md` is `/ship` run in parallel, one worktree and one test database per ticket. That waits until `/ship` has a week of clean runs.

---

## Implementation order

Each step ends on a check.

| # | Step | Done when |
|---|---|---|
| 1 | `scripts/usage-trend.py` from the scratchpad scripts | It prints the item 1 tables for any date range |
| 2 | ~~Hook: log every reply (6e)~~ Dropped | |
| 3 | Global CLAUDE.md rewrite (items 2, 5, 6a, 6c, 6d), via `writing-for-agents` | `/doctor prompt-audit` reports no contradictions, and the file is under 60 lines |
| 4 | Agent frontmatter: `effort: high` on Correctness and verifier; read-only rule on all reviewers | A test `/review` shows the effort in the transcript |
| 5 | `/review` step 0, `tier.sh`, `REVIEW.md` template in `stacks/ts` | The script assigns the item 3 tiers to five sample PRs |
| 6 | Review replay evals (#57, #73 first drafts) | The tier 3 review catches both known bugs |
| 7 | Ticket form: Risks and checks, Live check, Review tier; `/wayfinder` fills them | One new job-copilot ticket written with them |
| 8 | `kb-writer` agent; `/ship` replaces `/implement`; the `ship()` function | One real ticket shipped. The transcript shows Sonnet on every main-loop turn. |
| 9 | job-copilot `CLAUDE.md`, `REVIEW.md`, env-var check script, in a session opened in that repo | `pnpm check` fails on a missing env var. `REVIEW.md` holds the tier-3 path map that `tier.sh` reads. |
| 10 | `/retro` reads facets and the inbox | One weekly run proposes at least one change |
| 11 | `experiments.md`: fill the overdue verdicts (they were due 11-09) and add rows for tiers, `/ship`, 6d and 8a | Every row has a start date and a metric |

**Status, 2026-11-14 (branch `workflow-review`).**

- Done here: 1, 3, 4, 5, 7 (wayfinder and the stack ticket form), 8 (files and `install.sh`), 10, 11.
- Built, not run: 6. `scripts/review-eval.sh` costs about two tier-3 reviews.
- Waiting on you: 3's `/doctor prompt-audit`, 4's test `/review`, 8's first real `ship <n>`, and sourcing `shell/ship.zsh` from `~/.zshrc`.
- Waiting on the job-copilot session: 9, and copying the three new ticket fields into that repo's `ticket.yml`.
- `tier.sh` on six past PRs: #99 and #80 tier 1, #88, #92, #98 and #104 tier 3. Item 3's table was hand-tiered and put #99 at 0, #98 at 2 and #104 at 1. The script follows the stated rules: CI files are not on the default low list, #98 touches a migration, and #104 is 358 lines with no test naming `LabelScreen`.
- The global CLAUDE.md is 66 lines, not under 60, because 6d was declined.

---

## Skipped, and risks

- I did not count review findings per PR, so the "review cost more than the code" claim rests on token counts, not on findings per token.
- The quality numbers in item 1 are the `/insights` model's own estimates.
- I have not checked whether a forked skill (`context: fork`) can dispatch the reviewer subagents. That uncertainty is why 7a uses a session-level `--model sonnet` instead of `context: fork`.
