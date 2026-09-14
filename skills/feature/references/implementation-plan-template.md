# Template: implementation-plan.md

## Filling rules

- **The plan carries assertions, never test plumbing; the implementation is a pointer.** A task's
  test is specified as scenarios with **literal expected values** — the worker writes the actual
  test file. Rationale, measured: in a plan written the old way, assertions and scenario titles
  were 39% of the test code and imports, mock factories and fixtures were 60%. That 60% is
  plumbing, it carries no contract, and the head writes it blind from scout digests — so it is
  simultaneously the most expensive part of phase 1 and the likeliest to be wrong. Worse, writing
  it forces the head to pull whole files into its context to learn exact mock shapes, which is the
  single biggest reason the planning session fills up.

  **What the plan must give per test**, as a table or bullets, all four parts present:
  1. **Scenario** — the `it` title, prefixed with the contract reference (`CC7:`, `F3:`).
  2. **Given** — setup in words, but every fixture value literal.
  3. **When** — the call or interaction.
  4. **Then** — assertions with **exact expected values**. These are the contract: the worker may
     not reword, round or relax one.

  **State the scope of every assertion, not just its value.** Write either `equals <full literal>`
  or `contains <member>` — and choose deliberately, because the worker's matcher follows your
  phrasing. "Contains" leaves the rest of the value unchecked, and an unstated scope silently
  decides how strong the test is. Same for a compound return value: if a scenario pins only some of
  its parts, say which, so the reviewer does not read "unasserted" as "asserted". Verified in a
  round trip: a plan phrased one row as containment and the others as full equality got exactly
  that back — a containment matcher on the first, exact arrays on the rest.

  Plus, for the test as a whole: **what a wrong implementation would produce instead.** If the
  correct and the broken version yield the same result, the assertion discriminates nothing and is
  decoration — this is how a cache test that only ever called sequentially "proved" a cache that
  fails under the parallel calls it exists to serve.

  **Plumbing belongs to the worker:** imports, mock factories, fixtures, render helpers, written
  in the style of the nearest existing spec — name that spec in the step. Say the harness mode only
  when the repository has more than one (node versus browser-like) and getting it wrong costs a
  round.

  **Ready code is still right for two things**: an exact literal that the assertion compares
  against (a SQL fragment, a JSON payload, a long string) — that is data, not plumbing, and goes in
  a fenced block; and a **fragile implementation step** that cannot be described in one phrase — a
  constructor signature that must keep existing specs valid, a DTO under strict validation, a
  specific persistence call instead of the generic one, an orphaned import that breaks the type
  check. Criterion for the latter: the description needs a paragraph → give code; "as in `X`,
  fields from §2" suffices → no code. Everything that is code in the plan is verified against the
  real files of the base branch, not from memory.
- **Risk zones**: a place where the base branch may move before execution (signature, mock,
  route) — mark with a block quote `> ⚠️ Verify at execution: <what>`. The worker adapts and notes
  it in the report; the contract is not changed.
- **Changing a service constructor** — show in the step how existing calls in its spec stay valid
  (e.g. a new factory parameter with a default), otherwise the worker breaks someone else's tests.
- **`Run:` — single-run only.** Use the single-run test command from the project profile for each
  repository; never a watch-mode command — the worker will hang on it.
- **File placement follows the repository's `CLAUDE.md`** (layers, public API of a slice, naming).
  A placement error is caught by the gate — at the price of a review round.
- Every task ends with a commit step with a ready message. If the profile requires a changelog
  entry, the worker writes it itself — do not include it in the plan.
- Dependencies between tasks are expressed only through **Interfaces** (Produces/Consumes).
- **A human's manual step inside the sequence** (a check on a staging stand, an admin-panel
  action, an external service) — a separate task titled `## Task N: [MANUAL STEP] <what>`, without
  TDD steps: what to do, what to see, how to confirm. The manager stops on it and does not launch
  the following tasks until confirmed. Manual steps **before** the start — runbook preconditions.
- **A feature across several repositories**: one phase per repository (`# BACKEND` → `# FRONTEND`
  or whatever the profile's row order says), a same-named branch in each, the git line of Global
  Constraints lists all of them.

```markdown
# <Feature>: implementation plan (R1)

> **Behaviour source:** `contract.md` (<what exactly: matrix §2, corner cases CC>).
> **Launch:** `agent-runbook.md`.

**Goal:** <1–2 sentences>. **Architecture:** <new modules/services + integration point>.
**Tech Stack:** <only what is touched>.

## Global Constraints
- <Feature invariants, e.g. **Zero migrations** — no task touches a schema/entity file
  (verified by diff; do not run schema generators — see runbook)>
- Edits only in <repo A / repo B / both>.
- Texts/values — per §2 of the contract; terminology per the profile.
- Style of neighbouring files; <no new dependencies — if so decided>.
- Git: branch `<prefix><...>` from <base branch>. Worktrees: <per profile>.
- **Order:** T1 → TN by number. <If several phases: repo A T1–TK → repo B T(K+1)–TN.>

# <PHASE / REPOSITORY NAME>

## Task 1: <title>
<1–2 lines: what and why.>

**Files:**
- Create: `src/<...>`
- Modify: `src/<...>` (<what exactly; `:line` allowed>)
- Test: `src/<...>.spec.ts`

**Interfaces:**
- Produces: `<signature>` — <what it gives to later tasks>
- Consumes: `<signature>` (Task K)

- [ ] **Step 1: Failing test** — write `<test file>` <harness mode, only if the repo has more than
  one>. Plumbing in the style of `<nearest existing spec file>`. Expected values below are the
  contract: do not reword, round or relax any of them.

| Scenario (`it` title) | Given | When | Then — exact expected values |
|---|---|---|---|
| `<CC#/F#>: <title>` | <setup in words, fixture values literal> | <call or interaction> | <assertions with literal values> |

  **A wrong implementation would instead:** <what the broken version yields, per scenario or for
  the group — proof that these assertions discriminate. If both versions yield the same, the
  assertion is decoration; replace it.>
- [ ] **Step 2: Run — fails.** `<single-run test cmd> -- <pattern>` · Expected: FAIL (<why>).
- [ ] **Step 3: Implementation** (`<file>`): <pointer — what to do, modelled on which
  neighbouring file/method, which fields/texts from §2 of the contract; invariants that must not
  be broken. Ready code — only if the step is fragile (see rules above). Deliberate
  simplifications — with a comment naming the ceiling and the upgrade path>.
- [ ] **Step 4: Run — green.** `<single-run test cmd> -- <pattern>` · Expected: PASS.
- [ ] **Step 5: Commit.**
```bash
git add <files>
git commit -m "<type>(<scope>): <essence>"
```

<... Task 2..N in the same format ...>

## Self-review (plan vs contract)
- **<Matrix/states (§2)>:** covered by tasks <T#>.
- **Corner cases:** CC1 (T#) · CC2 (T#) · … · CCk deferred (§9).
- **Global Constraints:** <how they hold — e.g. "no task touches the schema">.
```
