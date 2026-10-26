# Experiments

Every trial earns its place on productivity within 2 weeks of its start date, or it is dropped. Fill in the verdict at the 2-week mark; the 2026-11-09 `/insights` run is the comparison point against the 2026-10-23 report (27 buggy-code and 13 wrong-approach frictions).

| Trial | Hypothesis | Metric | Start | Verdict |
|---|---|---|---|---|
| Sonnet `implement` | Implementing on Sonnet with an Opus Correctness reviewer uses less of the 5-hour window without letting more bugs through | 5-hour usage % per ticket, against Correctness findings per ticket | 2026-10-26 | |
| unslop-lite | 12 rules in global CLAUDE.md cut the AI tells in reports and chat | Stop-hook hit rate in `~/.claude/logs/unslop-hits.jsonl` (hits per 1,000 words). If it stays high, make the hook blocking | 2026-10-26 | |
| Ponytail lines | The change-scope rules in global CLAUDE.md produce smaller, complete diffs | Diff size on similar tickets, before vs after, and Spec findings for missing callers or tests | 2026-10-26 | |
| Context nudge | A red statusline and one nudge at 150k lead to handoffs at task boundaries instead of late compaction | Sessions that pass 150k and end in a `/handoff`, against sessions that hit auto-compaction | 2026-10-26 | |
| Jev KB capture | An async Stop hook finds KB-worthy decisions and gotchas the user would otherwise lose | Approval rate of `.inbox.md` items. Below about 30% after 2 weeks, drop it | not started (waiting on TypeSafe API access) | |
| Overnight worktree run | 2–3 independent tickets, one worktree each, can run unattended and end in reviewable PRs | PRs opened, Important findings per PR, and the user's time to merge-ready | not started (after setup) | |
| UI preview routes | A preview surface per stack (Claude Design + plain HTML, Storybook, `/_styleguide`) catches UI problems before review | UI fixes requested after a PR opens, per project | not started (portfolio site first) | |
| Jev job classifier | Jev classifies job postings for the job copilot well enough to replace hand triage | Agreement with the user's own labels on a held-out sample | not started (job copilot) | |
