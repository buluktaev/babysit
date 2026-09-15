---
name: feature
description: Takes a feature or a multi-step task from requirements to a reviewed branch through the babysit pipeline, with one stop for sign-off. Triage first picks the lane — a trivial change is done directly with no kit, a small task gets one document, a feature gets the full kit. Phase 1 (this session, the planning head) — reconnaissance by scouts, a decision gate for product forks, then contract, plan and runbook in the project's feature-kit folder. Phase 2 — an autonomous run by the `manager` agent with workers and a clean-context reviewer. Use when the user says "do feature X with babysit", "run babysit on X", "/babysit:feature", "prepare the feature for implementation", "break the feature into tasks", "babysit kit".
---

# feature — from requirements to a branch

One phrase in, one stop in the middle (contract sign-off), out comes a branch whose tasks have passed review, plus a summary. The document kit in the project's feature-kit folder is the **only carrier** between phases: subagents do not see this chat, only what landed on disk reaches them.

## Read the project profile first
`.claude/babysit.md` in the project root: repositories with base branches and gate commands, where feature kits live, where side findings and the incident log go, policies (branch prefix, worktrees, commit trailers, changelog). **Every changeable value below comes from there.** No profile → stop and create one from [references/project-profile-template.md](references/project-profile-template.md) with the user before anything else; the pipeline cannot run on guesses.

## Pipeline map (who owns what)

| Role | Model | Who | Owns |
|---|---|---|---|
| Head: forks, contract, decomposition | the most capable model available | this session, phase 1 | judgement |
| Reconnaissance | Sonnet | `scout` | facts with coordinates, no choices |
| Design reconnaissance | Sonnet | `design-scout` | resolves design pointers, states and texts in words |
| Final whole-diff review | the most capable model | `final-reviewer` | one pass at the end: does the whole add up, was the contract right |
| Run orchestrator | Opus | `manager` | order, loop, escalation |
| Execution | Opus | `worker` | code, tests, commits |
| Acceptance | Opus | `reviewer`, read-only, clean context | verdict by contract + gates |
| Visual check, E2E, merge | human | the user | — |

Agent type names as passed to the Agent tool are namespaced: `babysit:manager`, `babysit:worker`, `babysit:reviewer`, `babysit:scout`, `babysit:design-scout`, `babysit:final-reviewer`. Bare names are not registered.

Sources of truth that nobody rewrites, only reads: repo conventions — each repository's `CLAUDE.md`; the feature's gates and preconditions — its `agent-runbook.md`; behaviour — its `contract.md`. Agents and templates **reference** them; changeable values (paths, commands) are not copied.

**Boundaries:** the pipeline never merges into the base branch. Git operations inside phase 2 (branch, commits) are part of execution; launching the skill is the permission for them. Worktrees only if the profile allows them.

## Phase 0. Triage, entry and model

### Triage — pick the lane before anything else

Three lanes. Walk the gates in order and **stop at the first that holds**; the full kit is the last resort, not the default. The reason this gate exists is not elegance: a pipeline that puts a contract, a plan and a runbook behind a one-file change gets abandoned within weeks, and then none of the rest of this skill matters.

**Before the lanes, one reality check on the request itself.** Three outcomes short-circuit the whole ladder, and all three were caught by this gate on its first blind run:

- **Already true.** Verify the asked-for behaviour is actually absent before planning to build it. If it exists, say where (`file:line`, and check the base branch too, not just the working copy) and stop. There is no lane for work that is already done.
- **Contradicts a documented decision.** If the request goes against the project profile, a repository's `CLAUDE.md`, or a comment stating why a value is what it is — surface that reason first and let the owner decide. A default with a written rationale is not a defect until the rationale is read.
- **Scope not classifiable.** If the request could mean two jobs of very different size, ask **before** choosing a lane. This is the one kind of question that belongs in phase 0 rather than at the decision gate: the gate comes after reconnaissance, and you cannot scope reconnaissance you cannot size.

**Lane 1 — trivial: do it directly, no kit, no manager.** All of these hold: one repository · you can name **every** file the change touches from the request alone, without reconnaissance · no product fork · no schema or migration change · no change to a contract another repository depends on. Say it in one line — "one-file change, doing it directly, no kit" — then do the work and run the repository's gates from the profile. Writing a contract here is the failure mode, not diligence.

