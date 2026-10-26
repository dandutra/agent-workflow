# KB format (OKF v0.2)

A project's knowledge base is an OKF bundle, always at `docs/kb/`. The tracker (GitHub Issues) holds work; the KB holds knowledge.

## Layout

```
docs/kb/
├── index.md          ← Types table, glossary path, links to areas
├── glossary.md       ← or wherever index.md says
├── log.md            ← reserved by OKF; never write it
├── .inbox.md         ← gitignored; candidates from the capture hook
└── database/
    ├── index.md      ← nested index for one area
    └── migrations-run-in-order.md
```

Nested `index.md` files are the map: each lists the concepts and sub-areas under it with a one-line description. There is no separate context map.

## Root index.md

Declares the bundle's types and the glossary path. Types are per project, never global; use only the types the root index declares.

```md
---
type: index
title: <Project> knowledge base
---

# <Project> knowledge base

Glossary: [glossary.md](glossary.md)

## Types

| Type | Meaning | When to use |
|---|---|---|
| decision | A choice made against real alternatives | Hard to reverse, surprising, a real trade-off |
| gotcha | Behaviour that bites if you don't know it | A bug or near-miss someone would repeat |

## Areas

- [Database](database/index.md): schema, migrations, queries
```

## Concept frontmatter

One concept per file. YAML frontmatter, `type` required:

```md
---
type: decision            # required; one of the root index's types
title: Migrations run in filename order
description: One line a reader can judge relevance from.
tags: [database, migrations]
status: active            # where it fits: active | superseded | deprecated
stale_after: 2027-04-01   # where it fits: re-check after this date
verified: 2026-10-26      # where it fits: last date checked against the code
sources: [internal/db/migrate.go, "#123"]
---

<1-3 short paragraphs: the context, what was decided or what bites, and why.>
```

Links are plain markdown links (`[text](path.md)`), never wiki links, so the bundle reads the same on GitHub and in Obsidian (open `docs/kb/` as a vault with "Use markdown links" on).

## Glossary

```md
**Order**:
A customer's request to buy one or more items.
_Avoid_: Purchase, transaction
```

- Pick one word per concept and list the others under `_Avoid_`.
- One or two sentences. Define what it is, not what it does.
- Only terms specific to this project. General programming concepts stay out.

## When a decision earns a concept

All three must hold: **hard to reverse**, **surprising without context**, **the result of a real trade-off**. What usually qualifies:

- Architectural shape ("the write model is event-sourced").
- Integration patterns between areas.
- Technology choices with lock-in (database, auth provider, deploy target).
- Boundary and scope decisions, including explicit no's.
- Deliberate deviations from the obvious path ("manual SQL, not an ORM, because X").
- Constraints the code doesn't show (compliance, a partner API's latency contract).
- Rejected alternatives when the rejection is non-obvious.

## Where knowledge comes from

- When a ticket closes, its lasting lessons move into the KB in the same PR.
- Audit findings become issues; audit conclusions become concepts.
- `docs/kb/.inbox.md` collects candidates from the capture hook. `/handoff` and `/retro` propose promotions from it; the user approves each one.
