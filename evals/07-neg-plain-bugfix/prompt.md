---
max_turns: 5
timeout_seconds: 90
allowed_tools: [Skill, Read, Glob, Grep]
model: sonnet
runs: 3
---
Small bug: `formatProductRate(null)` throws a TypeError instead of returning the placeholder "—". It should return "—" for both null and undefined, and format the number as before otherwise. Tell me the fix.
