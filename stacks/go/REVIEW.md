# REVIEW.md

How to review a pull request in this repo, for a person or an agent. [CLAUDE.md](CLAUDE.md) holds the build rules.

An agent's approval never counts as a person's. The agent posts findings, and the owner decides.

## Risk tiers

Set the tier from the paths the diff touches. The highest tier wins.

| Tier | Paths | Review depth |
|---|---|---|
| High | <migrations, auth and sessions, middleware, deploy config> | The owner reads every line. Name each changed high-tier file in the summary. |
| Low | `docs/`, `*.md`, <stylesheets>, text-only changes to <templates> | Read for correctness of the text or style. |
| Normal | Everything else | Full review. |

## What failure looks like here

Each of these has cost real debugging time. Link the gotchas file that has the detail, so the reviewer cites it rather than a copy.

- **<Failure class>.** <What goes wrong, where to look, and the gotchas file that explains it.>
- **A missed authorization check.** A handler serves or changes a resource without checking who owns it or belongs to it.
- **Untested behaviour.** A behaviour change with no test, or a test that would pass without the change.

## Skip

- Whatever CI already checks: build, `go vet`, `gofmt`, staticcheck, tests passing.
- `go.sum`, vendored files, images and fonts.
- Style preferences the surrounding code doesn't share.

## Findings

- Tag each finding **Important**, **Nit** or **Pre-existing**. Important means it breaks behaviour, data, security or a rule above. Pre-existing means the diff didn't cause it.
- Cite `file:line` for each finding, and quote the line or name the gotcha that backs it.
- Post at most 5 Nits. Drop the weakest beyond that.
- Start the summary with the count, for example "2 Important, 1 Nit, 0 Pre-existing", then the tier.

A review is done when every changed file has been read and every finding has a `file:line`.
