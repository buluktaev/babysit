---
type: llm
focus: {source: file, path: docs/features/live-facets-panel/contract.md}
weight: 1
---
This is a babysit behaviour contract. One of its sections is a "standing-dimensions sweep": seven dimensions — permissions, absent or stale data, failed dependency, empty, boundaries, repetition, entry points — each of which must be closed either with a concrete corner case or with a dismissal that states its reason.

Judge ONLY two of those dimensions, wherever in the document they are addressed.

A. Stale data. The contract must name both of these as distinct, concrete situations, each closed with a corner case or a reasoned dismissal:
   - the asynchronous embeddings reindex lag — a profile created or edited moments ago is not yet searchable;
   - the facet panel refetching while the user is reading it — counts changing under the user, or the previous counts being held during the refetch.
   One generic line such as "data may be stale" that names neither situation is a FAIL.

B. Repetition / concurrency. The contract must address at least one genuinely concurrent situation — two requests in flight at the same time, a cache race, or a second interaction arriving before the first resolves — and state what the observable behaviour must be. A corner case describing only actions that happen one after another, or a test that only exercises a sequential sequence, does NOT satisfy this.

Pass only if both A and B hold. Fail if either is missing, silently skipped, or closed with a dismissal that gives no reason. Quote the relevant lines in your reasoning.
