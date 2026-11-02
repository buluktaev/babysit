# Eval suite — phase 1 of the `feature` skill

Seven cases covering phase 1 only: triage, the decision gate, and the kit that reaches the
sign-off checkpoint. Phase 2 (manager → worker → reviewer, real branches and commits) is out
of scope — every fire case ends the run at the checkpoint on purpose.

| Case | Checks |
|---|---|
| 01 | Task order is self-consistent: no task assumes a rename an earlier task has not performed |
| 02 | The §5 sweep closes staleness and concurrency with concrete cases, not a rubber stamp |
| 03 | The §5 sweep states who may perform an admin-only action, and where that is enforced |
| 04 | The decision gate asks the real product fork and skips the one the conventions answer |
| 05 | An unresolvable design pointer is marked unresolved; no invented detail, no hedge words |
| 06, 07 | Should NOT fire: a general question and a plain bug report |

## Running it

```bash
claude plugin eval . --ablation with-without --judge-model opus --allow-tools Write
```

`--allow-tools Write` is required: the fire cases write the kit to disk and their graders read
those files. The judge must stay larger than the agent under test — the cases pin the agent to
sonnet, so the judge is opus. Add `--no-publish` to keep the report local. The headline number
is Δ, the with-plugin score minus the without-plugin score.

## Environment precondition

A write- or Bash-granting run needs the runner's OS sandbox, and the sandbox refuses to start on
a machine whose `~/.docker` holds symlinks — a stock Docker Desktop install does, in `bin/` and
`cli-plugins/`. With `Bash` granted the run aborts loudly; with only `Write` granted it starts
and then denies every write, which reads as "the plugin produced nothing". Setting
`DOCKER_CONFIG` elsewhere does not help; the check reads `~/.docker` regardless. Run the suite
on a machine or CI image without that layout.

## Where this stands (2026-09-17, interrupted)

The five fire cases were rewritten as `case.yaml` with a `scaffold_script`, because the earlier
prompt-only cases lied to the agent: they described a React app while the sandbox was empty, and
the skill correctly refused to write a contract citing `file:line` for code that does not exist.
Runs that "passed" were runs that went along with the fiction. Each case now stages a small real
tree — hooks, components, routes, endpoints, migrations, `.claude/babysit.md`, `CLAUDE.md` — so
scouts read actual code. Run the suite with `--scaffold`.

Numbers from before that rewrite are not comparable with numbers after it.

Completed on the scaffolded suite, at `runs: 3` per arm:

| Case | with | without | Δ | note |
|---|---|---|---|---|
| 01 | 1.00 | 0.00 | +1.00 | clean, $3.78 |
| 02 | 0.50 | 0.00 | +0.50 | 2 of 3 with-runs hit the 700 s timeout |
| 03 | 0.33 | — | — | with-arm only; interrupted before the without-arm |

Next session, in order:

1. Raise `timeout_seconds` to 900 on cases 01, 02, 03 and 05. Reading a real tree costs far more
   than the empty sandbox did; 700 s was set against the old, fictional cases.
2. Re-run 02 and 03 whole, then 04, 05, 06, 07. One case per invocation (`--case '0N*'`) — the
   runner's `--case` takes one glob and does not understand a bracket range.
3. Only then read the Δ column as meaning anything.

## Calibration status (superseded by the rewrite above)

Piloted 2026-09-17 at `--runs 1`: seven cases, fourteen runs, 27 minutes, $4.17. Every case
scored 1.00 with the plugin; mean Δ +0.57. Kits from cases 01 and 03 were read by hand and the
judge's verdicts on them were fair. A full suite at the cases' own `runs: 3` is roughly three
times that pilot — about $12 and an hour and a half.

Three things to know before reading a Δ from this suite:

- **Δ in cases 01, 02 and 05 measures kit existence, not kit quality.** Without the plugin the
  model writes no kit at the expected path, so the content graders never run in that arm. They
  earn their keep inside the with-arm, where they catch a kit that regresses.
- **Case 03 does not discriminate.** Over three runs per arm both arms scored 1.00: a bare model
  also spots that the catalogue page is open to everyone while the endpoint is admin-only. It is
  kept as a regression guard, not as evidence of what the plugin adds. Do not tune it until Δ
  turns positive — that would make it a vanity metric.
- **Runs vary.** One with-plugin run of case 03 produced no kit at all where the next three
  produced good ones. Read a single run as noise; `runs: 3` is the floor for a reason.

The runner warns on every kit that llm judges are noisy on inputs this long (12–17k characters).
Where a check can be written as a regex over the kit, prefer that to a rubric.
