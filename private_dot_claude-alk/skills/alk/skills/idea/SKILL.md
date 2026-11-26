---
name: idea
description: Use when the user brings an idea, a wish, a customer feedback or a problem for an ALK product (trupeo, zibou, crenomi) and wants it shipped (e.g. "/alk:idea les parents devraient voir la progression par semaine", « j'ai une idée pour zibou », « un client m'a dit que… », « on pourrait ajouter… »). Discusses it until the intent is clear, writes the issues and their acceptance scenarios, gets one go from the user, then hands the issues to /alk:factory to deliver to production.
---

# From an idea to production

The user does everything at ALK: product, specs, and now acceptance. This skill
is the **only step where they are needed**. Everything before the go is a
conversation; everything after it is the factory. Run this in the main session
(the strongest model: this is where expensive mistakes are made or avoided).

`$ARGUMENTS` is the idea, in the user's words. Nothing given: ask for it.
Speak French with the user. Everything written into a repository (issues,
scenarios) is English.

## 1. Understand before proposing

- Find the repo (ask if the idea could belong to several). Read its manual
  (`CLAUDE.md` / `AGENTS.md`), `.claude/work-issue.md`, and the scenarios in
  `scenarios/` that touch the same journey.
- Explore the code read-only to see what exists today: the screens, the data,
  what is already half there. Search open and closed issues
  (`gh issue list --state all --search "<words>"`) and recent merged PRs: the idea
  may already be filed, shipped, or contradicted by an earlier decision.
- A raw customer report rather than an idea: run `/alk:user-feedback` first; it
  files the evidence, and you continue from its issues.

Then say back, in a few lines: what the person would be able to do that they
cannot today, what you found in the code, and what you are unsure of.

## 2. Settle the decisions, once

List only the decisions that are genuinely the user's (behaviour, wording that
matters, scope, what to leave out, anything irreversible: data model, emails sent
to real people, pricing). Ask them **in one message**, each with 2-4 concrete
options and the recommended one first (AskUserQuestion when available). Do not
ask what the code or a sensible default answers; state those defaults instead.

## 3. Slice and write

- **Slice by what the user will be able to verify**, one theme per issue (a
  vertical slice: data + API + UI for one visible outcome), not by layer. Small
  enough that one worker ships it in one PR; when an issue would carry a
  migration, keep the migration and the feature that needs it together.
- Write each issue in the repo's issue shape (`.claude/work-issue.md`, Issue
  shape), English, sufficient on its own: context, goal, what to do, out of
  scope, **Done when** (checkable boxes), validation, ordering (which issue lands
  first, which files are shared).
- For each issue, write or update the **acceptance scenarios** it must satisfy,
  following `scenarios/README.md` (and the `/alk:scenarios` skill's rules): a new
  scenario per new behaviour, an edited one where behaviour changes. Each issue's
  Done when ends with `- [ ] Scenarios pass: S-XXX-012, S-XXX-013`.
- Pick the model per issue for the factory and say why in one word: `sonnet` by
  default, `opus` for a migration, money, auth, a concurrency or a cross-cutting
  change.

## 4. Show everything, get one go

One message, in French: the plan in a few lines (issues, order, models), then
each issue's title and Done when, then each scenario in full (translated back to
French for reading if the user prefers). Ask: « Je lance la livraison ? » with
options: deliver all (recommended), file only, change something.

This is the gate. Nothing is created before it.

## 5. File, then deliver

- Scenarios first: commit the new or changed `scenarios/*.md` in a worktree on a
  `chore/scenarios-<topic>` branch, open the PR, wait for green CI, squash-merge
  it (they are the spec, so they land before the code that must satisfy them).
- Create the issues (`gh issue create --body-file`, label `ready`), with
  blocking order expressed in each body's Ordering section.
- "Deliver all": run `/alk:factory <numbers> models:<n>=opus,...` in this
  session. "File only": stop and give the issue links.

## 6. Report

The factory's report, plus what changed in the scenarios. Anything the factory
held back comes back as a question with options, and the loop starts at step 2
for that question only.
