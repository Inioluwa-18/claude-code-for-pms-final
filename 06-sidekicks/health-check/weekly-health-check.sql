-- Dispatch weekly health check — queries for rook-database (read-only).
-- Run each query separately with run_query. Each one reports on the last
-- complete Monday–Sunday week, compared with the four weeks before it.
--
-- To backtest a past week, replace the params line in each query with, e.g.:
--   params AS (SELECT DATE '2026-08-10' AS week_start)


-- Q0 · Data freshness ------------------------------------------------------
-- How old the newest ping and ticket are. If either is more than 7 days old,
-- the other numbers describe an old week. Rerun with week_start set to
-- last_full_week_in_data.
SELECT
  (SELECT max(sent_at) FROM rook.pings)                         AS latest_ping,
  (SELECT max(filed_at) FROM rook.support_tickets)              AS latest_ticket,
  round(extract(epoch FROM now() - (SELECT max(sent_at) FROM rook.pings)) / 86400, 1)
                                                                AS ping_data_age_days,
  (date_trunc('week', (SELECT max(sent_at) FROM rook.pings) + interval '1 day')::date - 7)
                                                                AS last_full_week_in_data;


-- Q1 · Network: acceptance, missed share, callouts nobody took --------------
WITH params AS (SELECT date_trunc('week', now())::date - 7 AS week_start),
w AS (
  SELECT date_trunc('week', sent_at)::date AS wk,
         count(*)                                   AS pings,
         avg((outcome = 'taken')::int::numeric)     AS acceptance,
         avg((outcome = 'missed')::int::numeric)    AS missed_share,
         avg((outcome = 'turned down')::int::numeric) AS turned_down_share
  FROM rook.pings GROUP BY 1
),
c AS (
  SELECT date_trunc('week', happened_at)::date AS wk,
         count(*) AS callouts,
         avg((NOT EXISTS (SELECT 1 FROM rook.pings p
                          WHERE p.callout_number = c.callout_number
                            AND p.outcome = 'taken'))::int::numeric) AS no_yes_share
  FROM rook.callouts c GROUP BY 1
)
SELECT p.week_start,
       w.pings, c.callouts,
       round(w.acceptance, 3)        AS acceptance,
       round(b.acceptance, 3)        AS acceptance_4wk,
       round(w.missed_share, 3)      AS missed_share,
       round(b.missed_share, 3)      AS missed_share_4wk,
       round(w.turned_down_share, 3) AS turned_down_share,
       round(c.no_yes_share, 3)      AS no_yes_share,
       round(bc.no_yes_share, 3)     AS no_yes_share_4wk
FROM params p
LEFT JOIN w ON w.wk = p.week_start
LEFT JOIN c ON c.wk = p.week_start
CROSS JOIN LATERAL (SELECT avg(acceptance) AS acceptance, avg(missed_share) AS missed_share
                    FROM w WHERE wk >= p.week_start - 28 AND wk < p.week_start) b
CROSS JOIN LATERAL (SELECT avg(no_yes_share) AS no_yes_share
                    FROM c WHERE wk >= p.week_start - 28 AND wk < p.week_start) bc;


-- Q2 · Responders gone quiet or overloaded ----------------------------------
-- An average can hide a few responders. This compares each responder with
-- their own last four weeks. Only flagged rows come back.
WITH params AS (SELECT date_trunc('week', now())::date - 7 AS week_start),
r AS (
  SELECT p.week_start, x.name AS responder, x.handler, x.area,
         count(pg.*) FILTER (WHERE pg.sent_at >= p.week_start AND pg.sent_at < p.week_start + 7) AS pings_wk,
         count(pg.*) FILTER (WHERE pg.sent_at >= p.week_start - 28 AND pg.sent_at < p.week_start) / 4.0 AS pings_4wk_avg,
         count(pg.*) FILTER (WHERE pg.sent_at >= p.week_start AND pg.sent_at < p.week_start + 7
                               AND pg.outcome = 'missed') AS missed_wk,
         max(pg.sent_at) FILTER (WHERE pg.sent_at < p.week_start + 7) AS last_ping
  FROM params p
  CROSS JOIN rook.responders x
  LEFT JOIN rook.pings pg ON pg.responder = x.name
  GROUP BY 1, 2, 3, 4
)
SELECT responder, handler, area, pings_wk,
       round(pings_4wk_avg, 1) AS pings_4wk_avg,
       missed_wk,
       round(extract(epoch FROM (week_start + 7) - last_ping) / 86400, 1) AS days_since_last_ping,
       CASE
         WHEN pings_wk < 0.5 * pings_4wk_avg
           OR (week_start + 7) - last_ping > interval '4 days' THEN 'QUIET'
         WHEN pings_wk > 1.5 * pings_4wk_avg                   THEN 'OVERLOADED'
         WHEN missed_wk >= 3                                   THEN 'MISSING PINGS'
       END AS flag
FROM r
WHERE pings_wk < 0.5 * pings_4wk_avg
   OR pings_wk > 1.5 * pings_4wk_avg
   OR missed_wk >= 3
   OR (week_start + 7) - last_ping > interval '4 days'
ORDER BY flag, responder;


-- Q3 · Tickets: volume and the two early-warning themes ---------------------
WITH params AS (SELECT date_trunc('week', now())::date - 7 AS week_start),
t AS (
  SELECT *,
    CASE
      WHEN subject || ' ' || body ~* '(quiet|hardly anything|not gone off|nothing has come|nothing coming|still on the list|still even in the system|fewer jobs)'
        THEN 'not_pinged'
      WHEN subject || ' ' || body ~* '(vanished|gone before|moved on|moved along|switched to someone|lost one|already gone)'
        THEN 'gone_too_fast'
    END AS theme
  FROM rook.support_tickets
)
SELECT p.week_start,
  count(*) FILTER (WHERE filed_at >= p.week_start AND filed_at < p.week_start + 7)                   AS tickets_wk,
  round(count(*) FILTER (WHERE filed_at >= p.week_start - 28 AND filed_at < p.week_start) / 4.0, 1) AS tickets_4wk_avg,
  count(*) FILTER (WHERE theme = 'not_pinged'    AND filed_at >= p.week_start AND filed_at < p.week_start + 7) AS not_pinged,
  count(DISTINCT filed_by) FILTER (WHERE theme = 'not_pinged'    AND filed_at >= p.week_start AND filed_at < p.week_start + 7) AS not_pinged_handlers,
  count(*) FILTER (WHERE theme = 'gone_too_fast' AND filed_at >= p.week_start AND filed_at < p.week_start + 7) AS gone_too_fast,
  count(DISTINCT filed_by) FILTER (WHERE theme = 'gone_too_fast' AND filed_at >= p.week_start AND filed_at < p.week_start + 7) AS gone_too_fast_handlers,
  string_agg(DISTINCT about_responder, ', ') FILTER (WHERE theme IS NOT NULL
                       AND filed_at >= p.week_start AND filed_at < p.week_start + 7)                 AS responders_named
FROM params p CROSS JOIN t
GROUP BY p.week_start;
