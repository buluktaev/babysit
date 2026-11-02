#!/bin/bash
# Stages the collision the case is about: a catalogue page every signed-in user
# reaches, a selection bar so far used only on admin pages, and an archive
# endpoint the server restricts to admins.
set -eu

mkdir -p .claude src/pages src/components src/routes src/api server/api

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

- Route-level access control lives in `src/routes/`, never inside a page component.
- Shared UI comes from `src/components/`; do not fork a component to change one behaviour.
EOF

cat > package.json <<'EOF'
{ "name": "products-app", "private": true, "type": "module" }
EOF

cat > src/routes/AdminRoutes.tsx <<'EOF'
import { RequireRole } from './RequireRole'
import { ProductsAdminPage } from '../pages/admin/ProductsAdminPage'

export function AdminRoutes() {
  return (
    <RequireRole role="admin">
      <ProductsAdminPage />
    </RequireRole>
  )
}
EOF

cat > src/routes/RequireRole.tsx <<'EOF'
import type { ReactNode } from 'react'
import { useCurrentUser } from '../hooks/useCurrentUser'

export function RequireRole({ role, children }: { role: string; children: ReactNode }) {
  const user = useCurrentUser()
  if (user?.role !== role) return null
  return <>{children}</>
}
EOF

cat > src/routes/AppRoutes.tsx <<'EOF'
import { ProductsPage } from '../pages/ProductsPage'
import { AdminRoutes } from './AdminRoutes'

// The catalogue is reachable by every signed-in user: no role guard wraps it.
export function AppRoutes() {
  return (
    <>
      <ProductsPage />
      <AdminRoutes />
    </>
  )
}
EOF

mkdir -p src/hooks src/pages/admin
cat > src/hooks/useCurrentUser.ts <<'EOF'
export type CurrentUser = { id: string; role: 'member' | 'admin' }

export function useCurrentUser(): CurrentUser | null {
  return globalThis.__currentUser ?? null
}
EOF

cat > src/components/BulkActionBar.tsx <<'EOF'
import type { ReactNode } from 'react'

// Used so far only on admin pages.
export function BulkActionBar({
  selectedIds,
  children,
}: {
  selectedIds: string[]
  children?: ReactNode
}) {
  if (selectedIds.length === 0) return null
  return (
    <div role="toolbar">
      <span>{selectedIds.length} selected</span>
      {children}
    </div>
  )
}
EOF

cat > src/components/ConfirmModal.tsx <<'EOF'
export function ConfirmModal({
  title,
  onConfirm,
  onCancel,
}: {
  title: string
  onConfirm: () => void
  onCancel: () => void
}) {
  return (
    <dialog open>
      <h2>{title}</h2>
      <button type="button" onClick={onConfirm}>Confirm</button>
      <button type="button" onClick={onCancel}>Cancel</button>
    </dialog>
  )
}
EOF

cat > src/pages/ProductsPage.tsx <<'EOF'
import { useState } from 'react'

// The public-facing catalogue. Any signed-in user lands here.
export function ProductsPage() {
  const [products] = useState<{ id: string; name: string }[]>([])

  return (
    <main>
      <h1>Products</h1>
      <ul>
        {products.map((product) => (
          <li key={product.id}>{product.name}</li>
        ))}
      </ul>
    </main>
  )
}
EOF

cat > src/pages/admin/ProductsAdminPage.tsx <<'EOF'
import { useState } from 'react'
import { BulkActionBar } from '../../components/BulkActionBar'

export function ProductsAdminPage() {
  const [selectedIds, setSelectedIds] = useState<string[]>([])

  return (
    <main>
      <h1>Products — admin</h1>
      <BulkActionBar selectedIds={selectedIds} />
      <button type="button" onClick={() => setSelectedIds([])}>Clear</button>
    </main>
  )
}
EOF

cat > src/api/products.ts <<'EOF'
export async function bulkArchiveProducts(ids: string[]): Promise<void> {
  const res = await fetch('/api/products/bulk-archive', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ ids }),
  })
  if (!res.ok) throw new Error('bulk archive failed')
}
EOF

cat > server/api/products.py <<'EOF'
"""Product endpoints."""

MAX_BULK_IDS = 50


@router.post("/api/products/bulk-archive")
@require_role("admin")
def bulk_archive(payload: BulkArchivePayload):
    """Archive several products at once. Admins only.

    Rejects more than MAX_BULK_IDS ids in one call.
    """
    if len(payload.ids) > MAX_BULK_IDS:
        raise BadRequest(f"at most {MAX_BULK_IDS} ids per call")
    archived = archive_products(payload.ids)
    return {"archived": archived}
EOF
