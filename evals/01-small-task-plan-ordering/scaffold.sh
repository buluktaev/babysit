#!/bin/bash
# Stages the small React app the case's facts describe, so the skill's scouts
# find real code instead of an empty directory.
set -eu

mkdir -p .claude src/hooks src/pages src/components

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

- Hooks live in `src/hooks/`, one hook per file, named export only.
- Components use function declarations, not arrow consts.
- Tests sit next to the file they cover, named `<file>.test.ts`.
EOF

cat > package.json <<'EOF'
{ "name": "products-app", "private": true, "type": "module" }
EOF

cat > src/hooks/useProductFilters.ts <<'EOF'
import { useState, useCallback } from 'react'

export type ProductFilters = {
  query: string
  topics: string[]
}

const EMPTY: ProductFilters = { query: '', topics: [] }

export function useProductFilters() {
  const [filters, setFilters] = useState<ProductFilters>(EMPTY)

  const setQuery = useCallback((query: string) => {
    setFilters((prev) => ({ ...prev, query }))
  }, [])

  const toggleTopic = useCallback((topic: string) => {
    setFilters((prev) => ({
      ...prev,
      topics: prev.topics.includes(topic)
        ? prev.topics.filter((t) => t !== topic)
        : [...prev.topics, topic],
    }))
  }, [])

  const resetFilters = useCallback(() => setFilters(EMPTY), [])

  return { filters, setQuery, toggleTopic, resetFilters }
}
EOF

cat > src/pages/ProductsPage.tsx <<'EOF'
import { useProductFilters } from '../hooks/useProductFilters'
import { FilterPanel } from '../components/FilterPanel'
import { ProductCard } from '../components/ProductCard'

export function ProductsPage() {
  const { filters, setQuery, toggleTopic, resetFilters } = useProductFilters()

  return (
    <main>
      <FilterPanel />
      <section aria-label="Products">
        {filters.topics.map((topic) => (
          <ProductCard key={topic} topic={topic} />
        ))}
      </section>
      <button type="button" onClick={resetFilters}>Reset</button>
      <input value={filters.query} onChange={(e) => setQuery(e.target.value)} />
      <span hidden>{String(toggleTopic.length)}</span>
    </main>
  )
}
EOF

cat > src/components/ProductCard.tsx <<'EOF'
import { useProductFilters } from '../hooks/useProductFilters'

export function ProductCard({ topic }: { topic: string }) {
  const { filters } = useProductFilters()
  return (
    <article data-active={filters.topics.includes(topic)}>
      <h3>{topic}</h3>
    </article>
  )
}
EOF

cat > src/components/FilterPanel.tsx <<'EOF'
import { useProductFilters } from '../hooks/useProductFilters'

const TOPICS = ['design', 'frontend', 'management']

export function FilterPanel() {
  const { filters, toggleTopic } = useProductFilters()

  return (
    <aside>
      {TOPICS.map((topic) => (
        <label key={topic}>
          <input
            type="checkbox"
            checked={filters.topics.includes(topic)}
            onChange={() => toggleTopic(topic)}
          />
          {topic}
        </label>
      ))}
    </aside>
  )
}
EOF

cat > src/hooks/useDebounce.test.ts <<'EOF'
import { describe, it, expect } from 'vitest'
import { renderHook, act } from '@testing-library/react'
import { useDebounce } from './useDebounce'

describe('useDebounce', () => {
  it('holds the previous value until the delay elapses', () => {
    const { result, rerender } = renderHook(({ v }) => useDebounce(v, 300), {
      initialProps: { v: 'a' },
    })

    rerender({ v: 'b' })
    expect(result.current).toBe('a')

    act(() => {
      vi.advanceTimersByTime(300)
    })
    expect(result.current).toBe('b')
  })
})
EOF

cat > src/hooks/useDebounce.ts <<'EOF'
import { useEffect, useState } from 'react'

export function useDebounce<T>(value: T, delayMs: number): T {
  const [debounced, setDebounced] = useState(value)

  useEffect(() => {
    const id = setTimeout(() => setDebounced(value), delayMs)
    return () => clearTimeout(id)
  }, [value, delayMs])

  return debounced
}
EOF
