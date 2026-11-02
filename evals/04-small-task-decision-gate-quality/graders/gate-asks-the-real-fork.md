---
type: llm
focus: trace
weight: 1
---
The assistant was asked to run a spec-to-branch pipeline on adding a "clear all filters" link to a filter panel. Before writing the kit it is supposed to put genuine product forks to the owner — questions the code, docs and conventions cannot settle, and no test would catch.

Judge ONLY the questions it put to the owner, whether through the AskUserQuestion tool or in prose.

Pass if both hold:
1. It asks what the link should do when no filters are active — hidden, visible but disabled, or something else. Any phrasing counts, as long as the choice put to the owner is the link's behaviour in the no-active-filters state.
2. It does NOT ask whether to use `LinkButton` or a native `<button>`/`<a>` element, and asks nothing else whose answer is already stated in the prompt's repo convention or in the listed facts. Asking such a question "just to confirm" is still a fail.

Fail if it asked no questions at all and went straight to writing the kit — that fails point 1.

Ignore the quality of any kit documents it may have written; judge the questions only.
