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

This is a global configuration file.

Project-level `AGENTS.md` files may override or extend these rules.
