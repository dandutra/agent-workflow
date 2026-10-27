# Agent workflow plan

Decided in a grilling session on 2026-10-25/26. This repo becomes `agent-workflow`: a public, versioned Claude Code setup (global CLAUDE.md, skills, agents, hooks, stack profiles) that symlinks into `~/.claude`.

## Ground rules

- **Filter:** anything adopted for interview value must earn its place on productivity within 2 weeks, or it is dropped. Every trial gets a row in `experiments.md`: hypothesis, metric, start date, verdict.
- **Setup is 3 sessions (A, B, C).** After that, trials run inside real portfolio work. There is no phase-by-phase analysis between sessions.
- **Target role:** full-stack first, then backend.

## Session A: this repo

### A1. Repo and install

- Rename the folder to `agent-workflow`, `git init`, and make the first commit this file.
- Layout:
  ```
  global/CLAUDE.md        → ~/.claude/CLAUDE.md
  skills/<name>/          → ~/.claude/skills/<name>
  agents/*.md             → ~/.claude/agents/
  hooks/*.sh
  stacks/go/  stacks/ts/  stacks/static-site/
  settings.fragment.json  (merged into ~/.claude/settings.json by install.sh with jq)
  experiments.md
  install.sh
  README.md               (credits Matt Pocock's skills, MIT)
  ```
- Do **not** symlink `settings.json`. Its `autoMode.environment` block names the private repo and sensitive paths, and it stays local.
- Add `.research/` to `.gitignore`. It holds third-party sources fetched during the grilling.

### A2. Skill cleanup

Skills currently live as symlinks `~/.claude/skills/<name> → ~/.agents/skills/<name>`. `unslop` and `unslop-comments` are real directories in `~/.claude/skills/`. `~/.claude/skills/synced/` holds claude.ai built-ins, so leave it alone.

- **Copy into `skills/`** (they diverge from upstream once edited):
  - Kept skills: `code-review` (renamed `review`), `diagnosing-bugs`, `grill-me`, `grilling`, `grill-with-docs`, `handoff`, `implement`, `retro`, `tdd`, `teach`, `wait-what`, `wayfinder`, `unslop`.
  - Their dependencies: `domain-modeling` (grill-with-docs, wayfinder), `codebase-design` (tdd), `writing-for-agents` (retro), `research` and `prototype` (wayfinder).
- **Delete** both the symlink and the `~/.agents/skills` target for: `ask-matt`, `claude-handoff`, `find-skills`, `git-guardrails-claude-code`, `implement-spec`, `improve-codebase-architecture`, `loop-me`, `migrate-to-shoehorn`, `scaffold-exercises`, `setup-pre-commit`, `setup-ts-deep-modules`, `to-questionnaire`, `to-spec`, `to-tickets`, `triage`, `wizard`, `writing-beats`, `writing-fragments`, `writing-shape`. Also delete `~/.claude/skills/unslop-comments`.
- **Keep `setup-matt-pocock-skills` until Session C**, which uses it to write `docs/agents/issue-tracker.md`.
- Remove the `mattpocock` entry from `extraKnownMarketplaces`. Once everything is copied, remove `~/.agents/skills`.

### A3. Global CLAUDE.md (target: under 60 lines)

- **Comments:** comment only the non-obvious why, never narrate what the code does. Gotchas go to the KB, with a one-line pointer in the code if needed.
- **Change scope** (from Ponytail):
  - before writing, list every place the change must reach (callers, tests, fixtures, config);
  - grep every caller before fixing a bug and fix the root cause once;
  - never cut validation at trust boundaries, data-loss error handling, security, or accessibility;
  - end task reports with one or two lines on what was skipped or not checked, and any risk.
- **unslop-lite:** about 12 rules taken from `skills/unslop`, chosen for reports and chat.
- **Skills:** when the user types a slash workflow, load that skill before doing anything else.
- **Environment:**
  - macOS: no `timeout` (use `gtimeout`); zsh globs fail when nothing matches; Unix socket paths have a length limit.
  - Multi-line or `$`-heavy remote commands go in a script file, never inline.
- **Data scripts:** a scan, backup or move that processes 0 items exits non-zero and prints its counts.
- **Git:** before describing a push, run `git fetch && git log --oneline origin/<branch>..HEAD` and report the exact commits. Confirm before every push.
- **Knowledge:** if the repo has `docs/kb/index.md`, read it first and use only the types it declares (see A6).
- **Memory policy:** auto-memory holds facts about the user only (preferences, feedback). Project status lives in Issues and the KB.

### A4. Settings fragment and hooks

