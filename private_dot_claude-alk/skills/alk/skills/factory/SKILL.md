---
name: factory
description: Use when the user wants several GitHub issues of an ALK repo shipped in one go (e.g. "/alk:factory 512 518 530", "/alk:factory label:ready", « traite toutes les issues ready », « vide le backlog », « lance la factory »). Plans which issues can run side by side, dispatches one worktree-isolated worker per issue running /alk:work-issue (with the repo's .claude/work-issue.md profile), then reviews and merges the pull requests one at a time while watching main's CI and deploy.
---

# Run a batch of issues through the factory

You are the coordinating session. Workers implement; you plan, dispatch, merge
and report. Each worker runs `/alk:work-issue`, which reads the repo's work-issue profile
(`.claude/work-issue.md`). Read both first: the profile's setup, isolation check
and check command are the contract every worker follows, and the skill's
section 6 says a dispatched worker leaves the merge to you.

Under the global Autonomy Contract you merge and deploy without asking. Stop
and ask only for a decision that is genuinely the user's, with options.

## 1. Pick the issues

`$ARGUMENTS` holds issue numbers, or `label:<name>` (default `label:ready`), and
optionally `max:<n>` for the number of workers running at once (default 3).

```bash
gh issue list --label <name> --state open --json number,title,labels,body --limit 50
```

Read every issue. Drop, and list in the final report, any issue that is not
actionable as written: no acceptance criteria, an open question addressed to the
user, a decision it says is pending. Do not guess the missing part.

## 2. Plan the waves

Two pull requests that touch the same area can each be green and still break
each other once both land (see the repo's CLAUDE.md if it documents such a
case). So for each issue, write down the area it will touch: the modules, the
hooks, the API shapes, the migrations, read from the issue and a quick look at
the code. Then:

- Issues with disjoint areas run in parallel, up to `max`.
- Issues sharing an area run one after the other, the later one started from a
  `main` that already contains the earlier one.
- Database migrations: at most one migration-carrying issue in flight at a time.

Show the plan in a few lines (wave, issue, area), then start without waiting for
approval.

## 3. Dispatch the workers

One `Agent` per issue, `isolation: "worktree"`, `run_in_background: true`. The
prompt is a brief that starts with `Context:` (that marks it as dispatched, so
the worker leaves the merge to you) and carries:

- `/alk:work-issue <N>` as the instruction,
- what you learned while planning that the issue does not say (neighbouring
  issues in flight and the files they own, so the worker stays out of them),
- the reminder to stop and report rather than guess if the issue turns out to
  need a decision.

While workers run, do not poll them: you are notified when each finishes.

## 4. Merge one at a time

Take finished pull requests in wave order. For each one:

1. Read the worker's report and the PR body. A worker that stopped on a
   question: collect the question for the user, do not merge.
2. Rebase it on the current `origin/main` if `main` moved
   (`gh pr update-branch <n> --rebase` or in its worktree). If another PR of this
   batch touching the same area merged since it was cut, rerun the repo's full
   check command in its worktree before going further.
3. Run the `code-review` skill on the PR at `medium` (`high` for billing, auth,
   migrations, data deletion, infra or deploy config). Fix real findings in the
   PR's worktree, rerun the checks, push.
4. Wait for green CI with a background `rtk proxy gh pr checks <n> --watch`
   (a bare `gh … --watch` returns at once under the rtk hook; never a `sleep` loop), mark the PR ready, `gh pr merge <n> --squash --delete-branch`.
5. Watch `main`'s CI and the deploy run that follows until they finish. If
   either fails, stop merging, fix forward (or revert the merge commit through a
   new PR when the fix is not obvious), and only then continue.

Start the next wave's workers as soon as the area they depend on has merged.

## 5. Report

In French, short:

- shipped: issue, PR link, deployed or not;
- held back: issue and why (not actionable, waiting on a question, failed
  checks), with the question and suggested answers when there is one;
- anything you noticed in passing that deserves its own issue.

Remove the worktrees of merged PRs. A worktree whose PR is still open stays.

## Boundaries

- Never merge red or pending CI, never bypass a ruleset or a hook.
- Never commit on the primary checkout's `main`.
- If the user asked to test something locally first, that PR waits for their go.
