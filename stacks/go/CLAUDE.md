# <Project>

<One line: what this is and who uses it.>

## Every change

```bash
go build -o /dev/null ./... && go vet ./... && gofmt -l . && staticcheck ./... && go test ./...
```

All five pass before a change is done, with `gofmt -l .` printing nothing. CI runs the same five on every PR. staticcheck lives in `~/go/bin` (`go install honnef.co/go/tools/cmd/staticcheck@2026.2.2`, the version CI pins). Suppress a false positive with `//lint:ignore <check> <reason>` on the line above (`//nolint` is ignored).

## How we work

- Work lives in GitHub Issues (`docs/agents/issue-tracker.md`). Each issue lists **Seams under test**; `/tdd` tests there.
- `/ship <n>` takes a ticket to a PR. `/review` runs at the tier `REVIEW.md` and the ticket set. Tickets use `.github/ISSUE_TEMPLATE/ticket.yml`: fill **Risks and checks**, **Live check** and **Review tier** when the ticket is written.
- [REVIEW.md](REVIEW.md) sets the risk tier of each path and what a review checks. The owner reads high-tier paths line by line, and an agent's approval never stands in for that.

## UI

A `/_styleguide` dev route renders every component. Check a UI change there before review.
