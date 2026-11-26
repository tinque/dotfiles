---
name: scenarios
description: Use when the user wants to write, review, update or bootstrap the acceptance scenarios of an ALK repo (trupeo, zibou, crenomi) (e.g. "/alk:scenarios", "/alk:scenarios propose", « écris un scénario pour l'inscription », « mets à jour les scénarios du jeu », « quels parcours ne sont pas couverts ? »). Turns journeys the user describes in their own words into scenarios in scenarios/*.md that an independent agent can run in a browser and judge, with no test syntax for the user to learn.
---

# Write the acceptance scenarios with the user

Scenarios are the user's definition of "it works", written as a person would
tell it: who, what they do, what they must see. The factory's scenario judge
(`scenario-judge` agent) plays them in a real browser against a PR's build and
says pass or fail, without seeing the code. They are the part of the factory the
user owns: workers never edit them.

The user knows the product, not test frameworks. **They talk; you write.** Talk
French with them; the files are English (repo language policy), and you read a
scenario back in French whenever they want to check it.

`$ARGUMENTS`: empty or a journey ("l'inscription", "un enfant joue") → write or
update that; `propose` → bootstrap; `review` → audit what exists.

## The format (scenarios/README.md is the reference)

One file per area (`scenarios/signup.md`, `scenarios/games.md`), one `##` block
per scenario:

```markdown
## S-ZIB-012 A parent sees the week's progress of one child

Status: active        <!-- draft until the user approved it; only active ones gate merges -->
Starting point: a parent account with one child, Lina (7), who played 3 games this week.
Device: phone

1. Sign in as the parent.
2. Open Lina's progress.
3. Switch to "This week".

Expected:
- The 3 games of the week are listed, newest first.
- Each shows its stars.
- Nothing from last week appears.
```

Rules that make a scenario judgeable:

- **Observable only.** What a person sees or can do on screen, in the words the
  UI shows (read the i18n files and routes for the real labels). No ids, no
  database, no "the API returns".
- **One journey, one outcome**, five to ten steps. Longer: split it.
- **The starting point is concrete** (accounts, data, device) so the judge can
  set it up: seeded account, sign-up, or the setup the repo profile describes.
- **Expected results are checkable without judgement calls**: "shows 3 games",
  not "looks good". Subjective wishes (tone, beauty) go to the issue, not here.
- Ids: `S-<REPO>-<nnn>` (`TRU`, `ZIB`, `CRE`), never reused; a retired scenario
  gets `Status: retired` and stays.

## Modes

- **One journey**: ask the user to tell it as they would to a friend; ask at
  most three questions (who, starting data, what proves success); write it; read
  it back in French; adjust; set `Status: active` only once they say it is right.
- **propose**: read the app (routes, screens, existing e2e tests) and list the
  5-10 journeys that matter most to the business (sign-up, the core loop,
  payment or limits, the main parent/admin view, account deletion). Draft them
  as `Status: draft`, show them in French, and activate the ones the user
  validates. Never activate on your own.
- **review**: list active scenarios that no longer match the app (labels, flows
  renamed), journeys with none, duplicates; propose the edits.

## Landing them

Work in a worktree, branch `chore/scenarios-<topic>`, commit the `.md` files
only, open a PR, wait for green CI with a background
`rtk proxy gh pr checks <n> --watch`, squash-merge (Autonomy Contract). Report the
ids added or changed, in French.

## Optional: try one now

When the user wants to see a scenario run, start the app in this worktree as the
repo profile says, and dispatch the `scenario-judge` agent on it with the base
URL; relay its verdict and screenshots.
