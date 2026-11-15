#!/usr/bin/env python3
"""Weekly model, effort and token use from Claude Code transcripts.

Run it before deciding a model got worse: it shows what changed on this
machine (model, effort, thinking per message, Opus share) week by week.

    scripts/usage-trend.py [--since 2026-10-26] [--until 2026-11-14] [--project job-hunting-copilot]
"""
import argparse, collections, datetime, glob, json, os, sys

ROOT = os.path.expanduser("~/.claude/projects")


def week_of(ts):
    d = datetime.date.fromisoformat(ts[:10])
    return (d - datetime.timedelta(days=d.weekday())).isoformat()


def short(model):
    for name in ("opus", "sonnet", "haiku", "fable"):
        if name in model:
            return name
    return model


def rows(args):
    for pdir in glob.glob(ROOT + "/*"):
        proj = os.path.basename(pdir)
        if args.project and args.project not in proj:
            continue
        for f in glob.glob(pdir + "/*.jsonl"):
            sid = os.path.basename(f)[:-6]
            subs = glob.glob(f"{pdir}/{sid}/subagents/*.jsonl")
            for path, sub in [(f, False)] + [(s, True) for s in subs]:
                yield from scan(path, sub, args)


def scan(path, sub, args):
    agent = None
    meta = path[:-6] + ".meta.json"
    if sub and os.path.exists(meta):
        try:
            agent = json.load(open(meta)).get("agentType")
        except (OSError, ValueError):
            pass
    for line in open(path, errors="ignore"):
        try:
            r = json.loads(line)
        except ValueError:
            continue
        msg = r.get("message")
        ts = r.get("timestamp") or ""
        if r.get("type") != "assistant" or not isinstance(msg, dict) or not msg.get("model") or not ts:
            continue
        if not (args.since <= ts[:10] <= args.until):
            continue
        u = msg.get("usage") or {}
        yield dict(week=week_of(ts), sub=sub, agent=agent or "?", model=short(msg["model"]),
                   effort=r.get("effort") or "-", out=u.get("output_tokens") or 0,
                   think=(u.get("output_tokens_details") or {}).get("thinking_tokens") or 0)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--since", default="2000-01-01")
    p.add_argument("--until", default="9999-12-31")
    p.add_argument("--project", help="substring of the ~/.claude/projects folder name")
    args = p.parse_args()

    main_loop = collections.defaultdict(lambda: [0, 0, 0])
    subagents = collections.defaultdict(lambda: [0, 0])
    found = 0
    for r in rows(args):
        found += 1
        if r["sub"]:
            a = subagents[(r["week"], r["agent"], r["model"])]
            a[0] += 1; a[1] += r["out"]
        else:
            a = main_loop[(r["week"], r["model"], r["effort"])]
            a[0] += 1; a[1] += r["think"]; a[2] += r["out"]

    print("== Main loop: week, model, effort, messages, thinking tokens/msg, output tokens")
    for (w, m, e), (n, th, o) in sorted(main_loop.items()):
        print(f"{w}  {m:7} {e:7} {n:6}  {th // n:5}  {o:>10,}")
    print("\n== Subagents: week, agent type, model, messages, output tokens")
    for (w, a, m), (n, o) in sorted(subagents.items()):
        print(f"{w}  {a:22} {m:7} {n:6}  {o:>10,}")
    print(f"\nfound={found} main_loop={sum(v[0] for v in main_loop.values())} "
          f"subagent={sum(v[0] for v in subagents.values())}")
    if found == 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
