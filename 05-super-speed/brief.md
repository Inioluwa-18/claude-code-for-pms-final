# A responder who's gone quiet should be able to see why, and get back

For Helen Achebe · from Inioluwa (Dispatch PM) · 7 Nov 2026 · Click-through: https://claude.ai/artifact/Mm9E9WHMCysVx7FVNwjZD8

## The problem

Every **responder** has a recent-acceptance score from 0 to 1. It is one of three inputs to **routing priority**, weighted 0.25 since 4.2 (it was 0.40). The other two are proximity (0.60) and capability match (0.15). Everyone starts at 0.5, which is neutral. A ping **taken** adds 0.08. A ping **turned down** or **missed** takes off 0.12. The score never recovers by itself. 4.2 (12 Aug) cut the **ping wait** from 90s to 60s, and missed pings jumped from 1–3% to 21.5% of pings in the release week. Responders who missed a few pings dropped down the order, stopped being pinged, and had no way back. Nobody decided this. The **acceptance rate** recovered to 72.7% because others absorbed the pings, so the average hides who lost out.

## Who it affects

**Meteor Mite** (Eastgate; handler Kip) went from 10–12 pings a week before 4.2 to 4, then 2, then 1 in the week of 31 Aug, the last full week of data. Over the same weeks The Gale went from 12–14 to 21. In Eastgate, The Gale got 42 first pings and Meteor Mite got 6. Meteor Mite's score hit 0 by 6 Sep, though they turned down pings at a normal rate. Kip, 4 Sep: "Mite thinks Mite's been forgotten. Gale's exhausted." The same thing happened to Farlight (Linda Pruitt), The Undertow (Desmond Okafor) and Vesper (Aunt Dot).

## What we'll change

The fix is what Meteor Mite and Kip experience, not a number. In 4.3:
1. **A missed ping stops counting like a no.** It's recorded and scored separately, and Meteor Mite is told so. This answers Wen Li's 2019 note in `history.py`: a missed ping means "didn't reach the phone in time", not "won't come".
2. **Scores recover.** Each day, every score moves about 5% of the way back toward 0.5, so a bad month fades over a few weeks. Wen's worry was that someone who has stopped taking work should stay down. They still drift down, because they keep turning down pings.
3. **Nobody disappears.** If a responder has been available for 72 hours and had no ping, they go first for the next **callout** within reach that fully matches their **capability tags**. The guard fires once. If that ping is missed, it asks the handler to confirm availability. Risks are in Appendix B.
4. **People can see it.** See the next section.

**Stopgap (Helen decides):** 4.2.1 can ship now. It puts the ping wait back to 90s, makes a missed ping cost 0.03, restores the four stuck scores to their 11 Aug values, and keeps the proximity weights. It changes numbers only, and doesn't replace 4.3.

## What Meteor Mite and Kip see

| | Today | With the fix |
| --- | --- | --- |
| **Meteor Mite** (phone app) | The ping vanishes before they can tap it, then nothing comes. | A countdown on the ping. After a miss: "This one moved on. Missing a ping doesn't count against you like turning one down." After 3 quiet days: "You're available and in the rotation." |
| **Kip** (console) | Two cards, one silent and one overloaded, with no reason given. | A rotation line on Meteor Mite's coverage card: pings this week against usual, the last ping, and the reason in plain words when the number falls, e.g. "Three pings in a row went unanswered, so Meteor Mite is lower in the order for now. This fades over the next few weeks. If Meteor Mite goes 72 hours without a ping, they go first for the next matching callout." Kip is notified when Meteor Mite is pinged. |

**The day the fix ships**, Meteor Mite's app says: "Your place in the order is back. Since 12 August, pings you didn't reach in time counted against you like turning one down. That was our mistake, not yours." Kip's card is marked "Restored". If 4.2.1 ships first, Kip's phone call carries this message until the app can show it.

## How we tell them