**Lane 2 — small task: one document, 2–4 tasks.** One or two repositories · the complete file list is knowable after **at most one** scout · at most one product fork · no new screen states beyond what already exists. Produce **one** file in the feature folder, `task.md`, assembled as a subset of the existing templates — §0 model, §2 the values table, §5 the standing-dimensions sweep, §6 only the corner cases that sweep produced, §8 decisions, then 2–4 task blocks in the plan's format, then the gates copied from the profile. No separate runbook, no README, no index row. The manager runs it with the same worker → reviewer loop.

Deliberately **not** a new template: `task.md` is those sections of the templates you already have. A second template would drift from the first, and then the two lanes would disagree about the same rule.

**Lane 3 — feature: the full kit.** Anything else, and in particular any one of: more than two repositories · screen states or a design source · more than one product fork · a schema change · the file list genuinely needs reconnaissance to know.

**What is never cut, in any lane:** the standing-dimensions sweep, literal expected values in tests, the reviewer with a clean context, the gates from the profile, and — in lanes 2 and 3 — the human checkpoint. What triage cuts is **paperwork volume**, never a gate. The one thing triage does cut is the **final whole-diff review**: it runs on lane 3 only, because the defects it hunts are created by a sequence of tasks and a two-task change has no sequence to speak of. A small task's checkpoint is cheap precisely because the document is one screen: the user reads it in a minute.

**The lane can change mid-flight, and saying so out loud is part of the job.** A small task that turns out to touch a second repository or to hide a product fork becomes a feature — that is triage working, not triage failing. A feature that reconnaissance shows to be trivial loses the ceremony. Announce the move and the reason in one line; silently staying in the wrong lane is the actual failure.

### Entry and model

1. **Model recommendation.** Phase 1 is designed for the most capable model available — it writes the contract everything downstream inherits. If you are not that model, say so in one line ("phase 1 is best run on <model>; continuing on <current>") and continue. Phase 2 does not depend on the session model — the manager spawns with `model: opus`.
2. Feature name (kebab-case) and sources: design files, research, session decisions, existing docs. If the kit folder already exists with a complete kit — skip phase 1, go to phase 2.
3. Ask **only** what blocks reconnaissance or triage: a missing link, which repository, which branch, or a scope so ambiguous that the lane cannot be chosen (see the reality check above). **Product forks are not asked here** — at this point you do not yet know which of them exist. They are asked at step 1a, after the scouts report.

## Phase 1. The kit (head + scouts)

### 1. Reconnaissance by scouts, in parallel
Spawn 2–4 `babysit:scout` agents in one message, each with a concrete question and a report path `<scratchpad>/reports/scout-<topic>.md`. Typical questions: how the integration point works today (signatures, constructors, DTOs — verbatim); every place the affected concept appears; what the design system already has for the needed elements; what the docs say about the behaviour. To a scout — "find / list / quote", never "suggest / choose".

