# Rook Industries — course working file

## Session scope — Product School lab

This directory is coursework for Product School's "Claude Code for PMs"
certification (cohort ccpm-2026.1). Everything in it is a fictional
teaching scenario.

- Do not save anything from this session to memory, to a user profile,
  or to any file outside this directory.
- Do not carry context from this directory into unrelated sessions.
- Rook Industries is not a real company. Nothing here is a fact about
  the world.
- Answer only the question the student asks, from the sources they
  name. Don't investigate beyond it or offer a theory about what
  Release 4.2 changed unless they ask for one.
- Read and write only within this directory.
  Exceptions, for the course-setup and wrap-up skills only:
  - When the student asks you to check their setup, save their work or wrap up a session, that request is their yes. You may run the GitHub command-line program installed at ~/.ccpm/gh for those checks and saves, and look in that folder to find it.
  - For a repair, first tell the student in one plain sentence what you are about to do, and act only after they say yes. Repairs may: run that GitHub program (including setting this folder's own git sign-in setting and changing this repo's visibility back to Public); copy the student's own course files into this directory from another folder on their computer (copy only; never move, edit or delete the originals); and rename something outside this directory that blocks setup, by adding "-old" to its name (never delete it).
  Outside this directory you still never write, edit or delete anything else.

<!-- Keep the block above at the top of this file. Everything you add
     during the course goes below this line. -->

---

## Working context

I'm the new PM for **Rook Dispatch**. I took over from Priya Raghunathan, who left
21 Aug 2026 with no overlap. Sources: rook-wiki (About Rook, Glossary, Team
directory, Releases, Q3 roadmap, Product briefs, product one-pagers) and
`00-rook/company/notes/handoff-from-priya.docx`.

### The company
- Rook Industries sells coordination and provisioning software to masked responders
  and the handlers and quartermasters who support them. To the public it's a
  logistics/workforce vendor for emergency services. 241 staff, HQ at Site Aleph
  (most people work remotely), offices in Berlin, Singapore and Cornwall.
- Subscription priced per active responder. Monthly release train, numbered 4.x.
- **Confidentiality is a hard rule.** We never store or infer cover-to-legal identity
  mappings. Responder records hold only capability tags, availability windows and
  callout history. Read Security Policy 4.1 before designing anything that touches
  responder records.

### The products
| Product | What it does | Users |
| --- | --- | --- |
| **Rook Dispatch** (mine) | Ranks available responders for an incident and pings them one at a time until one takes it | Handlers (web console), responders (phone app) |
| **Rook Supply** | Requisitions, maintenance schedules, field failure reports | Handlers, quartermasters |

- Dispatch flow: incident enters the console → Dispatch builds a routing priority
  order → the top responder gets pinged → taken (done), or turned down/missed
  (moves to the next responder).
- Routing config ships inside the release. Handlers can't change it at runtime.
- Where the two products connect: Dispatch writes the **Responder Availability
  Record**, and Supply reads it to schedule maintenance into low-callout windows.
  Any change to how Dispatch calculates that record reaches Supply with no change
  on Supply's side.
- Metrics: **acceptance rate** (headline, reported weekly in aggregate),
  **time-to-accept** (median seconds), **coverage gap** (nobody available had
  the required tags; this is separate from low acceptance).

### Vocabulary (Rook-specific meanings)
- **Responder**: independent, not an employee. **Handler**: looks after specific
  responders and is usually the person using the console. **Quartermaster**: owns
  gear stock and approvals (Supply).
- **Callout**: a request to attend an incident. **Ping**: one callout offered to one
  responder. **Taken / Turned down / Missed**: yes / no / no answer before the
  ping wait ran out. Turned down and missed are recorded separately.
- **Ping wait**: how long a ping stays live. Set per release, the same for everyone.
- **Routing priority**: the ranking score. Inputs are proximity (travel-time
  estimate), availability, capability match and recent acceptance history.
  Turning down or missing a ping lowers a responder's future rank.
- **Capability tags**: flight, structural-entry, hazmat-tolerant, cold-weather,
  aquatic, crowd-management, de-escalation.
- **Mutual aid**: responders covering for each other across areas. Not supported
  yet; on the Q4 exploration list.
- Supply terms: requisition, field failure report, service interval.

