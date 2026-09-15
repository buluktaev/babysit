# Checklist: the kit is ready for a worker

Run at step 7 of the `feature` skill. Any ❌ → the kit is reworked before it is handed to the user.

**By lane** (see triage, step 0). Lane 3 (full kit): every item. Lane 2 (small task, one `task.md`): every item except the four under "Launchable" about a separate runbook, README and index row — instead check that the gates are copied into `task.md` verbatim from the profile and that the start prompt names the single document. Lane 1 (trivial): this checklist does not apply; the repository's gates do.

## Executable without clarification
- [ ] Every task's test is specified as scenarios with all four parts — Scenario / Given / When / Then — and every expected value is **literal**, not described ("returns the right order" fails this item)
- [ ] Every assertion states its **scope**: `equals <full literal>` or `contains <member>`, chosen deliberately; where a scenario pins only part of a compound value, the plan says which parts — an unstated scope lets the worker's matcher decide the test's strength
- [ ] Every task's test step names the test file path and the nearest existing spec to copy the plumbing style from; harness mode stated where the repo has more than one
- [ ] Every test step says **what a wrong implementation would produce instead**, and that value differs from the expected one — an assertion that passes on both the correct and the broken version is decoration
- [ ] The implementation is an unambiguous pointer (file + example + fields from §2) or code for fragile steps; no "finish it yourself" / "roughly like this"
- [ ] The kit contains none of the words "probably", "likely", "apparently" — each resolved or moved to §8 as a decision
- [ ] Every "Test" in the contract can fail: verified by breaking the behaviour mentally
- [ ] Every `Run:` has a deterministic `Expected:` (PASS/FAIL + why) and uses the single-run test command from the profile, never a watch mode
- [ ] Task files are placed per the repository's `CLAUDE.md` structure rules
- [ ] Every pointer in the contract was dereferenced in this session: design node ids confirmed by `design-scout` (count given vs count resolved), `file:line` read or quoted, doc passages quoted, precondition branches checked with git. Anything unresolved is marked unverified in place, not left looking like a fact
- [ ] Signatures/constructors/paths are verified against the real code of the base branch — or the precondition branch recorded in the runbook (not from memory); shaky places are marked `⚠️ Verify at execution`
- [ ] Texts and values (UI strings, enums) come from §2 of the contract and match existing code 1:1 where duplicated
- [ ] Task dependencies are expressed through Interfaces (Produces/Consumes); execution order is unambiguous

## Traceability and boundaries
- [ ] §5 standing dimensions: all six rows filled — each closed by a CC number or by a dismissal that states its reason. A blank row, a bare "n/a" or a "—" fails this item
- [ ] UI features: every interactive component of the feature has its **variant set** listed — node id, variants, what differs between them — not only the screen frames it appears on. Hover, open and disabled states exist nowhere else, and a worker cannot build a state the kit never mentions
- [ ] Self-review: every CC is covered by a task or explicitly deferred (§9)
- [ ] Every §8 decision is marked **owner** or **head**; every head decision names the rejected alternative and why
- [ ] Global Constraints include the feature invariants and the git branch
- [ ] The user's manual steps are separated from worker tasks (section "What the worker does NOT do")

## Launchable
- [ ] Gates are runnable from the named directories, commands are exact and copied from the profile; invariants that cannot be a command are stated as a diff check
- [ ] One start prompt for all phases, pastes without edits (paths/names/ranges filled in) and references the "Gates" section instead of duplicating commands
- [ ] Feature README created
- [ ] Features index updated per the profile (or the profile says "none")

## Subagent verification
- [ ] A fresh subagent that read ONLY the kit found no place where it would have to guess