**Branch first.** The scout must check `git branch --show-current` and take facts from the base branch if the working copy is on another one (do not touch the user's running dev stand). If the feature depends on an unmerged branch — check against it, record its merge as a **precondition** in the runbook and mark such places `⚠️ Verify at execution`.

**A feature with a design source gets a `babysit:design-scout` in the same batch.** It is not optional on a UI feature, for two reasons proven in practice. First, design pointers rot: node ids copied from an older kit or an earlier session dereference to nothing, and nobody notices until an executor goes to fetch a design that is not there. Second — and this is what the code scouts structurally cannot give you — **the decisions the owner will care about most live in the design, not in the code.** Layout, which control commits on a button and which applies instantly, thresholds, what a counter means: recon that never opened the design produces a decision gate that asks about everything except what actually matters, and leaves the head to guess the rest silently.

Scout digests are raw material. Fragile places (signatures that go into the plan) **re-verify yourself** by reading the file: accuracy here is worth more than tokens.

### 1a. Decision gate — ask the user, once, after the facts are in

Questions belong **here**, not at entry. Before reconnaissance you do not know what is ambiguous; asking then produces either generic questions or none. After the scouts report you know exactly where the code stops answering.

**What qualifies as a question.** A fork that (a) you cannot derive from code, docs or convention, (b) is expensive to guess wrong, and (c) no test would catch, because both answers produce working software. Wording, layout, which control applies instantly versus on a button, thresholds, what counts as "empty", whether a role may see something at all.

**What does not.** Technical shape — pattern reuse, where a hook lives, which module owns orchestration. You decide those and record them in §8 of the contract. Anything the code already answers: go read the code instead of spending the user's attention.

**Run the six dimensions past this filter too.** Walk D1–D6 of [the contract template](references/contract-template.md) now, in draft. Where a dimension's answer is a product call rather than a code fact — an unauthenticated visitor, what "nothing found" should say, whether a stale record may show — hoist it into this question list. A dimension you dismiss silently here is the exact defect the sweep exists to prevent.

**Form — two variants, the profile decides.**

*The profile names an interview skill* (`Interview skill:`) → **invoke it** with the Skill tool and let it run the gate. A protocol built for this does it better than a single batch: it works the **frontier** — every fork whose prerequisites are already settled gets asked now, and a fork whose answer depends on another still-open one waits for the next round. That is strictly better than a fixed question cap, which silently drops the fifth fork when there were five. Two rules of ours still bind inside it: **every question must pass the three-part filter above** — an interview protocol says "facts are my job" but does not screen out questions the code already answers, and that screening is yours; and **a fact is never a question** — dispatch a scout, and let only the forks downstream of that scout wait, not the whole round.

*The profile names none* → one `AskUserQuestion` call, **at most four questions**, each with 2–4 concrete options, the recommended one first and marked, and the consequence of each stated in its description. Needing more than four is the signal that you are asking things you could derive — cut the list, not the batch.

**The test for every question:** name, in one clause, what changes downstream depending on the answer. Cannot name it → it is not a question, it is you avoiding a decision that is yours.

Answers go verbatim into §8 of the contract as decisions of the owner, so nobody re-litigates them later.

### 2. Contract → the only stop
`contract.md` (for UI features with screen states — `states.md`) per [references/contract-template.md](references/contract-template.md): card legend, matrix, **the standing-dimensions sweep**, corner cases `CC1..N` (numbers are stable), mapping to code, session decisions, out of scope. Every "Test" in a card **must be able to fail** — break the behaviour mentally and confirm the check would see it.

**The §5 sweep is not optional and comes before you consider the contract done.** Walk all six dimensions — permissions, absent or stale data, failed dependency, empty, boundaries, repetition — and close each one with a corner case or with a dismissal that states its reason. Do not skip a dimension because the feature "is not about that": the sweep exists precisely to surface what the recon was never asked about, and a case nobody wrote is invisible to every gate downstream.

**The glossary is written as terms settle, not afterwards.** If the profile names a `Glossary:`, then every term this feature introduces or sharpens goes into it **the moment it is settled** — inline, never batched at the end, because a term recorded later is a term recorded from memory. Two duties come with it: when the owner uses a word that conflicts with what the glossary already says, call it out then and there rather than quietly picking one; and when a word is fuzzy or overloaded, propose the precise canonical term instead of inheriting the ambiguity into the contract.

**Update the project's glossary in its own shape, at its own path.** Do not introduce a competing file with a format from somewhere else: a project that already has a term list must not grow a second one, and a plugin that imposes a format on an existing document is the "dead copy" failure in a new costume.

**No unresolved pointer reaches the checkpoint.** A pointer looks like a fact and is not one until somebody dereferenced it. Before you show the contract, every pointer in it is resolved with evidence gathered **in this session**:

| Pointer | Counts as resolved when |
|---|---|
| Design node id | `design-scout` reported it resolves, and gave the node's own name |
| `file:line` | you opened the file, or a scout quoted that line verbatim |
| Doc or wiki page | a scout quoted the passage the contract relies on |
| Precondition branch | checked with git in this session, after `fetch` |
| Library or framework behaviour | quoted from the installed version's own source or docs, not recalled |

**Copying a pointer from an older kit, a previous session or your own memory does not resolve it** — age is not evidence, and this is precisely how dead design nodes survive for days. A pointer that cannot be resolved does not enter the contract as a fact: drop it, or mark it unverified in place and say so out loud at the checkpoint.

**Checkpoint.** Show the contract and say plainly: "after 'ok' I will write the plan and runbook and immediately start the run in branch `<prefix><...>`; there will be no merge". Point the user at the §5 table specifically — a dismissal there is the cheapest thing for them to overturn, and the most expensive to discover later. Wait for the answer. Edits — apply and show again. This is the only place where the pipeline waits for a human before the finish.

**On "ok", promote the decisions that outlive the feature.** §8 of a contract is feature-scoped: it dies with the folder, and an architectural choice buried there is one nobody will find in a year. If the profile names a `Decision journal:`, move such decisions into it — **in its shape, at its path, continuing its numbering**, whether that is a file per decision or a single journal.

Promote only what clears all three bars: **hard to reverse** · **surprising without the context** (a future reader will look at the code and ask why on earth) · **the result of a real trade-off** with alternatives that were genuinely considered. Miss one bar and skip it: an easy-to-reverse decision will simply be reversed, an unsurprising one raises no question, and where there was no alternative there is nothing to record beyond "we did the obvious thing". The rejected option is the load-bearing half of the entry — it is what stops the next session from re-deciding.

Say in the summary which decisions were promoted and which stayed in §8, so the split is visible rather than assumed.

### 3. Implementation plan
`implementation-plan.md` per [references/implementation-plan-template.md](references/implementation-plan-template.md). Tasks `T1..N`: Files / Interfaces / **test as scenarios with literal expected values** / implementation **as a pointer** (file, example, contract fields) / `Run:`+`Expected:` / commit. Ready implementation code — only for fragile steps that cannot be described in one phrase. Self-review at the end: every CC is covered by a task or explicitly deferred.

**You do not write test files.** Give Scenario / Given / When / Then with literal expected values, the test file path, and the nearest existing spec whose style the worker should copy — the worker writes the file, having the real code open. Two reasons, both measured: the plumbing is 60% of test code and carries no contract, and writing it blind is what drags whole source files into your context. Also state, per test, **what a wrong implementation would produce instead** — an assertion that passes on both the correct and the broken version proves nothing.

### 4. Runbook
`agent-runbook.md` per [references/agent-runbook-template.md](references/agent-runbook-template.md): preconditions, **gates (the only place their commands live — copy them from the profile)**, one start prompt for all phases, E2E for the user, "what the worker does NOT do".

### 5. README + registration
The feature's `README.md` per [references/feature-readme-template.md](references/feature-readme-template.md). Then, if the profile names a features index — add the row and bump whatever the index's convention requires.

### 6. Agent check
The plugin's agents are feature-neutral and project-neutral by design. If you find that a previous feature leaked specifics into the project's own agent overrides (`.claude/agents/`), fix it and show the diff to the user in the final summary.

### 7. Kit verification
A fresh subagent (`general-purpose`, **model: sonnet**) gets the kit paths and read access to the repo, no session context, and the question: "Could you execute T1..TN without asking a single question? Where would you have to guess? Does the kit contain the words 'probably / likely / apparently'?" Every hole → fix → repeat. Then self-check against [references/worker-readiness-checklist.md](references/worker-readiness-checklist.md) — every item ✅.

## Phase 2. The run

### 8. Dispatch the manager
Spawn `babysit:manager` via the Agent tool (`model: opus`, `run_in_background: true`) with the start prompt from the runbook's "Launch" section **verbatim** plus the line `Scratchpad for reports: <scratchpad>/reports/`. The manager runs all phases (one per repository, in the profile's order) in a single session and returns a summary.

