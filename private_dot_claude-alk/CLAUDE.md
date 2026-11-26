# Global rules

## Autonomy Contract

The user does not review code. Work in full autonomy, end to end, by default:
branch, commit, push, open the PR, review it automatically, fix, wait for green CI,
merge, and deploy through the project's normal deploy path (production included).
Do not ask permission for any of these steps.

Two exceptions:

1. **"Test locally first."** When the user asks to test before merging ("je veux
   tester en local", "attends avant de merger", "laisse-moi tester"), stop once the
   PR is open and the change runs locally. Give the URL or steps to try it, then
   merge only after their go. This applies to that piece of work only.
2. **Blocking questions.** Ask only about decisions that are genuinely the user's
   (product choice, irreversible external effect, missing access). Group them in one
   message; give each 2-4 concrete options with a recommended one first. Once they
   answer, go back to full autonomy without asking again.

Never, even in autonomy:

- Commit on the local `main` of a primary checkout: other sessions share it. Work in a
  worktree (`claude -w`, `EnterWorktree`) and check the branch and `git status` before
  every commit.
- Force-push, `git reset --hard`, `git stash` (the stash is shared across worktrees),
  rewrite pushed history, or delete branches you did not create.
- Merge with red or pending CI, skip or weaken a failing test to get green, or pass
  `--no-verify`.
- Poll CI with `sleep` loops. Watch it with a background
  `rtk proxy gh pr checks <n> --watch` (the `rtk` hook rewrites a bare `gh … --watch`
  so that it returns at once) or with `Monitor`, and react when it finishes.

## Quality Gate (replaces human code review)

Before merging, every change must pass:

1. The project's full check command (tests, typecheck, lint, build), run fresh, with
   its output read: no success claim without that evidence.
2. An automated review of the PR diff with the `code-review` skill (level `medium`;
   `high` when the diff touches billing, payments, auth, permissions, database
   migrations, data deletion, infra or deploy config). Fix the real findings, rerun
   the checks, then merge.
3. For UI changes, look at the result in the browser (screenshot) before merging.

When a merged change comes back as a bug, add a regression test for it in the fix.

End every piece of work with a short report in the conversation language: what
shipped (PR links), where it is deployed, what was verified and how, what is left.

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
Talk to the user in French, including right after a context compaction.

## Custom Skills Layout

Custom skills are grouped into skills-directory plugins so they show up as
`/<prefix>:<skill>`:

- Generic ALK skills (any ALK repo): `~/.claude-alk/skills/alk/skills/<skill>/SKILL.md`
  (`/alk:…`).
- Project skills: `<repo>/.claude/skills/<prefix>/skills/<skill>/SKILL.md`, with
  `<repo>/.claude/skills/<prefix>/.claude-plugin/plugin.json` naming the prefix
  (`trupeo`, `prospection`, `finance`, `crenomi`, `assilva`).

Issues in every ALK repo are implemented with the generic `/alk:work-issue`
(batches with `/alk:factory`). What differs per repo (setup, isolation check,
issue shape, check command, traps) lives in that repo's `.claude/work-issue.md`
profile, not in a per-repo copy of the skill. The same pattern holds for user
reports: `/alk:user-feedback`, with specifics in `.claude/user-feedback.md`.

New custom skills go into the matching plugin, never loose in `.claude/skills/`.

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
