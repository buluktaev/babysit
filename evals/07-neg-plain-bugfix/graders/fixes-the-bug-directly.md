---
type: llm
focus: last_message
weight: 1
---
The user reported a small null-handling bug in one function and asked for the fix.

Pass if the assistant addresses the bug directly — the guard it would add, or the corrected function — treating this as a one-file change. Asking a single short clarifying question about the function's location or current shape is acceptable, as long as the answer is not a planning process.

Fail if it starts a multi-phase pipeline instead: asking for a project profile file, announcing a triage lane, writing a behaviour contract, a task plan or a runbook, or dispatching subagents before addressing the bug.