**Nested-spawn check.** The manager's first action is a self-test: it spawns `babysit:scout` before any git action (step 0 of its instruction). The self-test stays: builds change. Three outcomes:
- The manager keeps working and sends the run plan — nesting works, do nothing.
- The manager returned a message starting with `SPAWN_UNAVAILABLE:` — no nesting in this build. Print the start prompt from the runbook's "Launch" section to the user in a fenced block (with the scratchpad line filled in from the system prompt of **that** chat — say this in words) and one line: "open a new chat on Opus and paste". Record a `spawn-failed` line in the incident log.
- The `Agent(babysit:manager)` call itself was refused or crashed — same fallback as above; the cause goes to the incident log.

Do not become the manager yourself — running the loop on the most expensive model burns the priciest resource on dispatch work.

### 8a. Record what you expect, before the run starts

One short file at `<scratchpad>/prediction.md`, written **before** the manager is dispatched and never edited afterwards: which tasks you consider risky and why, how many second rounds you expect, what you think the final whole-diff review will find, and what would count as a surprise. **For a UI feature, one line on what the layout risks** — which states the kit does not pin, where the worker will have to choose. Without it the comparison at step 10 is blind exactly where the day's work goes: measured on `search-filters`, eight of fourteen owner fixes were visual, and the prediction had not a word about the layout.

