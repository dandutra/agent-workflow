---
name: handoff
description: Write a handoff document for the next session, or resume from the newest one.
argument-hint: "What will the next session be used for? Or 'resume'."
disable-model-invocation: true
---

`<project>` is the basename of the git repo root (or of the working directory outside a repo).

## Resume

If the user passed `resume`, or this is the start of a session and they asked to pick up where the last one left off:

1. List `~/.claude/handoffs/<project>/` and read the newest file in full. It is the whole handoff; `archive/` holds the ones it replaced.
2. Follow its "Start here" steps and load the skills it names.
3. Tell the user, in two or three lines, what the handoff says comes next.

Stop there; don't write a new handoff.

## Write

1. Write the handoff to `~/.claude/handoffs/<project>/YYYY-MM-DD-<topic>.md` (today's date, a short kebab-case topic). Create the folder if needed.
2. Make it self-contained. If older handoffs sit in the folder, carry forward each fact and step that is still true, and drop the ones this session finished or disproved. The next agent reads this file alone, so every pointer goes to a spec, plan, commit or issue, never to another handoff. Then move the older handoffs into `~/.claude/handoffs/<project>/archive/`.
3. Contents:
   - **Next session's job**, in one or two lines. If the user passed arguments, they describe it; tailor the document to it.
   - **Start here**: ordered first steps.
   - **Facts already established**: what the next agent would otherwise re-derive.
   - **Suggested skills**: which skills the next agent should load.
   - Reference specs, plans, KB concepts, issues, commits and diffs by path or URL. Don't copy their content.
   - Redact secrets, keys, passwords and personal data.
4. If `docs/kb/.inbox.md` exists and has entries, show them and propose which to promote into KB concepts (type, target path, one-line reason) and which to discard. Promote only what the user approves, in the format the `domain-modeling` skill's KB-FORMAT.md describes, then remove the handled entries from the inbox.
5. Print the handoff's full path.
