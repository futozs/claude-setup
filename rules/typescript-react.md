---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.mjs"
---
# TypeScript / React / Next.js

- Strict types. No `any`, no `as` casts to silence errors, no `@ts-ignore`; use `unknown` + narrowing or fix the type. Validate external data (request bodies, env, third-party APIs) with zod or the project's validator at the boundary, then trust the types inside.
- Package manager: whatever lockfile exists (`bun.lock` → bun, `pnpm-lock.yaml` → pnpm, else npm). Never mix; never create a second lockfile.
- Next.js App Router: Server Components by default; `"use client"` only on the smallest interactive leaf. Fetch on the server, mutate with Server Actions or route handlers, revalidate with tags/paths. Read the installed Next version's docs before using caching APIs; they change between majors.
- React: derive state instead of syncing it with `useEffect`; effects are for external systems. Stable keys from data, never array index for reorderable lists. No premature `useMemo`/`useCallback` (React Compiler may already handle it).
- Prisma: select only the fields you need, avoid N+1 (use `include`/`select` or batched queries), run `prisma generate` after schema edits, create migrations with `prisma migrate dev --name <what>`.
- Secrets only from env, never in client bundles (`NEXT_PUBLIC_` is public).
- Verify with the project's own scripts: `typecheck`/`tsc --noEmit`, `lint`, `test`, `build`.
