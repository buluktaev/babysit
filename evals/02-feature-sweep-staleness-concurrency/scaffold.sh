#!/bin/bash
# Stages the catalogue app the case's facts describe: a facets fetch that runs
# once on mount, a debounced search box, a cache helper, and an embeddings
# reindex job that runs every ten minutes.
set -eu

mkdir -p .claude src/pages src/hooks src/lib src/api server/search migrations

cat > .claude/babysit.md <<'EOF'
# Project profile — babysit

## Repositories
| Repo | Path | Base branch | Gate command | Single-run test |
|---|---|---|---|---|
| app | . | main | echo "gates ok" | echo "single test ok" |

## Layout
- Feature kits: docs/features/<slug>/
- Features index: docs/features/README.md
- Side-findings register: docs/side-findings.md
- Run log: docs/run-log.md
- Incident log: docs/incident-log.md

## Durable knowledge
- Interview skill: none
- Glossary: docs/glossary.md
- Decision journal: docs/decisions.md

## Tracker
- Kind: none

## Policies
- Branch prefix: feature/
- Worktrees: no
- Commit trailers: none
- Changelog: no
- Final review: on
- Dev stand never to kill: none

## Terminology
- none
EOF

cat > CLAUDE.md <<'EOF'
# Conventions

- Data fetching goes through `src/api/`, never inline `fetch` in a component.
- Cache invalidation uses the helper in `src/lib/cache.ts`.
- Migrations are timestamped SQL files in `migrations/`.
EOF

cat > package.json <<'EOF'
{ "name": "products-app", "private": true, "type": "module" }
EOF

cat > src/hooks/useSearchDebounce.ts <<'EOF'
import { useEffect, useState } from 'react'

export const SEARCH_DEBOUNCE_MS = 300

export function useSearchDebounce(value: string): string {
  const [debounced, setDebounced] = useState(value)

  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), SEARCH_DEBOUNCE_MS)
    return () => clearTimeout(id)
  }, [value])

  return debounced
}
EOF

cat > src/lib/cache.ts <<'EOF'
type Entry<T> = { value: T; storedAt: number }

const store = new Map<string, Entry<unknown>>()

export function readCache<T>(key: string, maxAgeMs: number): T | undefined {
  const hit = store.get(key) as Entry<T> | undefined
  if (hit === undefined) return undefined
  if (Date.now() - hit.storedAt > maxAgeMs) {
    store.delete(key)
    return undefined
  }
  return hit.value
}

export function writeCache<T>(key: string, value: T): void {
  store.set(key, { value, storedAt: Date.now() })
}

export function invalidate(prefix: string): void {
  for (const key of store.keys()) {
    if (key.startsWith(prefix)) store.delete(key)
  }
}
EOF

cat > src/api/products.ts <<'EOF'
export type Facet = { value: string; count: number }

export async function fetchFacets(query: string): Promise<Facet[]> {
  const res = await fetch(`/api/products/facets?q=${encodeURIComponent(query)}`)
  if (!res.ok) throw new Error('facets request failed')
  return res.json()
}

export async function searchProducts(query: string) {
  const res = await fetch(`/api/products/search?q=${encodeURIComponent(query)}`)
  if (!res.ok) throw new Error('search request failed')
  return res.json()
}
EOF

cat > src/pages/ProductsPage.tsx <<'EOF'
import { useEffect, useState } from 'react'
import { useSearchDebounce } from '../hooks/useSearchDebounce'
import { fetchFacets, searchProducts, type Facet } from '../api/products'

export function ProductsPage() {
  const [query, setQuery] = useState('')
  const debouncedQuery = useSearchDebounce(query)
  const [facets, setFacets] = useState<Facet[]>([])
  const [results, setResults] = useState<unknown[]>([])

  // Facets are fetched once, on mount, and never refreshed after that.
  useEffect(() => {
    fetchFacets('').then(setFacets)
  }, [])

  useEffect(() => {
    searchProducts(debouncedQuery).then(setResults)
  }, [debouncedQuery])

  return (
    <main>
      <input value={query} onChange={(e) => setQuery(e.target.value)} />
      <aside>
        {facets.map((facet) => (
          <span key={facet.value}>{facet.value}: {facet.count}</span>
        ))}
      </aside>
      <section>{results.length} products</section>
    </main>
  )
}
EOF

cat > server/search/embeddings.py <<'EOF'
"""Semantic search over product profiles.

The embeddings index is rebuilt by a scheduled job, not on write: a profile
created or edited now becomes searchable only after the next pass.
"""

REINDEX_INTERVAL_MINUTES = 10


def reindex_profiles() -> int:
    """Rebuild embeddings for profiles changed since the last pass.

    Scheduled every REINDEX_INTERVAL_MINUTES minutes by the worker.
    """
    changed = _profiles_changed_since_last_pass()
    for profile in changed:
        _write_embedding(profile)
    return len(changed)


def search(query: str, limit: int = 20):
    return _nearest_neighbours(_embed(query), limit=limit)
EOF

cat > server/search/facets.py <<'EOF'
"""Facet counts for the product catalogue.

Counted live off the products table on every request; there is no cache table
for them yet.
"""


def facet_counts(query: str) -> list[dict]:
    rows = _count_by_topic(query)
    return [{"value": value, "count": count} for value, count in rows]
EOF

cat > migrations/20260101_000000_create_products.sql <<'EOF'
CREATE TABLE products (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    topic TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX products_topic_idx ON products (topic);
EOF
