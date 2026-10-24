# Dispatch weekly health check — scheduled task

Schedule: Mondays 07:00 (Site Aleph time). Read-only. Writes one report file.

Paste everything under "Prompt" into the scheduled task.

## Metrics, thresholds, owners

Every week is compared with two things: a fixed floor, and the responder's or
network's own last four weeks. Both are needed. After 4.2, the four-week
baseline itself went bad, so by 31 Aug a rolling-only check would have read
72.7% acceptance as "improving."

| # | Metric | Green | Amber | Red | Owner |
|---|---|---|---|---|---|
| 0 | Data freshness: age of newest ping | ≤ 2 days | 3–7 days | > 7 days | Ravi Menon |
| 1 | Acceptance rate | ≥ 75% and ≤ 3 pts below 4-wk avg | 70–75%, or 3–6 pts below | < 70%, or > 6 pts below | Ravi Menon |
| 2 | Missed share (no answer in time) | ≤ 4% | 4–8% | > 8% | Wen Li |
| 3 | Callouts nobody took | ≤ 6% | 6–10% | > 10% | Marcus Oyelaran |
| 4 | Quiet responders: pings < 50% of own 4-wk avg, or none for > 4 days | 0 | 1 | ≥ 2, or same responder 2 weeks running | Wen Li (routing). Nadia Hoffmann tells the handler. |
| 4b | Responders with ≥ 3 missed pings in the week (the early sign of #4) | 0 | 1–2 | ≥ 3 | Wen Li |
| 5 | Overloaded responders: pings > 150% of own 4-wk avg | 0 | 1 | ≥ 2 | Ravi Menon |
| 6 | Ticket volume vs 4-wk avg | ≤ 1.5× | 1.5–2.5× | > 2.5× | Nadia Hoffmann |
| 7 | "Not getting pinged" tickets | 0 | 1–2 from 1 handler | ≥ 3, or from ≥ 2 handlers | Nadia Hoffmann → Wen Li |
| 8 | "Gone before I could answer" tickets | 0–1 | 2–3 | ≥ 4, or from ≥ 3 handlers | Nadia Hoffmann → Wen Li |

**Release rule.** If a Dispatch release shipped in the report week or the week
before it, treat every amber as red. Release dates are in the wiki's Releases
database. **Overall owner:** the Dispatch PM, who reads every report and
chases any red that's still red the next week.

**Backtest** (run against the database on 24 Oct 2026):

| Report for week of | Result |
|---|---|
| 3 Aug (before 4.2) | All green. No responder flagged. |
| 10 Aug (4.2 week) | Red on #1 (54.2%), #2 (21.5%), #3 (12.7%), #6 (2.9×) and #8 (7 tickets from 6 handlers). #4b red: 6 responders missing pings, including all four who went quiet the next week. |
| 17 Aug | Red on #4 (Farlight, The Undertow, Vesper, Meteor Mite) and #7 (8 tickets from 4 handlers) |
| 31 Aug | #1 amber (72.7%). #2 red (12.7%). #4 red: the same four responders, now 3+ weeks running. |

## Prompt

You're running the weekly Rook Dispatch health check. Work only in this
folder, read only, and send no messages to anyone.

1. Read `06-sidekicks/health-check/weekly-health-check.sql`. Run Q0–Q3 one at a
   time with the rook-database `run_query` tool, exactly as written.
2. If Q0 shows the newest ping is more than 7 days old, mark metric #0 red.
   Then run Q1–Q3 again with `params` set to `last_full_week_in_data`, and say
   clearly in the report which week the numbers describe.
3. Read the Releases database from rook-wiki (`search_wiki` "Releases", then
   `read_database`). If a release shipped in the report week or the week
   before, apply the release rule.
4. Score metrics #0–#8 (including #4b) using the table in
   `06-sidekicks/health-check/task-prompt.md`.
5. Write the report to `06-sidekicks/health-check/reports/<YYYY-MM-DD>.md`,
   using today's date, in this order:
   - One line: overall status (red if any metric is red, otherwise amber if
     any is amber, otherwise green) and the week covered.
   - A table with one row per metric: value, 4-week comparison, colour, owner.
   - For each amber or red: one or two sentences on what moved and the next
     step for the named owner. For #4, #4b and #7, name each responder and
     their handler.
   - Anything this check can't see (see below).
6. Report only what the queries return. Don't guess at causes. Use only
   responder names already in the database, and never try to work out who
   anyone is.

**What this check can't see yet:** time-to-accept (the pings table has no
answer time), coverage gaps (the database has no capability tags or
availability), and whether a quiet responder was actually available. Ravi owns
getting these into the data.
