# Global rules

## Git Safety Rules

The agent MUST NOT perform any Git history mutation without explicit user request.

Prohibited by default:

- `git commit`
- `git push`
- `git rebase`
- `git merge`
- `git branch`
- `git tag`
- opening pull requests

These actions require explicit user confirmation.

If code changes are made:

1. Apply the modifications
2. Present a clear summary or diff
3. Wait for the user to request a commit

Never assume a commit is desired.

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
