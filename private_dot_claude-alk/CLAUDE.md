# Global rules

## Git Delivery Workflow

A request to implement or change code is itself authorization to create a task branch, commit the requested changes, push that branch, and open a pull request. Do not ask for separate confirmation for those routine delivery steps when the conditions below are met.

This standing authorization applies only to Git repositories under `/Users/quentin/alk-innovations`. Outside that root, do not mutate Git history or create remote resources unless the user explicitly requests it.

For implementation work:

1. Inspect the worktree status, current branch, remote, default branch, and repository-specific instructions before editing.
2. Continue a suitable existing task branch or pull request when one exists. Otherwise, update remote refs and create a descriptively named task branch from the latest `origin/main`. Prefer an isolated worktree when unrelated work is present or another task may be in progress.
3. Never stash, reset, overwrite, or include pre-existing user changes. If they cannot be protected through isolation, stop and ask the user.
4. Implement the requested scope, run the repository's required checks, and review the final diff.
5. Stage only task-related files and create focused English commit(s), following repository conventions.
6. Push the task branch and open a pull request targeting `main`. Follow the repository's pull-request template and conventions. Open a ready-for-review PR when the work is complete and checks pass; use a draft PR when the work is intentionally incomplete or blocked.
7. Report the branch, commit(s), checks run, and pull-request URL.

For read-only requests such as analysis, explanation, audit, or review, do not create a branch, commit, push, or pull request. If the user explicitly asks for a patch without delivery or specifies another workflow, follow that request.

Safety boundaries:

- Never commit or push directly to `main`.
- Never force-push or rewrite published history.
- Never merge or close a pull request, delete a branch or worktree, create or delete a tag or release, deploy, or mutate shared/production infrastructure without an explicit user request.
- Never bypass repository hooks, required checks, branch protections, or review requirements.

## Planning and Specification Artifacts

The agent MUST NOT add, stage, track, or commit planning/specification artifacts unless the user explicitly names that exact documentation as something to commit.

This includes, but is not limited to:

- Superpowers planning documents
- implementation plans
- technical specs
- task breakdowns
- investigation notes
- generated design documents

When committing is explicitly requested, include only the documentation the user clearly specified. Exclude every other plan/spec/supporting document, even if it was created during the work.

## Language Policy

All repository artifacts MUST be written in English.

This includes:

- source code comments
- documentation
- commit messages
- pull request descriptions
- issue text
- changelogs
- design documents

Conversation language may vary, but repository content must always remain English.

## Claude Code Settings and Hooks

Global `$CLAUDE_CONFIG_DIR/settings.json` is the source of runtime safety defaults. Keep it synchronized through chezmoi whenever it changes.

Security and workflow guardrails:

- `permissions.deny` is intentional and must remain stricter than convenience defaults.
- Do not bypass protections for `.env`, secret directories, generated build output, destructive shell commands, or force-push operations.
- The `UserPromptSubmit` hook runs `codegraph prompt-hook` to inject codebase context when available.
- The `PreToolUse` Bash hook runs `rtk hook claude` to optimize shell output and reduce token usage.
- If a hook blocks an action, treat it as a safety signal; prefer a narrower, safer command rather than disabling the hook.

## Scope

This is a global Claude Code configuration file.

Project-level `CLAUDE.md` files may override or extend these rules.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->

@RTK.md
