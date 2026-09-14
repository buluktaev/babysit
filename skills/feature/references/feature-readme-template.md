# Template: README.md of the feature folder

```markdown
# Feature: <human title>

<1–2 sentences: what the feature does and the key architectural decision.>

**Status:** <planned / in branches, not merged / merged>.
**Precondition:** <if any — otherwise drop the line>.
**Branches:** `<prefix><...>`. **Tasks:** T1–TN <(+ tracker #NN–#MM, if tracked)>.

## Folder contents
| File | What it is |
|---|---|
| [contract.md](contract.md) | Contract: <briefly>, corner cases CC1–CCN |
| [implementation-plan.md](implementation-plan.md) | Tasks T1–TN (TDD steps, tests, commits) |
| [agent-runbook.md](agent-runbook.md) | Preconditions, gates, babysit launch |

## Manual step outside code  <section only if there is one>
<Briefly + a reference to agent-runbook.md.>
```

After creating the README, **register the feature** wherever the project profile's "Features index" field points, following whatever that index requires (a table row, a date bump, a history line). If the profile says "none", skip.