The reason is not ceremony. Without an expectation fixed in advance, the post-run analysis becomes an explanation after the fact, in which every outcome looks like it was obvious — and the one thing that stays invisible is where **phase 1 itself** was weak. Comparing prediction to outcome is the only cheap way to learn whether the head that wrote the plan understands its own blind spots.

Measured, first run: the prediction named four risky tasks and expected three to five second rounds; the run had two, one of them on a task rated low risk, and neither of the final review's two findings appeared anywhere in the prediction — one of them was a defect in the plan the prediction had just called safe.

No agent reads this file. It exists for step 10.

### 9. While the manager works
Do not wait silently and do not poll. If the user has a next feature — its phase 1 can start.

**Escalation** (three rounds without convergence, `BLOCKED`, a red gate outside the task, contract diverged from reality) arrives as the manager **finishing** with a dump — it cannot be resumed, `SendMessage` is disabled in this build for the session and for subagents alike. Read the dump and the full reports in `<scratchpad>/reports/`, decide; if it changes scope or contract — ask the user. Then **spawn the manager anew** with the same start prompt plus two lines: `Escalation decision: <what was decided and why>` and `Continue from T<N>, branches already exist`. The manager skips branch creation on these lines and starts at the right task.

### 10. Finish
Manager summary → to the user, without transcripts: tasks and statuses, branches, SHAs, what is left. **Include the run's shape from the run log**: how many tasks went in one round, which needed a second and why — the causes, not the counts. **And the final whole-diff review's verdict**: its count line and what became of each finding — fixed as a task, escalated to the owner, or filed below the bar. A run that reports "nothing above P2" from that pass is reporting something, not nothing. Triage the "Noticed, not touched" sections from worker reports **into** the side-findings register the profile names (not into the chat). **Then compare the run against `prediction.md` from step 8a** and sort every deviation by owner, because a fix filed against the wrong owner is worse than no fix: a defect of the **kit** (the plan or contract said the wrong thing and the worker executed it faithfully) is fixed in a template or a checklist; a defect of an **agent** (its instruction did not cover the situation) is fixed in that agent's file; a defect of the **skill** (the process lacked a step, or put it in the wrong place) is fixed here. Write what changed into this skill's own history. Update the status in the feature README and the features index row. Merge, visual check and E2E — the user.

## Run log — the boring data that makes the tenth run better than the first

The incident log records failures. The run log records **every** finished task, including the dull ones, because the pattern lives in the dull ones: which kinds of task systematically cost a second round is invisible from any single run and obvious across ten.

The manager appends one line per task the moment the reviewer says `APPROVED`, to the run log the profile names:

```markdown
| Date | Feature | Task | Repo | Rounds | Cause of extra rounds | Red gate | SHA |
|---|---|---|---|---|---|---|---|
| 2026-01-15 | example | T5 facets in JS | backend | 2 | plan's mock shape did not match the real spec factory | — | a1b2c3d |
| 2026-01-15 | example | T6 list with ids | backend | 1 | — | — | e4f5a6b |
```

**The payload is the cause column, not the count.** "T5 took two rounds" is not actionable; "T5 took two rounds because the plan's mock shape did not match the real spec" is a template fix. So: one round → the cause cell is `—`; more than one → **one phrase naming what the plan or the agent got wrong**, not a retelling of the fix. If the extra round was the worker's own slip with nothing wrong upstream, write that plainly — it is data too.

**Review rule, same shape as the incident log:** at the start of phase 1, read both logs. **Two entries sharing a cause → fix the template or the agent**, and note in this skill's own history what changed. A cause that recurs and is never fixed is the pipeline paying the same tax forever.

Ranges and rounds also feed the final summary (step 10) — the user sees the run's shape, not just its result.

## Pipeline incident log
Every process slip — a worker misread, a gate turned out wrong, a path rotted, an agent did not return a report, a spawn failed — one line in the incident log the profile names: date, feature, class, what happened, status. Classes: `gate-wrong`, `path-rotted`, `spec-taken-literally`, `report-lost`, `spawn-failed`, `manual-step-dropped`, `dead-copy`. At the start of phase 1 review the log: **two open entries of one class → fix the skill or an agent**, mark both entries `closed: <what changed>`. This is the only mechanism that keeps the agents from rotting for weeks.

Log format:
```markdown
| Date | Feature | Class | What happened | Status |
|---|---|---|---|---|
| 2026-01-15 | example | gate-wrong | Gate expected an empty generator run; base branch is never empty | closed: gate checks by diff |
```
