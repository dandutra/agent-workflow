# agent-workflow

My Claude Code setup, versioned: a global `CLAUDE.md`, skills, review agents, hooks and per-stack project profiles. `install.sh` symlinks it into `~/.claude`, so an edit here is live in the next session.

[PLAN.md](PLAN.md) records why each piece exists. [experiments.md](experiments.md) tracks each trial against a 2-week productivity bar; a trial that misses it is removed.

## Install

```sh
git clone https://github.com/dandutra/agent-workflow ~/Projects/agent-workflow
~/Projects/agent-workflow/install.sh
```

Needs `jq`. The script is safe to re-run. It moves anything it would replace into `~/.claude/backups/` and prints its counts.

| Repo | Installed as |
|---|---|
| `global/CLAUDE.md` | `~/.claude/CLAUDE.md` (symlink) |
| `skills/<name>/` | `~/.claude/skills/<name>` (symlink) |
| `agents/*.md` | `~/.claude/agents/` (symlinks) |
| `statusline.sh` | `~/.claude/statusline.sh` (symlink) |
| `settings.fragment.json` | merged into `~/.claude/settings.json` with `jq` |
| `hooks/*.sh` | run in place, by path, from the merged settings |

`settings.json` is merged, never symlinked. It holds machine-private config that stays out of git.

## What's here

**Skills.** The ones I run most:

- `/review`: three parallel reviewers (Standards and Spec on Sonnet, Correctness on Opus), then an Opus verifier that drops false positives. The report opens with a count of findings tagged Important, Nit or Pre-existing.
- `/implement`: runs on Sonnet. It builds a ticket test-first at the ticket's seams, fixes every Important finding from `/review`, and allows at most two re-review rounds.
- `/tdd` and `/diagnosing-bugs`: test-first and debugging loops, with extra rules from superpowers. Show the red output, name the break a test catches, stop after 3 failed fixes, and check the blast radius before calling a fix done.
- `/handoff`: writes a handoff to `~/.claude/handoffs/<project>/` and resumes from the newest one.
- `domain-modeling`: writes glossary terms and decisions into a project's knowledge base. Its [KB-FORMAT.md](skills/domain-modeling/KB-FORMAT.md) is the convention every project's `docs/kb/` follows (OKF v0.2).

**Agents.** `reviewer-standards`, `reviewer-spec`, `reviewer-correctness` and `verifier` are what `/review` dispatches. `kb-scout` runs read-only lookups in a project's KB, on Haiku.

**Hooks.**

| Hook | Event | What it does |
|---|---|---|
| `context-nudge.sh` | UserPromptSubmit | Once the transcript passes 150k tokens, tells Claude to offer a `/handoff` at the next break. The statusline's ctx segment turns red at the same point |
| `block-push-main.sh` | PreToolUse (Bash) | Denies `git push` to `main` or `master` |
| `unslop-log.sh` | Stop | Logs AI-writing tells in Claude's replies to `~/.claude/logs/unslop-hits.jsonl`. It never blocks |
| `kb-capture.sh` | Stop (async) | Asks Jev whether a reply holds a decision or gotcha worth keeping, and appends hits to the project's gitignored `docs/kb/.inbox.md`. Off until `JEV_API_URL` and `JEV_API_KEY` are set |

**Stack profiles.** [stacks/](stacks/README.md) holds starting files for new projects: the edit hook, the Stop gate, CI, a PR template and the Claude review workflow, for `ts` and `static-site`. `go` is next.

## Credits

- Most skills started as copies of [Matt Pocock's skills](https://github.com/mattpocock/skills) (MIT, [license](licenses/mattpocock-skills.LICENSE)) and have since been edited.
- Rules in `tdd`, `diagnosing-bugs` and `/review` are adapted from [superpowers](https://github.com/obra/superpowers) by Jesse Vincent (MIT) and from Anthropic's code-review plugin for Claude Code.
- The change-scope rules in `global/CLAUDE.md` come from the Ponytail skill (MIT).

## License

MIT. See [LICENSE](LICENSE).
