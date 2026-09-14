# Template: `.claude/babysit.md` — project profile

> Lives in the target project's root `.claude/` directory. This is the **only** place project-specific values live. The plugin's agents and templates read it; they never hardcode paths, commands or policies. Every field below is read by at least one agent — do not leave one blank, write "none" instead.

```markdown
# babysit project profile

## Repositories
One row per repository the pipeline may touch. Phase order in a multi-repo feature = row order.

| Name | Path (from project root) | Base branch | Gates (run from repo root, all must pass) | Single-run tests |
|---|---|---|---|---|
| backend | `<dir>` | `main` | `<build> && <test>` | `<test cmd> -- <pattern>` |
| frontend | `<dir>` | `main` | `<lint> && <build> && <test single-run>` | `<test cmd> -- <pattern>` |

## Layout
- Feature kits: `<path>/<feature>/` — where `contract.md`, `implementation-plan.md`, `agent-runbook.md`, `README.md` go.
- Features index: `<path to the page listing features>` — what to add per feature (row / date bump / history line), or "none".
- Side-findings register: `<path>` — where "Noticed, not touched" items are triaged, or "none".
- Incident log: `<path>` — the pipeline's own failure journal (format in the skill).
- Run log: `<path>` — one line per finished task across all features (format in the skill). The only place the tenth run gets to be better than the first because of what the ninth taught.
- Docs root (for the scout): `<path>`, or "none".

## Durable knowledge, outside any one feature
- Interview skill: `<skill name>` | `none` — a skill invoked at the decision gate instead of the built-in question round. `none` → the built-in gate.
- Glossary: `<path>` | `none` — the project's own term list. **Update it in place, in whatever shape it already has.** The plugin imposes no format: a project with an existing glossary must not grow a second one.
- Decision journal: `<path>` | `none` — where decisions that outlive a feature go, plus its **shape**: one file per decision, or a single journal; the numbering rule; the section schema. Copy the shape from what is already there.

## Tracker
- Kind: `gitlab` | `github` | `none`
- CLI: `glab` | `gh` — **run it from the repository's directory, never from a parent.** Both pick the server from the current folder; from a non-repo parent they silently address the public host and return a misleading 404 or 401.
- Project: `<group/project or owner/repo>` — **one row per repository if the project has more than one.** A multi-repo project usually has one tracker project per repository, not one for all; the CLI picks it from the current directory anyway, so list them the same way the Repositories table does and let the directory decide.
- Verbs, so agents do not guess the dialect: view `<glab issue view N | gh issue view N>` · comment `<glab issue note N -m "…" | gh issue comment N --body "…">`

**The tracker is a journal, never the carrier of the contract.** The contract and the plan live in the feature kit; the tracker gets the run's phase transitions so a human can follow along without reading a chat. Two hard rules: an agent **never closes** an issue — that is the owner's call after their own verification; and a commit message may reference an issue but **never with an auto-closing keyword**, because the tracker would close it before anything was verified.

**Posting is authorised per feature, not by this profile.** The manager posts only when the runbook's start prompt carries an issue number. No number in the prompt → no posting, everything else unchanged. Writing that number into the runbook is the owner's act of consent for an outward-facing write.

## Policies
- Branch prefix: `feat/`
- Worktrees: no | yes
- Commit trailers: none | `<exact trailer lines to add>`; forbidden: `<trailers never to add>`
- Changelog entry per task: no | yes — `<path>`, section `[Unreleased]`, decision-not-diff
- Merge into base branch: never by agents
- Final whole-diff review: yes | no — one pass by `final-reviewer` (the most capable model) after the last task of a lane-3 feature. Never runs on a trivial change or a small-lane task. Set "no" only if the token cost is not worth it on this project; the measured floor is roughly 65k tokens before it reads anything, and a feature-sized diff brings the pass to the low hundreds of thousands.
- User's running dev stand (never kill/restart): `<what and where>`, or "none"

## Terminology
<Only if the project has names that differ between code and storage/wire (legacy DB columns, JWT claims). State the mapping and where the canonical mapping lives in code. Otherwise "none".>
```

## Why a profile and not the plugin

Plugins are copied into a cache and shared across projects; anything project-specific baked into an agent is wrong in every other project and silently stale in this one. The profile is the seam: agents stay generic, the project supplies values. Repo-level conventions (stack invariants, layer rules) do **not** go here — they belong in each repository's `CLAUDE.md`, which every subagent receives automatically.
