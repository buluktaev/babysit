---
type: llm
focus: {source: file, path: docs/features/bulk-archive-products/task.md}
weight: 1
---
This is a babysit "small task" kit for adding a bulk-archive action to a product catalogue page.

The situation the kit was written against, which it was NOT told to worry about: the catalogue page is reached by every signed-in user and no role guard wraps it, while the backend endpoint the action calls is admin-only (`requireRole('admin')`). So a non-admin can see whatever the page renders, and their click would be refused by the server.

Judge ONLY whether the kit surfaces that collision. Pass if it does both:
1. States what a non-admin sees — the action hidden, disabled, absent, or a stated decision that it renders for everyone and the server refusal is what the user gets.
2. Names where the restriction lives or must be added — the backend `requireRole('admin')` guard, a new client-side role check, or an explicit note that the enforcement point is unsettled and must be decided.

Fail if the kit treats the action as if every viewer of the page may perform it, never mentions roles or who may archive, or silently assumes the page is admin-only when the facts say it is not.

Judge only what is written in the document. Do not credit a sweep heading with no content under it.
