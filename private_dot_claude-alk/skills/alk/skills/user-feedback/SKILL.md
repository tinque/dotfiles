---
name: user-feedback
description: Use when the user pastes a raw report from a person to be filed as GitHub issues in an ALK repo (e.g. "/alk:user-feedback <pasted email>", "/user-feedback", "voilà un retour utilisateur", "j'ai reçu ce mail, tu peux en faire des issues ?", a screenshot of a customer message). Groups it into the problems the person actually has, checks each against existing issues and recent fixes, and proposes issues to create or comment on before creating anything. Not for feedback about Claude Code itself (the built-in /feedback).
---

# Turn a raw user report into issues

`$ARGUMENTS`, or whatever the user pasted or screenshotted with it, is a message
from a real person: a contact-form email, a WhatsApp message, a support ticket.
Get it into GitHub without losing what makes it useful, and without opening a
duplicate. No report to work from: stop and ask for it; do not go hunting through
mailboxes or logs.

The repo is the one you are in (`gh repo view --json nameWithOwner`). Read its
**feedback profile**, `.claude/user-feedback.md`, first if it exists: it names the
issue template, the labels, the vocabulary, and any extra step (an ideas board,
locales). The profile outranks this skill. No profile: use the defaults below.

## The two rules that shape everything else

**One theme per issue, and a theme is a problem as the person lives it**: the
unit the reporter would recognise, and could tell you is solved. It is not the
unit of delivery (a PR is): one issue can take several PRs and its reading can
name several causes, so "these could be fixed separately" is never on its own a
reason to file separately.

**The verbatim is the evidence.** Paste their own words into the issue; never
replace them with your summary. "it just says it can't connect" once revealed
that an error message was lying; a paraphrase would have thrown that away. Your
reading goes _underneath_ the quote, clearly separated.

## 1. Group, and say how you grouped

List the themes you found in one short message, before touching GitHub, each with
the passage it comes from. Start from the reporter's own grouping: a paragraph,
an "in the same vein", an "also" is them telling you what belongs together.

Split only when:

- **Two troubles, not one**: they would not call it the same problem, and solving
  one would leave them no better off on the other.
- **It contradicts something already shipped**: a regression, or a fix that did
  not hold, is a different fact ("we believed this was done") and must not wait
  inside a request for something new.
- **Part of it already has a home**: comment on that issue (step 3), file the rest.

Never a reason on its own: the causes live in different files, one half is a bug
and the other a design question, one part is quicker. That is a horizontal slice:
each piece is real work and none means anything to the person alone. Too coarse
buries one problem under another; too fine strips each piece of its context.
Unsure: keep it together, say so, let the user decide.

## 2. Check each theme against what already exists

```bash
gh issue list --state all --limit 40 --search "<keywords>"
```

Search on the person's own words and on the feature name, not only your label.
A **closed** match matters as much as an open one: we believe we shipped it and
they still hit it, which is more urgent than a new report. Say so explicitly.

## 3. Decide each theme's fate

| What it is               | What to do                                                                                         |
| ------------------------ | -------------------------------------------------------------------------------------------------- |
| Already recorded, open   | **Comment on that issue**, no second one: the comment count is how "five people said this" shows. |
| Already recorded, closed | Say so, ask the user whether to reopen or file fresh. Do not decide alone.                         |
| Already fixed since      | **File nothing.** Say which PR shipped it and whether the person has been told.                    |
| New                      | Draft a new issue.                                                                                 |

**"Already fixed since" is the one that catches you out**: the report is older
than the fix, and there was never an issue, only a commit. For any theme that
reads like a defect, check it is still true before drafting:
`/usr/bin/git log --oneline -30 origin/main` and the recently merged PRs. That
theme needs a reply to the person, not a ticket.

Type of a new issue: **Bug** (broken, should work), **Feature** (something clear
that does not exist), or **no type** (an observation, a confusion, a preference,
not yet actionable). No type is the honest choice, not a lesser one: untyped open
issues are the list of things heard and not planned. A theme carrying both a
defect and the question it raises takes the type of what would close it from the
reporter's side. No type is for a whole report with nothing to close, never for a
fragment split off an actionable one.

Labels (defaults; the profile may rename them):

- **`from-user`** when the report came from outside the team, and only then. It
  is provenance: somebody else's words and context. The team's own observations,
  even made while reading the code for a real report, do not get it.
- **`blocker`** only when the person genuinely cannot use the product until it is
  fixed, not when merely annoyed. Being unable to _leave_ counts (an account
  deletion that fails is a locked exit, and a data-protection question). Not
  clear from the report: ask, do not guess.

If a label does not exist in the repo, say so in the drafts and create it with
the issues (`gh label create from-user --description "Reported by someone outside the team"`).

## 4. Show the drafts, then stop

One message with every proposal: exact title, type (or "no type" and why),
labels, full body, and the comments you would post. Then **stop and wait** for
the user's go. Create nothing, not even the obvious one. This is a deliberate
exception to the autonomy contract: issues carry a person's words and contact.

Titles say what is wrong from the user's side, not the fix: "Setup gives no way
back to a previous step", not "Add back-navigation to onboarding".

## 5. Create what was approved

```bash
gh issue create --title "<title>" --label from-user --type Bug --body-file <file>
gh issue comment <N> --body-file <file>
```

Bodies go in files: the verbatim carries characters that do not survive a shell
argument. Then run the profile's **After filing** steps if any. Report the URLs
and which theme went where.

## The body

Follow the repo's template (default `.github/ISSUE_TEMPLATE/user-feedback.yml`
when it exists), in this order: the verbatim quote; who and how to reach them;
where and when it came from; what they were trying to do; your reading.

Then `- [ ] Told them it shipped`, **when they are owed a reply**: on anything
they asked for. It closes the loop: `label:from-user is:closed "- [ ] Told them"`
lists the people whose request shipped and who have not been told. Never tick it
yourself. It does not go on a fact they volunteered without asking for anything
(their use case, how they found us): a box nobody can tick turns that search into
noise.

## Personal data

Record the minimum that lets the user reply: a name and one address. Never copy
account identifiers, log excerpts tying them to other users, or anything about a
_different_ customer in the same thread. A report from a channel the user has not
mentioned, or naming someone other than the sender: flag it rather than filing it
silently. Check the repo is private before putting contact details in an issue
(`gh repo view --json visibility`); public repo: leave the contact out and say
where it is kept.
