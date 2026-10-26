# Stack profiles

Per-project starting files. Copy a profile's contents into a new repo's root (`cp -R stacks/ts/. ~/Projects/<repo>/`), then fill in the `<placeholders>` and add the `check` script to `package.json`.

| | `static-site` (portfolio) | `ts` (job copilot) | `go` (schedule-matcher) |
|---|---|---|---|
| Checks | html-validate, prettier, Lighthouse CI | tsc, eslint or biome, vitest, prettier | gofmt, go vet, staticcheck, go test |
| Edit hook | prettier on file | prettier on file | gofmt on file |
| Stop gate | none | tsc + vitest if TS changed | build + vet + test if Go changed |
| TDD + 3-axis review | Standards only | full | full |
| KB | none | from the first commit | deferred |
| UI preview | Claude Design, then plain HTML | Storybook, plus Claude Design for new screens | `/_styleguide` dev route |
| CI + PR template + Claude Action | yes | yes | yes |

Each profile holds:

- `.claude/settings.json` and `.claude/hooks/`: the edit hook and the Stop gate.
- `CLAUDE.md`: the check command, how work flows, the UI preview route.
- `.github/`: CI, the Claude review workflow, and the PR template (Testing / Risk / How to revert).
- `ts` only: a seed `docs/kb/` bundle. Approve its Types table in the project's first grilling.

The Claude review workflow needs the repo secret `CLAUDE_CODE_OAUTH_TOKEN`, from `claude setup-token`.

`go/` is written in Session B from what schedule-matcher ends up using.
