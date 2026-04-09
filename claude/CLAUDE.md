# Workflow

## Branching

- **Never commit to `main` directly.** All work happens on feature branches.
- All feature work MUST be done in a **git worktree**. This keeps the main checkout clean and runnable. Use `isolation: "worktree"` when dispatching subagents.
- **Never read or write files in the main checkout when doing feature work.** All edits must go to the worktree path only. The main checkout must remain unmodified at all times.
- Branch naming: `claude/<short-description>`.

## Development cycle

1. Create a worktree and branch from `main`.
2. Implement the change.
3. Run the project's tests/build before creating a PR. Each project's CLAUDE.md specifies the command.
4. Create a PR against `main` with `gh pr create`. Include what changed and test results.
5. When review feedback arrives, push fixes to the **same branch**. The review bot re-reviews automatically on push.
6. Squash-merge when approved.

## PR review comments

Use `gh api repos/{owner}/{repo}/pulls/{N}/comments` to fetch line-level review comments. `gh pr view --json comments` only returns top-level conversation comments.
