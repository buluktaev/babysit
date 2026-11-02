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

### Component states <UI features only; skip when the feature adds no interactive component>

<A screen frame shows one state each. What it cannot show is what a control does under the cursor,
while open, while disabled — that lives in the component's own variant set, a different node.
One row per interactive component of the feature; ids resolved by `design-scout` in this session.>

| Component | Variant set `<id>` "<node name>" | Variants | What differs between them |
|---|---|---|---|
| <dropdown trigger> | `<id>` "<name>" | default / hover / open × selected | <background token, chevron direction, counter colour> |

<Measured, production project: three of the four pipeline-caused fixes of one day were
states that exist only in a variant set — hover on a list row, the open state of a trigger, the
counter colour of a selected chip. The worker could not have built them from the kit: it listed
screen frames only, and none of those states appears on a screen frame. This table is the fix.>

## 4. Model delta <mandatory when the feature adds or changes an entity, a property, a relation, a dictionary or a status; otherwise one line `n/a: <reason>`>

<The change this feature makes to the system model, designed before code. Without it the model
exists only as whatever the code happens to do, the project's docs describe that code after the
fact, and every gap between the two becomes a defect nobody designed. Describe only the delta, not
the whole model; drop a table the feature does not touch.>

**Properties**
| Entity.property | Type | Source of truth | Stored where | Required |
|---|---|---|---|---|
| <entity.property> | scalar / reference to <entity> / dictionary-enum <name> / derived from <what> | <the one place this value is authored> | server / client / both / external system <which> | yes / no |

<A value that comes from a dictionary is a **reference** to it, never a copy of its label: the
copy survives a rename of the dictionary entry and quietly stops matching anything. One property,
one source of truth; "both" in Stored where names which side wins on conflict.
Measured, production project: a profile stored dictionary labels as plain strings instead of
references; renaming one dictionary entry broke the filter built on it.>

**Relations**
| From → to | Cardinality | Direction and dependency | On delete of each side | Stored explicitly or computed |
|---|---|---|---|---|
| <A → B> | 1:1 / 1:N / M:N | <who owns whom; can B exist without A> | <A deleted → …; B deleted → …> | FK / field <name> · computed from <what>, because <reason> |

<A relation is part of the model: cardinality, direction and delete behaviour are decided here,
not discovered in a cascade. A **computed** relation (derived from another record instead of
stored) needs a stated reason — it breaks the moment the record it is computed from changes or
disappears.
Measured, production project: a reservation had no owner field and took it from its first
time slot; a cascading delete of slots made reservations lose their owner and silently vanish from
lists. The request a reservation came from held no link to it, and notifications stored ids
without a foreign key and without the cause they were sent for.>

**Transitions**
| Entity | From → to | Who or what moves it | Guard (what is checked) | Invalid transition answers | Test that fails if the guard is removed |
|---|---|---|---|---|---|
| <entity> | <state> → <state> | <role / job / event> | <source state, ownership, …> | <error code> | <scenario> |

<Every state and every allowed transition of each touched entity is listed before code; a pair not
listed is forbidden, and the guard is what makes "forbidden" true at runtime. The test column is
not optional: a guard without a test that hits the invalid case is a guard the next refactor
removes unnoticed.
Measured, production project: only one of three core entities had an explicit lifecycle; approve
and reject of a profile did not check the source state, and another entity's statuses arrived in
three migrations within one day.>

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
