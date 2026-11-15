# Review replay evals

Past first-draft diffs with a bug that later surfaced. A change to `/review`, `tier.sh` or a reviewer agent is trusted only when the replay still finds every known bug.

`cases.tsv` holds one case per row: the repo under `~/Projects`, the fixed point, the first-draft commit, the tier to force, a regex the report must match, and the bug in words.

```sh
scripts/review-eval.sh            # every case
scripts/review-eval.sh t73        # cases whose name starts with t73
```

Each run checks out the first draft in a temporary worktree, runs `claude -p "/review <base> tier=<n>"`, saves the report under `evals/review/runs/<date>/`, and prints PASS when the regex matches. The regex is a coarse filter, so read every report before trusting a PASS. A tier 3 replay costs about as much as one real tier 3 review.

Add a case whenever a bug reaches main after review: the base, the draft commit the review saw, and the fix commit.
