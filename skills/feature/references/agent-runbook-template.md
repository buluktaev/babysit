# Template: agent-runbook.md

```markdown
# <Feature>: agent runbook

> Contract — `contract.md`. Plan (tasks T1–TN) — `implementation-plan.md`.

## Preconditions
1. **Git:** <what the branch is cut from; what must be merged into the base branch before the
   start. Merges into the base branch — only with the user's explicit consent, outside worker
   tasks.>
2. **The user's manual steps (outside code):** <registrations, webhooks, env secrets — with ready
   commands and a result check. If none — "none".>

## Gates
<Copy the gate commands for every repository this feature touches from the project profile
`.claude/babysit.md`, verbatim. This section is the ONLY place the worker and the reviewer take
gate commands from.>
- <repo A>: `cd <dir> && <gates>`
- <repo B>: `cd <dir> && <gates>`
<- Feature invariants that are verified by diff rather than by a command (e.g. "zero migrations" →
  no schema file in the task range) — state them here with the exact check.>
<- Anything that must be rebuilt/restarted for a check to be meaningful (a dev container without
  hot reload) — the exact command.>

## Launch babysit
One start prompt for the whole feature, all phases in one manager session. The `feature` skill
passes it to the manager verbatim (phase 2) and appends the scratchpad line; for a manual launch —
paste into a new chat on Opus without edits, every path and name filled in:
```
You are the babysit manager; follow the `manager` agent's instruction.
Execute feature <feature> strictly by <kit path>/<feature>/implementation-plan.md,
tasks T1→TN in order: T1–TK — <repo A> (<dir>); T(K+1)–TN — <repo B> (<dir>). <Drop the extra phase if one repo.>
Behaviour contract — <kit path>/<feature>/contract.md.
Gates — section "Gates" of <kit path>/<feature>/agent-runbook.md; the reviewer takes them from there.
Project profile — .claude/babysit.md.
In each repo before its first task: pull <base branch>, git switch -c <prefix><branch>. Worktrees: <per profile>.
After EVERY task: worker → reviewer → on NEEDS_REVISION back to the worker, max 3 rounds;
BLOCKED, REJECTED or 3 rounds without convergence — escalate. NEVER merge into <base branch>.
Scratchpad for reports: <filled in by the skill; on a manual launch — the "Scratchpad Directory" path from the system prompt of the chat the prompt is pasted into>.
Print the run plan and start immediately — autonomously to the end, stop only on a terminal problem.
```
Loop: worker → `reviewer` (rubric + gates + `VERDICT:`) → APPROVED → next;
NEEDS_REVISION → fixes, ≤3 rounds; BLOCKED / REJECTED / 3 rounds → escalation.

## Visual acceptance — the owner's eyes, not a gate

<Decide this per project and write the decision down. Silence is the worst of the three options:
the pipeline then neither checks the layout nor admits that it does not.>

Default: **the pipeline does not compare geometry to the design.** Neither the worker nor the
reviewer measures heights, padding, radii, colours or shadows — that check needs a running stand per
task and finds what the owner sees in a minute on a live screen. Three consequences, and they are
the point of writing this down:

- the worker builds from the frame as understood and **names in its report what it chose itself**
  where the frame is silent — hover, open state, empty block. That list is what the owner looks at first;
- the reviewer stays on texts, controls and the conditions under which buttons appear — "not pixels"
  in its rubric is a rule, not a hedge;
- a mismatch the owner finds is `nobody` in the fix journal, not `agent`. It is not a pipeline defect.

The boundary that keeps this from becoming an excuse: it **is** a pipeline defect when the frame was
in the kit **and** the mismatch is visible without a stand — the wrong kind of button, a missing
section, the wrong text.

## E2E verification (after implementation <+ manual steps>)
<A hands-on scenario: what to do and what to see (every channel/screen/role).>
<Last step for a UI feature: open every state next to its frame and walk the workers'
"Chosen, not specified" lists. This is the only place the layout is compared to the design.>

## What the worker does NOT do
<An explicit list: manual steps, merges into the base branch, edits outside scope (e.g. the
frontend in a backend feature).>
```
