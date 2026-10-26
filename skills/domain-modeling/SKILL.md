---
name: domain-modeling
description: Build and sharpen a project's domain model in its docs/kb/ knowledge base. Use when discussing codebase terminology, adding or editing a glossary term, or recording a decision.
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design: challenge terms, invent edge-case scenarios, and write glossary terms and decisions down the moment they crystallise. (Merely _reading_ the glossary for vocabulary is not this skill; any skill does that. This skill is for changing the model.)

The model lives in the project's OKF bundle at `docs/kb/`. [KB-FORMAT.md](./KB-FORMAT.md) is the format: the root index and its **Types** table, concept frontmatter, the glossary, and when a decision earns a concept.

## Before the session

Read `docs/kb/index.md`. Note its declared types and the glossary path, and use only those types. Follow nested `index.md` files to the area under discussion.

If `docs/kb/` doesn't exist, ask the user whether to start a bundle now. The root `index.md` needs the user to approve its Types table, so propose one and wait. If they decline, keep resolved terms and decisions in the conversation and list them at the end.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the glossary, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y. Which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account': do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible. Which is right?"

### Write the glossary inline

When a term is resolved, add or edit it in the glossary right there, in the format in [KB-FORMAT.md](./KB-FORMAT.md). Capture each as it happens rather than batching.

The glossary is definitions only: no implementation details, no spec, no scratch notes.

### Record decisions sparingly

Offer to write a `decision` concept only when it is hard to reverse, surprising without context, and the result of a real trade-off. If any of the three is missing, skip it. Each new concept gets a link from the nearest `index.md`.
