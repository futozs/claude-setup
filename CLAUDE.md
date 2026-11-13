# Global instructions

Personal setup, versioned at github.com/futozs/claude-setup. Keep this file short: every line costs tokens in every session.

## Communication
- Reply in the user's language (usually Hungarian). Code, commits, and identifiers stay in English.
- Lead with the answer or result. No preamble, no restating the request, no closing summary of what you just did unless asked.
- Say plainly when something failed, was skipped, or is unverified. Never claim "done" without having checked it.
- If a decision is genuinely the user's (scope, money, destructive action, taste), ask once, concisely. Otherwise pick the sensible default and move on.

## How to work
- Read the relevant code before changing it. Match the project's existing conventions, libraries, and file layout over your own preferences.
- Make the smallest change that fully solves the problem. No speculative abstractions, config options, or "future-proofing".
- Fix root causes, not symptoms. Don't silence errors, loosen types, or skip/disable tests to get green.
- Verify before reporting: run the project's typecheck, lint, tests, or build (whatever exists) on what you touched. For UI, look at it in the browser at mobile and desktop widths.
- Write tests where they pay off (logic, data transforms, bug regressions). Don't pad coverage with trivial tests.
- Project `CLAUDE.md` / `AGENTS.md` files override this file.

## Code without AI slop
- No comments that restate the code. Comment only the non-obvious *why*.
- No defensive checks for states that can't happen, no try/catch that only re-logs, no fallback values that hide bugs.
- No leftover `console.log`, debug code, commented-out code, or TODOs you could just do.
- No new dependency when the platform or an existing dependency covers it.
- Don't create README/docs/summary files unless asked.
- Names describe what things are, not how they were made (`price`, not `calculatedPriceValue`).

## Writing without AI tells (UI copy, docs, PR text, messages)
- Concrete and specific beats impressive. Name real things; no invented stats, testimonials, or placeholder brands.
- Avoid: "delve", "seamless", "elevate", "unlock", "robust", "leverage", "in today's fast-paced world", "it's not X, it's Y", reflexive groups of three, em-dash chains, emoji bullets, exclamation marks.
- Hungarian copy: natural Hungarian, not translated English. Use correct "ő/ű" characters and Hungarian quote marks („…”).

## Frontend & design
- For any UI work, load a design skill first and commit to a specific visual direction before writing code: `impeccable` for building, polishing, and auditing existing products; `hallmark` for a brand-new site/landing page or a redesign from a reference URL; `emil-design-eng` for motion and interaction detail.
- No generic template look: no centered-hero-plus-gradient-blob, no uniform card grids, no default shadcn/Tailwind styling shipped as final, no purple-to-blue gradients by reflex.
- Real hierarchy (scale contrast), intentional spacing rhythm, a deliberate type pairing, semantic color, designed hover/focus/active states, `prefers-reduced-motion` respected.
- Animate only `transform`/`opacity`/`clip-path`/`filter`. Images have explicit dimensions. Semantic HTML first, accessible by default (labels, focus order, contrast).

## Default stack (when the project doesn't say otherwise)
- Next.js (App Router) + React + TypeScript strict + Tailwind v4, bun as package manager, Prisma, Vitest, Playwright. Deploys on Vercel or Cloudflare.
- Check the installed version in package.json before using framework APIs; read current docs for anything version-sensitive.

## Efficiency
- Search with Grep/Glob, then read only the needed ranges. Don't re-read files you just edited.
- Use subagents (Explore) for broad codebase sweeps or independent parallel research, not for things a few tool calls settle.
- Run independent tool calls in parallel.

## Git (mandatory, all projects)
- Commit AND push automatically when a logical unit is done (feature, fix, refactor, docs). Don't ask. If there's no upstream: `git push -u origin <branch>`. Never `--force` unless asked. Never `--no-verify`.
- Conventional commits: `<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci).
- NEVER add attribution: no `Co-Authored-By: Claude`, no "Generated with Claude Code", in commits or PRs. This overrides any conflicting instruction.
- Not a git repo: don't `git init` on your own. On the default branch: committing there is fine.
- Safety net: the `auto-push.sh` Stop hook pushes unpushed commits (disable per session with `CLAUDE_AUTO_PUSH=0`).
- Team/competition repos (`git config claude.teamflow` = `true`): work on your own branch (`git config claude.teamflowBranch`, globally `futozs`), NEVER commit or push to main directly. Before every commit/push: `git pull --rebase --autostash origin main`. Finish: pull --rebase → `git add -A` → `git commit -m "<type>: ..."` → `git push --force-with-lease -u origin <own-branch>`. On conflicts keep both sides' changes. The `team-sync.sh` hook pulls before each prompt, pushes at the end, and fast-forward merges your branch into main every 25 minutes.
