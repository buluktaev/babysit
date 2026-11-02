# feature skill — history

What changed in the pipeline and why, newest last. Step 10 and the run-log review write here, so a
fix carries its reason and the next session does not undo it. Not loaded with the skill: history
read on every run would cost tokens and teach nothing new.

| Date | Change | Why |
|---|---|---|
| 2026-11-02 | Contract §4 "Model delta": properties, relations, transitions; required whenever the feature touches the model; the reviewer checks code against it | A production project read against information-architecture and data-design practice: the model was never designed before code, and most defects grew from that — computed relations lost on cascade, dictionary labels copied as strings, unguarded status changes |

## Ideas

Not scheduled, kept so they are not re-invented.