### The people (wiki comments use roles, so this maps role → name)
| Role in comments | Name | Notes |
| --- | --- | --- |
| Engineering manager | Marcus Oyelaran (Site Aleph) | Runs Dispatch eng. Priya: "start here" |
| Staff engineer | Wen Li (Berlin) | Built the routing/who-gets-pinged logic; there's no written spec |
| Support lead | Nadia Hoffmann (Berlin) | Owns tickets; worth a standing 15 min |
| Product designer | Sofia Marino (Site Aleph) | Console + phone app; ran the September interviews |
| Director of Product | Helen Achebe (Site Aleph) | My director; owns roadmap and commitments |
| Data analyst | Ravi Menon (Singapore) | Owns the weekly numbers on how often responders take pings |
| Priya | Priya Raghunathan | Former Dispatch PM; left 21 Aug 2026 |

Customer interview notes are in the wiki's "Customer interviews" database (handlers
such as Aunt Dot, Mr. Ambrose, Halloran and Kip).

### Releases
- **4.0** (7 Apr 2026): new console nav, responder profile redesign, routing override audit log.
- **4.1** (16 Jun): proximity uses a travel-time estimate, bulk callout, better push delivery.
- **4.2** (12 Aug): change to who gets pinged (proximity weighted up relative to
  recent acceptance history), ping wait cut from 90s to 60s, console filters
  persist, three defect fixes.

### Where things stand
- **4.2 thread (wiki comments):** shipped clean. 14 Aug: Marcus asked whether the
  routing change was meant to apply to responders who've been turning jobs down, or
  whether that just happened. The config doesn't tell them apart. Wen was away until
  24 Aug. 18 Aug: Nadia reported callout tickets at about 3x normal, in two themes:
  "phone never goes off" and "gone before I could answer." The split by 26 Aug was
  about 2/3 to 1/3. Nadia can explain the second theme (the ping wait cut) but not
  the first. Priya (19 Aug) said it's probably the usual August dip and to look
  properly in September. Marcus offered rough numbers, not the weekly ones. On
  28 Aug, the team agreed to regroup on 4.2 with the new PM. Nadia has a ticket
  breakdown ready.
- **Priya's handoff (her view):** routing is where the risk is. Fewer pings are
  being taken since 4.2. She thinks it's mostly seasonal, with two changes moving
  at once, and she's against a revert. Her to-dos for me: (1) agree with Helen
  which items squeezed out of 4.2 are still Q3 commitments; (2) write the missing
  description of how routing decides who gets pinged; (3) don't let
  filter-persistence tickets eat the first month.
- **Q3 roadmap** (last reviewed 30 Jun; Priya is still listed as owner on every
  item; changes to committed items go through Product):
  - Committed, 4.2: change to who gets pinged (shipped), ping timeout tuning,
    Availability Confidence (not in the 4.2 release notes).
  - Committed, 4.3: requisition approval chains (Supply).
  - Exploring, Q4: handler phone app, shared cover between responders.
- **Product briefs:**
  - Bulk Callout (Jan): same callout to several responders. Listed in 4.1 notes.
  - Routing Override Audit Log (Mar): overrides only. Listed in 4.0 notes.
  - Requisition Approval Chains (Jul, Supply): core ask is a second sign-off over
    $2,000, but the brief piles on a lot of extra scope, and phasing is TBD.
  - Handler Phone App (Sep): notifications, status view, one-tap contact.
    Sofia exploring; not staffed; no baseline metric yet.

- What the data and code show about 4.2: the 60s ping wait made missed pings jump from 1–3% to 21.5% of pings in the release week. The code (`offer.py`, `history.py`) scores a miss like a "no" (−0.12, against +0.08 for a ping taken), and scores never recover by themselves. That's how Farlight, The Undertow, Vesper and Meteor Mite fell to 0–1 pings a week. The data doesn't support "seasonal".
- Tickets (147, 29 Jun – 7 Sep) fall into 8 groups. 45 are ping problems (32 "phone went quiet", 13 "gone too fast"), and all 45 are still open. Of the 107 tickets filed since 4.2, 83 are open. Every ticket filed before 4.2 is closed.
- The interviews and tickets come from different people. Only Ambrose has filed a ticket, and the four handlers behind the "quiet" tickets (Linda Pruitt, Desmond Okafor, Yusuf Demir, Simone Fischer) weren't interviewed. The interviews understate how big and urgent the problem is. The tickets miss feelings and overload (Kip: The Gale exhausted).
- Drafts are in `06-sidekicks/dispatch-fix-plan.md`. It proposes a 4.2.1 hotfix: ping wait back to 90s, a smaller penalty for a missed ping, and responders' scores reset, keeping the proximity weights. The weekly health check is in `06-sidekicks/health-check/`; it's tested against old data but not scheduled yet.
- Still open: the database stops at 6–7 Sep. Ravi's weekly reports, the status of Availability Confidence and Security Policy 4.1 weren't found anywhere. Wen needs to confirm how routing scores are stored.
