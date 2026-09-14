# Template: contract.md / states.md

> Section numbering may be sparse (§2 → §6) — canonical numbers are kept for recognisability; skip sections that do not apply, do NOT renumber.

```markdown
# <Feature>: <behaviour / delivery / state> contract (R1)

> `implementation-plan.md` grows out of this contract.
> Babysit launch — `agent-runbook.md`.
> Source of truth for the behaviour of <what exactly>.
> **Read on:** code `<base branch, sha>`, design `<date and time, by design-scout>`.
> <Date the design read, not just the code read. Designs move under a signed contract — a panel
> can grow a button the same day the owner signed that it has none — and without a timestamp the
> drift is invisible. On any re-read, compare against this line first.>

## 0. Model (brief)
- <5–8 bullets: key concepts, invariants ("duplication, not replacement"), the single integration point>
- **Terminology↔storage:** <if the project profile lists legacy names — state the mapping here; otherwise drop the line>

## 1. Card legend
<The fields every card/row below is described with. Two field sets — they MAY be combined
(a hybrid feature: Trigger/Recipient from the backend + Text/Click from the frontend):>
- UI feature: **Entry / Frontend / Data (API) / Backend / Actions / Test**
- Backend feature: **Type / Trigger / Recipient / Text / Test**
<**Test** is always mandatory and **must be able to fail**: break the described behaviour mentally
and confirm that exactly this check would notice. A green check on broken logic is worse than
no check — it lies to the reviewer.>

## 2. Matrix (overview — the source of truth for values)
<A table of all states/types: exact texts, roles, paths. The plan references this, it does not duplicate it.>

## 3. State cards <UI features only; backend features skip this section>
<Every design node id here was resolved by `design-scout` in this session — see the pointer rule in
the skill. Cite the node's own name next to the id: an id that resolves to a frame named nothing
like this state is a finding, not a match.>
### S0 · <title> · design node `<id>` "<node name as the tool reports it>"
- **Entry:** <under which ownership/status it is shown>
- **Frontend:** <navigation, distinguishing content>
- **Data (API):** <what is needed from the backend>
- **Backend:** <endpoints, checks, codes>
- **Actions:** <clicks and where they lead>
- **Test:** <minimal check>

## 5. Standing dimensions (mandatory sweep)

<Every feature answers all six, whatever it is about. A dimension is closed either by a corner
case in §6 or by an explicit dismissal that states its reason. **A blank row is not allowed.**
Absence is the one defect class nothing downstream can catch: the reviewer checks coverage of
the corner cases that exist, and a case nobody wrote is invisible to every gate.>

| # | Dimension | The question to answer | Outcome |
|---|---|---|---|
| D1 | Authentication and permissions | Who may see this and act on it? What does an unauthenticated actor, or one holding the wrong role, see — and can their actions still change persistent state (URL, storage, server)? | CC# / n/a: … |
| D2 | Data absent or stale | First render, request in flight, an optional field missing, an entity whose satellite record (index, cache, derived row) has not caught up with it. What renders, what is returned? | CC# / n/a: … |
| D3 | Dependency failed | The upstream call errors, times out, or runs in a degraded mode. Does the feature fail closed (empty and honest) or open (silently wrong)? | CC# / n/a: … |
| D4 | Empty | Nothing matches the current conditions, versus nothing exists at all. Two different screens with two different messages — decide both. | CC# / n/a: … |
| D5 | Boundary values | Zero, one, the maximum, both sides of every bucket edge, an empty string versus an absent parameter, the longest allowed input. | CC# / n/a: … |
| D6 | Repetition and concurrency | Double click, retry, two actors on one entity, a stale response arriving after a newer one. | CC# / n/a: … |

<**Rule for inherited rules.** When a parameter, a validation or a limit moves to a different
endpoint, scope or caller, **re-derive it from the new scenario — never inherit it**. A rule that
was safe where it came from can be harmful where it lands: a minimum-length check that protected
a dedicated search route starts rejecting the whole catalog once that parameter joins the catalog
route.>

## 6. Corner cases (CC)
<CC numbers are global and STABLE — the plan (Self-review) and the reviewer refer to them.>
### CC1 · <title>
- **Entry:** <condition>
- **Behaviour:** <what must happen>
- **Test:** <a check that fails if "Behaviour" is violated>

## 7. Mapping to code
| Invariant | Where | Essence |
|---|---|---|
| <invariant> | `<file>` | <one line> |

## 8. Decisions of this session
<Every decision carries its author, because a year later nobody remembers which were choices and
which were guesses:>
- **owner** — answered at the decision gate (step 1a). Never re-litigate these; if one now looks
  wrong, raise it, do not quietly change it.
- **head** — technical shape decided here: what was chosen, and the alternative that was rejected
  with the reason. The rejected option matters more than the chosen one — it is what stops the
  next session from re-deciding.

<Mark each entry that was **promoted to the project's decision journal** and give its number there.
This section is feature-scoped and dies with the folder; a decision that is hard to reverse,
surprising without context, and the result of a real trade-off belongs somewhere that outlives it.
A promoted entry stays here as a one-line pointer, not a copy — two copies of one decision drift.>

## 9. Out of scope for R1
<An explicit list of what is deferred — otherwise the worker will "finish" it.>
```