Inioluwa and Nadia Hoffmann call Kip first, then Linda Pruitt, Desmond Okafor and Aunt Dot. They call Yusuf Demir and Simone Fischer with the milder script. Each call is followed up in writing. Nadia answers the 45 open ping tickets. A release note goes to all handlers on each release. We reach responders only through their handlers and the app, and name them by cover identity only.

## Owners and target dates (proposed)

| Part | Owner | By |
| --- | --- | --- |
| Decide on 4.2.1 now or hold; sign off 4.3 scope (changes the committed Ping timeout tuning item); decide on a billing credit | Helen Achebe | Wed 11 Nov |
| Answer the open questions for engineering (below) | Wen Li | Fri 13 Nov |
| Pull data to date; set baselines (Appendix A) | Ravi Menon | Fri 13 Nov |
| Handler calls and written follow-up | Inioluwa, Nadia Hoffmann | Fri 13 Nov |
| Replies to the 45 open ping tickets | Nadia Hoffmann | Fri 13 Nov |
| Ship 4.2.1, if Helen says go | Marcus Oyelaran | Thu 19 Nov |
| Rotation line, countdown, messages; test with Kip, Linda Pruitt and Desmond Okafor | Sofia Marino | Fri 11 Dec |
| Build items 1–3 in 4.3; set its release date | Wen Li, Marcus Oyelaran | Release after design sign-off |
| Checks at 2 and 4 weeks after scores are restored; schedule the weekly health check | Ravi Menon | Restore + 2 and + 4 weeks |
| Follow-up interviews with the six handlers | Sofia Marino | Restore + 4 weeks |
| Routing description (Priya's to-do), release notes, this brief | Inioluwa | Fri 27 Nov |

## Open questions

- **Wen Li:** Scores are an in-memory dict keyed by name. Does a restart or a handler override reset them? Is there an 11 Aug snapshot to restore to? Which time zone do availability windows use? Does gear out for maintenance make a responder unavailable?
- **Ravi Menon:** Our data ends 7 Sep. Where is Meteor Mite today?
- **Helen Achebe:** Is Availability Confidence still a commitment? Does "4.3" still name the next release?
- **Security Policy 4.1** hasn't been found. Can a handler see the reason a responder dropped down the order?

## Out of scope

- Reverting the 4.2 proximity weights.
- A leave status.
- A second sign-in for a covering handler, and handover notes.
- Handler requests from the interviews and tickets: dark mode, a different alert sound per responder, bigger badge text.
- The handler phone app, so notifications stay in the console for now.
- Mutual aid.
- Supply requisition work.

---

## Appendix A: How we'll know it worked

Ravi Menon sets each baseline from the weeks before 4.2 (29 Jun – 11 Aug), once the data is pulled up to today. Thresholds marked *proposed* need Helen's agreement. Only four responders went quiet, so the rows about them are tracked one responder at a time, not as statistics.

| # | Measure | Baseline | Target | Owner |
| --- | --- | --- | --- | --- |
| 1 | Pings per available hour, for each of the four | Pre-4.2 rate (Meteor Mite: 10–12 a week; Ravi to compute for the other three) | ≥80% of baseline by restore + 2 weeks | Ravi Menon |
| 2 | Meteor Mite's share of first pings in Eastgate | Pre-4.2 share; 6 against The Gale's 42 since 4.2 | ≥80% of pre-4.2 share by restore + 4 weeks | Ravi Menon |
| 3 | **Missed** pings as a share of all pings | 1–3% a week; 21.5% in the release week | ≤3% every week for 4 weeks | Ravi Menon |
| 4 | **Time-to-accept** (median) | Pre-4.2 median at a 90s ping wait | Within 10s of baseline (*proposed*) | Ravi Menon |
| 5 | Available responders with no ping for 72 hours while a matching callout was within reach | Pre-4.2 weekly count | 0 a week after 4.3 | Ravi Menon |
| 6 | The Gale's and Nightwell's pings a week | Their own pre-4.2 usual | ≤120% of usual (*proposed*) | Ravi Menon |
| 7 | Travel-time estimate on pings sent by the guard, against normal pings in the same area | Normal pings, same area and week | Median no more than 5 min longer (*proposed*) | Wen Li |
| 8 | New "phone went quiet" tickets | 32 since 4.2, all open | 0 for 4 weeks in a row after restore | Nadia Hoffmann |
| 9 | Handlers can explain their responder's ping count from the console alone | None | Pass for all six at restore + 4 weeks | Sofia Marino |
| 10 | Quiet responders trust that pings reach them again (asked through their handlers) | Today's tickets | All four still active at 8 weeks; each handler says yes | Sofia Marino |

**Guardrails, not goals:**
- **Acceptance rate** stays at or above 72.7%.
- **Coverage gap** doesn't rise above its pre-4.2 level.

**Which release did what:** rows 1–4 and 8 are read for 4.2.1, and rows 5–7, 9 and 10 for 4.3. If 4.2.1 ships first, Ravi takes a reading before 4.3 lands.

## Appendix B: When the 72-hour guard could misfire

The guard trusts "available". Availability is set by the responder or their handler in the app, and routing never changes it (`availability.py`). The tickets and interviews show several ways it can be wrong.

| Situation | Evidence | What goes wrong | How we handle it |
| --- | --- | --- | --- |
| On leave, but still marked available | Simone Fischer (#3035) and Teresa Alvarez (#3143): the only way to show leave is to set the responder unavailable, which "looks the same as being busy" | The guard pings someone who's away. Each missed guard ping delays that callout by up to 90s. | The guard fires once. After a missed guard ping, the handler gets "Is Meteor Mite still available?" and the guard waits for an answer. The 72-hour clock only counts available hours. |
| Working from another city | Simone Fischer (#3050) and Renata Kovač (#3116): availability windows seem to use the handler's time zone | Availability hours are off by hours, so the clock and the guard fire at the wrong times. A responder's home area isn't where they are. | Use travel time from their real location, not their home area, and only fire within the 45-minute proximity limit. Wen confirms the time zone question. #3116 is still open. |
| A covering handler signed in as the main handler | Teresa Alvarez (#3053) and Renata Kovač (#3141): a colleague covers two nights a week on the main handler's sign-in. Handover notes are on paper (#3008, #3068) | The prompt asking to confirm availability, or the "Restored" news, reaches whoever is on shift, who may not know the history. | Put the reason on the coverage card, not only in a notification, so any handler on shift can see it. Second sign-ins are out of scope. |
| One handler, two responders in the same area | Kip handles Meteor Mite and The Gale, both in Eastgate | The guard moves callouts from one of Kip's responders to the other. That's intended, but Kip should be able to see it. | The rotation line appears on both cards. The Gale's card shows when load eases. |
| Missing or incomplete capability tags | Teresa Alvarez (#3024): Ironvale was cleared for cold-weather work but had no tag | No matching callout arrives, so the guard never fires, and the 72-hour measure counts that as a failure. | Measure 5 only counts responders who had a matching callout within reach. After 72 quiet hours with no match, the rotation line says "No callouts needed Meteor Mite's tags" and suggests checking tags. |
| Gear out for maintenance | Beatrice Calloway (#3030) and Desmond Okafor (#3069): the console shows gear away, with no return date | The guard pings a responder with no suit. | Wen confirms whether gear away makes a responder unavailable. If not, the guard skips anyone whose gear is out. |
| Away from the phone, but available | Aunt Dot: Vesper is upstairs, and it's "phone to stairs". Mr. Ambrose: Captain Vantage was suiting up | A missed guard ping. | A 90s ping wait, the countdown, and Kip's notification (Aunt Dot asked for this). A missed ping costs 0.03, and the guard asks the handler before firing again. |
| Engaged and available look alike on the console | Graham Petrov (#3013) and Owen Bramwell (#3142): the badges are hard to tell apart | A handler misreads the status and leaves availability wrong. | The guard clock pauses while a responder is engaged. The rotation line is written in words, not only shown as badge color. |
