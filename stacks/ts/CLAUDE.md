# <Project>

<One line: what this is and who uses it.>

## Every change

`npm run check` runs prettier --check, eslint (or biome), tsc and vitest. CI runs the same command. Run it before calling a change done.

## How we work

- Work lives in GitHub Issues (`docs/agents/issue-tracker.md`). Each issue lists **Seams under test**; `/tdd` tests there.
- `/implement` builds a ticket, then `/review` runs all three axes (Standards, Spec, Correctness).
- Knowledge lives in `docs/kb/`. Read `docs/kb/index.md` before changing code. When a ticket closes, its lasting lessons move into the KB in the same PR.

## UI

Components get a Storybook story. New screens start as a Claude Design mock, then become components with stories.
