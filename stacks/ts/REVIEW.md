# REVIEW.md

How to review a pull request in this repo, for a person or an agent. [CLAUDE.md](CLAUDE.md) holds the build rules.

An agent's approval never counts as a person's. The agent posts findings, and the owner decides.

## Risk tiers

`/review` runs `tier.sh`, which reads the globs below. A critical path forces tier 3, and a diff made only of low paths is tier 0. The tier table is in the `review` skill. `*` spans directories.

```review-tiers
critical:
  - <prisma/migrations/*>
  - <src/auth/*>
  - <deploy/*>
low:
  - <src/*.css>
```

On a critical path the owner reads every line. Name each changed critical file in the summary.

## What failure looks like here

Each of these has cost real debugging time. Link the gotchas file that has the detail, so the reviewer cites it rather than a copy.

- **<Failure class>.** <What goes wrong, where to look, and the gotchas file that explains it.>
- **A missed authorization check.** A handler serves or changes a resource without checking who owns it or belongs to it.
- **Untested behaviour.** A behaviour change with no test, or a test that would pass without the change.

## Skip

- Whatever CI already checks: build, typecheck, lint, format, tests passing.
- lockfiles, generated clients and OpenAPI output, images and fonts.
- Style preferences the surrounding code doesn't share.

## Findings

- Tag each finding **Important**, **Nit** or **Pre-existing**. Important means it breaks behaviour, data, security or a rule above. Pre-existing means the diff didn't cause it.
- Cite `file:line` for each finding, and quote the line or name the gotcha that backs it.
- Post at most 5 Nits. Drop the weakest beyond that.
- Start the summary with the count, for example "2 Important, 1 Nit, 0 Pre-existing", then the tier.

A review is done when every changed file has been read and every finding has a `file:line`.
