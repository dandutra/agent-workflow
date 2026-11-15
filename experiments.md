# Experiments

Every trial earns its place on productivity within 2 weeks of its start date, or it is dropped. Fill in the verdict at the 2-week mark; the 2026-11-09 `/insights` run is the comparison point against the 2026-10-23 report (27 buggy-code and 13 wrong-approach frictions).

| Trial | Hypothesis | Metric | Start | Verdict |
|---|---|---|---|---|
| Sonnet `implement` | Implementing on Sonnet with an Opus Correctness reviewer uses less of the 5-hour window without letting more bugs through | 5-hour usage % per ticket, against Correctness findings per ticket | 2026-10-26 | Kept, replaced by `/ship` (2026-11-14). Sonnet wrote 1.63M output tokens of implementation, but the skill's model lasted one turn, so 2.05M Opus tokens went to follow-up turns. |
| unslop-lite | 12 rules in global CLAUDE.md cut the AI tells in reports and chat | Stop-hook hit rate in `~/.claude/logs/unslop-hits.jsonl` (hits per 1,000 words). If it stays high, make the hook blocking | 2026-10-26 | Kept (2026-11-14). 0 hits in 206k words after, against 0.06 per 1,000 words before. Rule 28 rewritten as connected prose. |
| Ponytail lines | The change-scope rules in global CLAUDE.md produce smaller, complete diffs | Diff size on similar tickets, before vs after, and Spec findings for missing callers or tests | 2026-10-26 | Not measured. Folded into the 2026-11-14 Change scope section. |
| Context nudge | A red statusline and one nudge at 150k lead to handoffs at task boundaries instead of late compaction | Sessions that pass 150k and end in a `/handoff`, against sessions that hit auto-compaction | 2026-10-26 | Not measured. Idle compaction turned off 2026-11-14, so only auto-compaction remains to compare. |
| Jev KB capture | An async Stop hook finds KB-worthy decisions and gotchas the user would otherwise lose | Approval rate of `.inbox.md` items. Below about 30% after 2 weeks, drop it | not started (waiting on TypeSafe API access) | |
| Overnight worktree run | 2–3 independent tickets, one worktree each, can run unattended and end in reviewable PRs | PRs opened, Important findings per PR, and the user's time to merge-ready | not started (after setup) | |
| UI preview routes | A preview surface per stack (Claude Design + plain HTML, Storybook, `/_styleguide`) catches UI problems before review | UI fixes requested after a PR opens, per project | not started (portfolio site first) | |
| Jev job classifier | Jev classifies job postings for the job copilot well enough to replace hand triage | Agreement with the user's own labels on a held-out sample | not started (job copilot) | |
| Review tiers | `tier.sh` tiers cut review tokens on small tickets without more bugs reaching main | Reviewer output tokens per PR (`usage-trend.py`), and post-merge fixes per PR. The replay evals must still pass | 2026-11-14 | |
| `/ship` on Sonnet | A session started on Sonnet keeps follow-up turns off Opus with no rise in Important findings | Opus main-loop output tokens in ship sessions (target near 0), Important findings per ticket | 2026-11-14 | |
| Sonnet KB writing | `kb-writer` and `/ship` move gotcha and runbook authorship to Sonnet | Share of `docs/kb/` gotcha and runbook lines with a Sonnet trailer, re-run after 10 tickets (was 351 of 517 gotcha lines) | 2026-11-14 | |
| Risks at planning | Risks and checks, Live check and Review tier on the ticket move risks from PR caveats to the plan | Deviations per PR, and hotfixes after merge | 2026-11-14 | |
| Report caveats | The Reports rule cuts closing caveats to the cases with a skipped step or a new risk | Share of 60+ word replies ending in a caveat line (was 21%, 5% before the old rule) | 2026-11-14 | |
| Effort by role | `effort: high` on Correctness and the verifier, and `/effort high` for planning, recover the depth of the 10-26 week | Thinking tokens per reviewer message, and Important findings confirmed by the verifier | 2026-11-14 | |
| Weekly retro | `/retro weekly` turns repeated frictions into checks and rules | Changes adopted per run, and repeats of an adopted class afterwards | not started (first run 2026-11-21) | |
