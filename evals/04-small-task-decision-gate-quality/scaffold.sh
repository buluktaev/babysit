#!/bin/bash
# Stages the filter panel, the existing reset-all helper, and the design-system
# link component whose use is already settled by convention — so the only open
# question left is a product one.
set -eu

mkdir -p .claude src/components src/hooks src/design-system

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

- Every interactive text link uses `LinkButton` from `src/design-system/LinkButton.tsx`.
  Native `<button>` and `<a>` tags are never used directly in feature code.
- Spacing and typography come from the design system; features add no new tokens.
EOF

cat > package.json <<'EOF'
{ "name": "products-app", "private": true, "type": "module" }
EOF

cat > src/design-system/LinkButton.tsx <<'EOF'
import type { ReactNode } from 'react'

export function LinkButton({
  onClick,
  children,
}: {
  onClick: () => void
  children: ReactNode
}) {
  return (
    <button type="button" className="ds-link-button" onClick={onClick}>
      {children}
    </button>
  )
}
EOF

cat > src/hooks/useProductFilters.ts <<'EOF'
import { useState, useCallback } from 'react'

export type ProductFilters = { query: string; topics: string[] }

const EMPTY: ProductFilters = { query: '', topics: [] }

export function useProductFilters() {
  const [filters, setFilters] = useState<ProductFilters>(EMPTY)

  const toggleTopic = useCallback((topic: string) => {
    setFilters((prev) => ({
      ...prev,
      topics: prev.topics.includes(topic)
        ? prev.topics.filter((t) => t !== topic)
        : [...prev.topics, topic],
    }))
  }, [])

  // Clears every active filter at once.
  const resetFilters = useCallback(() => setFilters(EMPTY), [])

  const activeFilters = [
    ...(filters.query ? ['query'] : []),
    ...filters.topics,
  ]

  return { filters, activeFilters, toggleTopic, resetFilters }
}
EOF

cat > src/components/FilterPanel.tsx <<'EOF'
import { useProductFilters } from '../hooks/useProductFilters'

const TOPICS = ['design', 'frontend', 'management']

export function FilterPanel() {
  const { filters, activeFilters, toggleTopic } = useProductFilters()

  return (
    <aside>
      <span hidden>{activeFilters.length} active</span>
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

cat > src/components/MobileFilterSheet.tsx <<'EOF'
import { useProductFilters } from '../hooks/useProductFilters'
import { LinkButton } from '../design-system/LinkButton'

export function MobileFilterSheet() {
  const { resetFilters } = useProductFilters()

  return (
    <div role="dialog">
      <LinkButton onClick={resetFilters}>Reset</LinkButton>
    </div>
  )
}
EOF
