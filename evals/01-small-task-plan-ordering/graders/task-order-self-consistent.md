---
type: llm
focus: {source: file, path: docs/features/catalog-filters-rename/task.md}
weight: 1
---
This document is a babysit "small task" kit: numbered tasks (T1, T2, …) that a worker executes strictly in order, one at a time, committing after each. The worker sees only this document and the repository as it stands when its own task starts.

Judge ONLY the execution-order consistency of the task list. Pass if all of these hold:

1. No task refers to the symbol `useCatalogFilters` or the path `src/hooks/useCatalogFilters.ts` as something that already exists, unless that same task performs the rename or an earlier-numbered task in this document performs it.
2. No task refers to `useProductFilters` or `src/hooks/useProductFilters.ts` as still present after an earlier-numbered task has renamed it away.
3. Every task that touches a call site (`ProductsPage.tsx`, `ProductCard.tsx`, `FilterPanel.tsx`) either performs the rename itself, comes after the task that performs it, or states the rename explicitly as its own precondition.
4. Executing the tasks in the given order never leaves the repository in a state where a call site imports a symbol that no task has created yet.

Fail if any single task assumes a rename, move, or deletion that neither it nor an earlier-numbered task performs. Name the offending task number and quote the line in your reasoning.
