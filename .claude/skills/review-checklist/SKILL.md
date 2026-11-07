---
name: review-checklist
description: Reviews a product brief against four checks — it names an owner, says how we'll know it worked, keeps the same scope start to finish, and explains the problem before the fix. Use it when the student says "review this brief", "run the review checklist", "check this brief" or points at a brief (a file path, a rook-wiki Product briefs page, or pasted text) and asks whether it's ready.
---

# Review checklist

You're reviewing one product brief for a PM. Run the four checks below against that brief only, and report what you found. Don't rewrite the brief and don't edit the file unless they ask.

## 1. Get the brief

- A file path: read the file.
- A brief name (e.g. "Requisition Approval Chains"): find it in rook-wiki's Product briefs and read that page.
- Pasted text: use what they pasted.
- Nothing given, or more than one match: ask one short question — "Which brief should I review?"

Read the whole brief before judging anything. Judge only what the brief itself says; don't fill gaps with what you know from elsewhere (note it as a suggestion instead, clearly labelled).

## 2. Run the four checks

Give each check one verdict: **Pass**, **Partly**, or **Missing**. Back every verdict with a short quote or section name from the brief so the PM can find it.

### Check 1 — Names who owns it
- Pass: a named person (not just a team or role) is accountable for the work and its decisions.
- Partly: only a team or role ("Dispatch eng", "Product"), several owners with no lead, or the named owner has left (e.g. Priya Raghunathan, left 21 Aug 2026).
- Missing: no owner anywhere.

### Check 2 — Says how we'll know it worked
- Pass: at least one measurable success signal with a baseline and a target (or a clear direction and timeframe), e.g. "acceptance rate back above 75% within 4 weeks of release".
- Partly: a metric is named but has no baseline, target or timeframe; or success is described only as shipping the feature.
- Missing: no success measure.
- Note if the metric could be confused with a neighbour (for Dispatch: acceptance rate vs coverage gap).

### Check 3 — Keeps the same scope start to finish
- Compare what the opening (summary, goal, problem) says is in scope against what the requirements, phasing, and open questions actually ask for.
- Pass: the later sections build what the opening promised, no more and no less; anything out of scope is said to be.
- Partly: extras appear later that the opening never mentioned, or an opening promise is never delivered, but the core holds.
- Missing: the later sections describe a meaningfully different or much bigger piece of work.
- List each item that drifts, with where it first appears.

### Check 4 — Explains the problem before the fix
- Pass: the brief states who has the problem, what goes wrong for them, and the evidence (tickets, data, interviews) before any solution is proposed.
- Partly: a problem is stated but with no evidence or no affected user, or it's mixed in with the solution.
- Missing: the brief opens with the solution, or the "problem" is just the absence of the feature ("we don't have X").

## 3. Report

Keep it short and plain. Use this shape:

```
Review: <brief name>

| Check | Verdict | Why |
| --- | --- | --- |
| Names who owns it | Pass/Partly/Missing | <one line + quote or section> |
| Says how we'll know it worked | ... | ... |
| Same scope start to finish | ... | ... |
| Problem before the fix | ... | ... |

To fix first: <the single most important gap, in one sentence>
Other gaps: <one bullet per remaining Partly/Missing, each with a concrete suggested fix>
```

If all four pass, say so in one line and stop. Don't add checks beyond these four.
