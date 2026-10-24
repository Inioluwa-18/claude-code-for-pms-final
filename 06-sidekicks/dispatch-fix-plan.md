# Dispatch 4.2 — fix plan

Draft for Helen, Marcus, Wen, Nadia, Ravi and Sofia · 24 October 2026
Sources: rook-database (pings, callouts, tickets, 29 Jun – 7 Sep), the routing
code in `00-rook/code/dispatch-routing/`, the 4.2 wiki thread, and the
September interviews.

## What happened

4.2 changed two things at once: it raised the weight on proximity and cut the
ping wait from 90 to 60 seconds. The data points to the cut ping wait as what
set things off, with the scoring code turning it into a lasting problem.

1. **Missed pings jumped overnight.** Before the release, 1–3% of pings went
   unanswered each week. In the release week it was 21.5%, then 17.7%, 14.8% and
   12.7%. Turned-down pings didn't rise. People weren't saying no. They didn't
   get to the phone in time.
2. **The code scores a missed ping exactly like a turned-down one.**
   `offer.py:30` calls `history.record_declined` for both, so a slow thumb costs
   −0.12. A ping taken earns only +0.08. That means anyone whose take rate falls
   below 60% keeps sliding down.
3. **The score never recovers by itself.** That's the 2019 TODO in
   `history.py:30`. The only way back up is to take a ping, and a responder who
   ranks low doesn't get pinged. So once a responder is low, they stay low.
4. **Four responders got caught in that loop.** In the five days after the
   release, Farlight, The Undertow, Vesper and Meteor Mite each missed 4–5 pings.
   In the six weeks before, each had missed only 1–3. After that they lost the first ping even in their own area: in Eastgate,
   The Gale got 42 first pings and Meteor Mite got 6. They fell from 11–14 pings
   a week to 0–1. Nobody removed them from the list. They just sit at the bottom
   of it.

The data doesn't tell us why it was these four. Handler interviews suggest they
may be the responders who need longer to reach the phone (Aunt Dot: "phone to
stairs"). Ask their handlers about this before assuming it.

**Marcus's question (14 Aug):** yes, the 4.2 weights apply to everyone the same
way, including responders who've been turning jobs down. That was never decided;
it's simply how the code works. The ping wait is the bigger problem, not the
weights.

**This isn't seasonal.** The week before release had the best acceptance rate in
the data (77.9%). It fell to 54.2% in the release week. We have no earlier
Augusts to compare with.

**Wen needs to confirm two things:** how the score is actually stored in
production (`_scores` in the code is an in-memory dict keyed by name), and
whether the rankings would look the same if rebuilt from real scores.

## 1. Code: what to roll back, what to change

### 4.2.1 hotfix (ship as soon as Marcus is comfortable)

Routing config ships with a release, so this has to be a point release. Helen
signs it off because it changes a committed roadmap item (Ping timeout tuning).

| Change | File | Why |
| --- | --- | --- |
| **Roll back** the ping wait from 60s to 90s | `config.py:9` | It's what set this off. Bring it back down later only if the data supports it. |
| Count a missed ping as something different from a turned-down one, and give it a much smaller penalty | `offer.py:30`, `history.py`, `config.py` | Missing a ping isn't the same as refusing one. The glossary already says the two are recorded separately. |
| One-off fix: set every responder's score back to its 11 Aug value (or to neutral, 0.5, if there's no snapshot) | data fix, run once | Gets the four stuck responders out of the loop straight away |
| **Keep** the proximity weights (0.60 / 0.25 / 0.15) | `config.py:13-15` | Responders asked for this change, and the data doesn't blame it. Reverting it "trades one angry group for another" (Priya). |

```python
# config.py
OFFER_TIMEOUT_SECONDS = 90           # back to 90 in 4.2.1; 60 in 4.2 caused a miss spike
MISSED_PENALTY = 0.03                # a missed ping costs far less than a no

# offer.py, dispatch()
        if answer == TAKEN:
            history.record_accepted(responder)
            return responder
        if answer == MISSED:
            history.record_missed(responder)
        else:
            history.record_declined(responder)

# history.py
def record_missed(responder):
    """No answer in time. Counts against them, but much less than a no."""
    _set(responder, recent_acceptance(responder) - MISSED_PENALTY)
```

