#!/bin/bash
# Stages the catalogue the saved-searches feature attaches to. The design the
# request points at is deliberately absent: there is no Figma integration here,
# so the frame id cannot be dereferenced by any means.
set -eu

mkdir -p .claude src/pages src/hooks src/components src/api

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

- Panels that slide in from the side reuse `src/components/Drawer.tsx`.
- User-scoped settings go through `POST /api/products/preferences`.
EOF

cat > package.json <<'EOF'
{ "name": "products-app", "private": true, "type": "module" }
EOF

cat > src/hooks/useProductFilters.ts <<'EOF'
import { useState, useCallback } from 'react'

export type ProductFilters = { query: string; topics: string[] }

const EMPTY: ProductFilters = { query: '', topics: [] }

export function useProductFilters() {
  const [filters, setFilters] = useState<ProductFilters>(EMPTY)

  const setQuery = useCallback((query: string) => {
    setFilters((prev) => ({ ...prev, query }))
  }, [])

  const applyFilters = useCallback((next: ProductFilters) => setFilters(next), [])

  return { filters, setQuery, applyFilters }
}
EOF

cat > src/components/Drawer.tsx <<'EOF'
import type { ReactNode } from 'react'

export function Drawer({
  open,
  side = 'right',
  children,
}: {
  open: boolean
  side?: 'left' | 'right'
  children: ReactNode
}) {
  if (!open) return null
  return (
    <aside className={`drawer drawer--${side}`} role="complementary">
      {children}
    </aside>
  )
}
EOF

cat > src/components/SaveButton.tsx <<'EOF'
export function SaveButton({ onSave }: { onSave: () => void }) {
  return (
    <button type="button" className="save-button" onClick={onSave}>
      Save
    </button>
  )
}
EOF

cat > src/api/preferences.ts <<'EOF'
export type Preferences = Record<string, unknown>

export async function savePreferences(prefs: Preferences): Promise<void> {
  const res = await fetch('/api/products/preferences', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify(prefs),
  })
  if (!res.ok) throw new Error('saving preferences failed')
}
EOF

cat > src/pages/ProductsPage.tsx <<'EOF'
import { useProductFilters } from '../hooks/useProductFilters'

export function ProductsPage() {
  const { filters, setQuery } = useProductFilters()

  return (
    <main>
      <input value={filters.query} onChange={(e) => setQuery(e.target.value)} />
      <section>{filters.topics.join(', ')}</section>
    </main>
  )
}
EOF