- **Model and effort:** keep `model: opus`. Set `effortLevel: medium` (the model's default) on `claude-opus-5-5`, and drop the stale `claude-opus-5` key.
- **Context nudge** (decided over an auto-handoff hook, because a turn is not a task):
  - `statusline.sh` colors the ctx segment red at 150k tokens;
  - a UserPromptSubmit hook adds "context is over 150k: offer a handoff at the next natural break" once the transcript shows usage over 150k.
  - Claude decides when the task is done and offers `/handoff`.
- **unslop log:** a Stop command hook that never blocks. It runs regex over `last_assistant_message` for the regex-checkable rules (3, 7, 8, 9) and appends hits to `~/.claude/logs/unslop-hits.jsonl`. It becomes blocking only if the log shows a high tell rate after 2 weeks.
- **Push block:** a PreToolUse hook on Bash that denies `git push` targeting `main`/`master`.
- **Jev KB-capture** (needs TypeSafe API access, which the user is requesting):
  - an `async` Stop hook, active only where `docs/kb/index.md` exists;
  - it trims `last_assistant_message`, runs a local secret-scan regex, then asks Jev a Noul ("contains a decision, gotcha or rule worth keeping?") plus a Choice over the bundle's declared types;
  - when the score is ≥ 0.7, it appends the score, type and excerpt to gitignored `docs/kb/.inbox.md`;
  - it never writes concepts, and never touches `log.md`, which OKF reserves.
  - Metric: approval rate of inbox items. Below ~30% after 2 weeks, drop it.

### A5. Skill edits

- **`review`** (was `code-review`; renamed because it hid the bundled `/code-review`):
  - Three axes, each a parallel subagent:
    - **Standards:** repo docs, `REVIEW.md` and the Fowler smell baseline, on Sonnet.
    - **Spec:** the issue or ticket, on Sonnet.
    - **Correctness:** bugs, security and downstream effects, on Opus.
  - **Verify pass:** a fresh Opus agent checks each Important finding against the code, and false positives are dropped.
  - Tag findings Important / Nit / Pre-existing. Skip what tooling enforces. Start the report with a count of findings.
  - Run `/security-review` too when the diff touches auth, sessions, CSRF, uploads or migrations.
  - Replace the hard-coded `claude-sonnet-5` with the aliases `sonnet` and `opus`.
  - Read the tracker via `docs/agents/issue-tracker.md` (GitHub Issues).
- **`implement`:** frontmatter `model: sonnet`. TDD at the seams in the ticket. After `review`, fix every Important finding. At most 2 re-review rounds, each on the new diff only. Then commit.
- **`tdd`**, additions from superpowers:
  - show the red output, and confirm it fails for the expected reason;
  - before writing a test, name the production change that would make it fail;
  - run the full suite before "done" and report every failure by name, even one Claude didn't cause.
  - Read seams from the ticket's **Seams under test** section, and ask the user only if it is missing.
- **`diagnosing-bugs`:**
  - Phase 3: build hypotheses from `git log`/`git diff` on the area and from working code in the same codebase.
  - Phase 5: after 3 failed fixes, stop and question the architecture with the user.
  - Phase 6: blast-radius check. List what depends on the changed code or config and re-check it. A run that processed 0 items is a failure.
- **OKF-aware skills** (skills follow OKF, not the reverse):
  - `tdd`, `diagnosing-bugs` and `wait-what` read `docs/kb/index.md`, then the glossary it points to, and check `decision` concepts in the area being touched.
  - `domain-modeling` writes glossary terms and decisions as OKF concepts, using the bundle's declared types.
  - Nested `index.md` files replace `CONTEXT-MAP.md`.
  - With no KB, skip the glossary step.
- **`handoff`:** write to `~/.claude/handoffs/<project>/YYYY-MM-DD-<topic>.md` and print the path. Add a resume step: read the newest handoff for this project. Show `docs/kb/.inbox.md` and propose KB promotions.
- **`retro`:** propose KB promotions. A review comment made twice moves into `REVIEW.md`.

### A6. KB convention (OKF v0.2)

- A project's bundle is always at `docs/kb/`. The root `index.md` declares a **Types** table (name, meaning, when to use) and the glossary's path. Types are per project, never global.
- Follow the spec: YAML frontmatter with the required `type`; `title`, `description` and `tags` recommended; `status`, `stale_after`, `verified` and `sources` where they fit; plain markdown links only.
- Obsidian: open `docs/kb/` as a vault with "Use markdown links" on.
- The tracker holds work and the KB holds knowledge. When a ticket closes, its lasting lessons move into the KB in the same PR. Audit findings become issues, and audit conclusions become KB concepts.

### A7. Custom agents (`agents/`)

- `reviewer-standards` (Sonnet)
- `reviewer-spec` (Sonnet)
- `reviewer-correctness` (Opus)
- `verifier` (Opus)
- `kb-scout` (Haiku): read-only lookups in `docs/kb/`

### A8. Stack profiles

| | `static-site` (portfolio) | `ts` (job copilot) | `go` (schedule-matcher) |
|---|---|---|---|
| Checks | html-validate, prettier, Lighthouse CI | tsc, eslint or biome, vitest, prettier | gofmt, go vet, staticcheck, go test |
| Edit hook | prettier on file | prettier on file | gofmt on file |
| Stop gate | none | tsc + vitest if TS changed | build + vet + test if Go changed |
| TDD + 3-axis review | Standards only | full | full |
| KB | none | from the first commit | deferred |
| UI preview | Claude Design, then plain HTML | Storybook, plus Claude Design for new screens | `/_styleguide` dev route |
| CI + PR template + Claude Action | yes | yes | yes |

Session A writes `ts` and `static-site`. Session B writes `go` from what it builds.

### A9. Clean-up

- Delete stale project memories in `~/.claude/projects/-Users-danieldutra-Projects-schedule-matcher/memory/`, e.g. "tickets 053 + 054 open", since 053 shipped in `10308b0`. Keep the user and feedback ones.
- Write `~/Projects/first-home-server/QUIRKS.md` and link it from that repo's CLAUDE.md. Source: the insights report (`~/.claude/usage-data/report-2026-10-23-194146.html`): Windows 11 Pro in English, script files over `ssh -T`, `Scripting.Dictionary` is missing on Mac Excel, the clamscan 0-files case, and the downstream checks after ACL/qBittorrent changes.
- Create `experiments.md` with rows for:
  - Sonnet `implement`: 5-hour usage % per ticket vs Correctness findings;
  - unslop-lite: hit rate;
  - Ponytail lines: diff size on similar tickets;
  - context nudge;
  - Jev KB capture: approval rate;
  - overnight worktree run;
  - Storybook / Claude Design / `/_styleguide`;
  - Jev job classifier.

## Session B: schedule-matcher guardrails (maintenance mode)

- `.claude/settings.json`: gofmt hook after each edit, and the Stop gate (build/vet/test when Go changed).
- Add staticcheck to CLAUDE.md's "Every change" line and to CI.
- `.github/workflows/ci.yml`: build, vet, `gofmt -l`, staticcheck, test.
- `.github/pull_request_template.md`: Testing / Risk / How to revert.
- `REVIEW.md` at the repo root:
  - what failure looks like in this repo;
  - cap the nits;
  - paths to skip;
  - cite file:line as evidence;
  - start the summary with a count.
  - Link out to the gotchas files; don't copy them.
- Claude Code GitHub Action as the PR reviewer. The user runs `claude setup-token` and stores it as `CLAUDE_CODE_OAUTH_TOKEN`. It uses the existing subscription limits.
- Risk tiers by path, in CLAUDE.md or REVIEW.md. Low is docs, copy and CSS. High is `internal/db/migrations`, auth/session and `deploy/`, which the user reads line by line. An agent's approval never counts as a person's.
- No branch protection: the repo is private on GitHub Free. The push-block hook and discipline stand in for it.
- Copy the result into `stacks/go/`.

## Session C, reduced: work to Issues

- Run `setup-matt-pocock-skills` to write `docs/agents/issue-tracker.md` for GitHub Issues, then delete that skill.
- Move the open tickets (027, 029–035, 037, 040, 051, 054, 055) and the open `.scratch` audit findings to Issues with a `gh` script that keeps their bodies.
  - Labels: `ticket`, `audit:web`, `audit:store`, `ready`, `area:*`.
  - `**Blocked by:**` becomes GitHub's native issue dependencies.
  - No Projects board.
- Add an Issue form: Source, Blocked by, Touches, Read first, **Seams under test**, Acceptance.
- **Deferred until after the 3 projects:**
  - The OKF migration of schedule-matcher. Approve the types after the first folder (`database/`) is converted. Starting guess: `gotcha`, `decision`, `domain`, `runbook`, `audit`.
  - Retire `current-work.md` and add a short "how we work" section to CLAUDE.md. Closed tickets stay in git history.

## After setup

1. **Portfolio site:** plain HTML/CSS/JS on GitHub Pages, showing work only. Short grilling, `static-site` profile, Claude Design to preview the look. The `agent-workflow` repo goes in the portfolio.
2. **Job copilot:** a separate, long `/grill-with-docs` session. Mainstream TS stack, OKF KB from the first commit, Jev as the job classifier, Claude API for tailoring, form filling. Architecture is out of scope here.
3. **Overnight worktree run:** 2–3 independent tickets, one worktree each, ending in PRs. Nothing merges, and each ticket must list its seams first.
4. **After 2 weeks:** re-run `/insights` and compare it with the 2026-10-23 report (27 buggy-code and 13 wrong-approach frictions). Fill in the verdicts in `experiments.md`.

## Rejected, and why

- **Full plugins (superpowers, matt-pocock):** single skills, copied and edited, fit better.
- **`jev-router`:** a young third-party proxy that carries the subscription login through it. Switching models per message throws away the prompt cache, so it can use more of the limits, not less. Built-in routing (skill/subagent `model:`, effort) does the job.
- **`dispatching-parallel-agents`:** the harness already covers most of it.
- **Ponytail plugin:** its useful lines live in global CLAUDE.md. Its hooks only inject text, which is what CLAUDE.md already does.
- **Blocking auto-handoff hook:** Stop fires per turn, not per task.
- **Running vet and the tests after every edit:** too slow and noisy mid-change. That moved to the Stop gate.
- **Figma MCP:** skipped for now.
- **Merge queue, feature flags, staged releases, incident eval sets:** overkill for one developer with 31 beta accounts.

## User tasks

- Request TypeSafe API access.
- Turn on "Use markdown links" in Obsidian when opening a KB.
- Run `claude setup-token` during Session B.
