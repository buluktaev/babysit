# feature skill — history

What changed in the pipeline and why, newest last. Step 10 and the run-log review write here, so a
fix carries its reason and the next session does not undo it. Not loaded with the skill: history
read on every run would cost tokens and teach nothing new.

| Date | Change | Why |
|---|---|---|
| 2026-11-02 | Contract §4 "Model delta": properties, relations, transitions; required whenever the feature touches the model; the reviewer checks code against it | A production project read against information-architecture and data-design practice: the model was never designed before code, and most defects grew from that — computed relations lost on cascade, dictionary labels copied as strings, unguarded status changes |
| 2026-11-02 | §5 gains D7 "Entry points"; the decision gate asks every time whether the key concept has a predictable second variant, and if so both branches go into §4, the deferred one into §9 with the data it needs | Same production project: deep links lost after sign-in, the central entity had no address; a single-variant role field cost six waves of rework |

## Ideas

Not scheduled, kept so they are not re-invented.