### 4.3 (the proper fix Helen asked for)

- **Close the 2019 TODO.** Each day, move every score back toward neutral by
  about 5% of the gap. A bad month then fades over a few weeks. Someone who has
  really stopped taking work still drops, because they keep missing or turning
  down pings.
- **Starvation guard.** If a responder is available and hasn't been pinged for
  72 hours, they go to the top of the list for the next callout in their own
  area that matches their tags. This ensures no responder silently disappears
  from the rotation.
- **Something a handler would notice** (Sofia to design): a "rotation" line on
  each responder's coverage card. It would show pings this week vs. usual, when
  the last ping was, and a plain-language reason when the number drops, e.g.
  "Three pings in a row went unanswered, so Farlight is lower in the order for
  now. This recovers as she takes jobs." This answers the question Kip,
  Linda Pruitt and Desmond Okafor have all asked.
- **Something a responder would feel:** a visible countdown on the ping itself.
  After a missed ping, a short message: "This one moved on. Missing a ping
  doesn't count against you like turning one down." If a responder has been
  quiet for 3 days while available, a note saying they're available and in the
  rotation.
- **Tell the handler when their responder gets a ping** (Aunt Dot's ask). This
  ties into the Handler phone app exploration.

## 2. Winning responders back

Rook reaches responders through their handlers. We don't contact responders
directly, and nothing in this plan needs anything beyond responder names
already in our system.

| When | What | Owner |
| --- | --- | --- |
| This week | Call the six handlers whose responders went quiet: Linda Pruitt (Farlight), Desmond Okafor (The Undertow), Yusuf Demir (Corporal Ashgrove), Simone Fischer (Halfmoon), Kip (Meteor Mite) and Aunt Dot (Vesper). Explain what happened and when it'll be fixed. | PM + Nadia |
| This week | Reply to all 45 open "not getting pinged" and "gone too fast" tickets, using the reply below | Nadia |
| On 4.2.1 day | Send the release note below to all handlers | PM |
| 4.2.1 + 2 weeks | Check that the four quiet responders are back to at least 80% of their pre-August ping volume. If not, escalate to Wen. | Ravi |
| Decide now | Billing credit for affected responders from 12 Aug until the fix (we bill per active responder, and they were barely pinged) | Helen |
| 4.2.1 + 4 weeks | Follow-up interviews with the four September handlers plus Linda Pruitt and Desmond Okafor | Sofia |

## 3. What we'd tell them

**To the six affected handlers (call first, then send this in writing):**

> Since our 12 August update, [responder] has been getting far fewer callouts
> than usual. That was our fault, not anything on your side or theirs. The
> update shortened how long a callout waits on the phone, so more of them
> moved on before [responder] could answer. Our system then counted each of
> those like a "no" and moved [responder] down the list, and nothing brought
> them back up. On [date] we're putting the wait back to 90 seconds, no longer
> counting an unanswered callout as a "no", and restoring [responder]'s place
> in the order. You don't need to change anything. We'll check [responder]'s
> callouts for the next two weeks and tell you what we see. I'm sorry this went
> on as long as it did, and that you had to keep asking.

**4.2.1 release note (all handlers):**

> **4.2.1.** Callouts now wait 90 seconds for an answer again, up from 60 in
> 4.2. A callout that times out no longer counts against a responder the way
> turning one down does. If a responder was moved down the order by timeouts
> since 12 August, we've restored their place. The 4.2 change that favors
> nearby responders stays.

**Reply for open tickets (Nadia):**

> Thanks for raising this, and sorry for the wait for a real answer. Your
> ticket was one of several that helped us find the cause: the 12 August update
> gave callouts less time to be answered and counted the misses against
> responders. We're fixing both on [date]. We'll update this ticket when it's
> live.

## 4. Catching it next time

See `health-check/` for the weekly health check, which is ready to run as a
scheduled task. I tested it against the old data. Its first Monday report
after 4.2 (17 Aug) would have flagged acceptance, missed pings, callouts
nobody took, and ticket volume, all red. That's a day before Nadia's heads-up
in the wiki thread and two days before the "wait for September" call. It
would also have listed Farlight, The Undertow, Vesper and Meteor Mite among
the responders missing pings, a week before they went quiet. The next week's
report would have named all four as quiet.
