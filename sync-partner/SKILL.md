---
name: sync-partner
description: Sync full session context with a hackathon teammate via a shared GitHub repo. Writes your progress update, reads your partner's latest update, and displays a clean side-by-side summary. Use when you want to share what you've built, your decisions, and what's next — or read what your partner has been doing. Invoke as /sync-partner [partner-username].
argument-hint: [partner-github-username]
allowed-tools: Bash(*), Read, Write, Edit
---

# Sync Partner

Share full session context with your hackathon teammate.

Partner username: **$ARGUMENTS**

## Prerequisites Check

Before doing anything else, verify the environment is ready:

1. Confirm `$ARGUMENTS` is not empty. If it is, stop and say:
   > Usage: `/sync-partner <partner-username>` — e.g. `/sync-partner bob`

2. Confirm `git` is available: `git --version`

3. Detect the shared repo root. Try these in order:
   - If the current working directory contains a `collab/` folder, use it as-is
   - Run `git rev-parse --show-toplevel` in cwd — if it succeeds and `collab/` exists inside, use that root
   - If neither succeeds, ask the user: "What is the path to your shared hackathon repo? (e.g. ~/projects/hackathon-collab)"
   
   Store this as `REPO_ROOT`.

4. Detect username:
   ```bash
   git -C "$REPO_ROOT" config user.name 2>/dev/null || echo "$USER"
   ```
   Clean to a lowercase, hyphen-safe slug (e.g. "Alice Chen" → "alice-chen", "alice" → "alice").
   Store as `MY_NAME`.

5. Store partner username from `$ARGUMENTS` as `PARTNER_NAME`.

## Step 1 — Pull Latest Changes

```bash
git -C "$REPO_ROOT" pull --rebase --autostash
```

If this fails with a merge conflict:
- Report: "Git pull failed with conflicts. Please resolve conflicts in `$REPO_ROOT` first, then re-run `/sync-partner`."
- Stop. Do not proceed.

If it fails because there is no remote (`fatal: No remote`):
- Report: "No git remote configured. Set one with `git remote add origin <url>` in `$REPO_ROOT`."
- Stop.

## Step 2 — Gather Session Context

Read the current conversation and workspace to build a rich picture of this session. Synthesize across ALL of these sources — do not skip any:

### A. Skills Used This Session
- List every `/skill-name` that was invoked in this conversation
- Note which tools were called most (Bash, Write, Read, Edit, etc.)

### B. Thinking and Decisions
- Key architectural or design decisions made this session
- Trade-offs considered and why a particular approach was chosen
- Open questions or unresolved debates
- Any pivots or course corrections

### C. What Was Done (Completed Work)
- Concrete tasks completed: features built, bugs fixed, tests written, docs added
- What actually works and is verified
- What was tried and abandoned (and why)

### D. What Is Next (TODOs and Blockers)
- The most important next step (the single thing to do right now)
- Secondary TODOs in priority order
- Blockers: things that cannot proceed without input, a fix, or a partner's help
- Integration points that require the partner's awareness

### E. Files Changed
- Run: `git -C "$REPO_ROOT" diff --name-only HEAD~5..HEAD 2>/dev/null || git -C "$REPO_ROOT" status --short`
- Also note files edited in this conversation that are not yet committed
- For each file: one line on what changed and why

## Step 3 — Create Directory If Needed

```bash
mkdir -p "$REPO_ROOT/collab/$MY_NAME"
```

## Step 4 — Write Update File

Write to `$REPO_ROOT/collab/$MY_NAME/update.md` using the template below.
Replace every placeholder with real content gathered in Step 2. Do not leave any section blank — if a section genuinely has nothing, write "None this session."

Template:

```markdown
# Session Update — $MY_NAME

_Last synced: <ISO 8601 timestamp from `date -u +"%Y-%m-%dT%H:%M:%SZ"`>_

---

## What I Did

<!-- Concrete completed work: features shipped, bugs fixed, tests written, integrations done -->

_FILL IN FROM STEP 2C: What was actually completed_

## Skills Used

<!-- List Claude Code skills invoked, key tools used, notable commands run -->

_FILL IN FROM STEP 2A: Skills and tools used_

## Thinking and Decisions

<!-- Architecture choices, trade-offs, pivots, and the reasoning behind them -->

_FILL IN FROM STEP 2B: Key decisions and reasoning_

## What Is Next

### Immediate (next action)
_FILL IN FROM STEP 2D: Single most important next step_

### Queued TODOs
_FILL IN FROM STEP 2D: Priority-ordered list of secondary tasks_

### Blockers
_FILL IN FROM STEP 2D: What is stuck or needs partner's help_

## Files Changed

_FILL IN FROM STEP 2E: File paths with one-line summary of changes_

---
_Session context captured by /sync-partner_
```

## Step 5 — Commit and Push

```bash
git -C "$REPO_ROOT" add "collab/$MY_NAME/update.md"
git -C "$REPO_ROOT" commit -m "sync: $MY_NAME session update $(date -u +%Y-%m-%dT%H:%M:%SZ)"
git -C "$REPO_ROOT" push
```

If `git push` fails:
- Try `git -C "$REPO_ROOT" pull --rebase && git -C "$REPO_ROOT" push`
- If still failing, report the exact error and say: "Your update was saved locally at `collab/$MY_NAME/update.md` but could not be pushed. Check your remote access and try again."
- Continue to Step 6 regardless — read the partner's file from local disk.

## Step 6 — Read Partner's Update

Check if the partner file exists:

```bash
ls "$REPO_ROOT/collab/$PARTNER_NAME/update.md" 2>/dev/null
```

If the file does not exist:
- Report: "No update from $PARTNER_NAME yet. They haven't run `/sync-partner` yet, or their push hasn't landed. Your update is published — they'll see it when they sync."
- Display your own update summary (Step 7, your side only) and stop.

If the file exists, read it fully using the Read tool:
```
Read $REPO_ROOT/collab/$PARTNER_NAME/update.md
```

Also check when it was last modified:
```bash
git -C "$REPO_ROOT" log -1 --format="%ar" -- "collab/$PARTNER_NAME/update.md" 2>/dev/null || stat -f "%Sm" "$REPO_ROOT/collab/$PARTNER_NAME/update.md" 2>/dev/null || stat --format="%y" "$REPO_ROOT/collab/$PARTNER_NAME/update.md" 2>/dev/null
```

## Step 7 — Display Side-by-Side Summary

Present a clean, readable summary. Use this layout:

---

```
╔══════════════════════════════════════════════════════════════╗
║              HACKATHON SYNC                                 ║
╠══════════════════════════════════════╦═══════════════════════╣
║  YOU ($MY_NAME)                      ║  PARTNER ($PARTNER_NAME) ║
╚══════════════════════════════════════╩═══════════════════════╝
```

### What Was Done

**You:**
- _3-5 bullets from your What I Did section_

**$PARTNER_NAME** _(updated <relative time>)_:
- _3-5 bullets from partner's What I Did section_

---

### Thinking and Decisions

**You:**
- _2-3 key decisions/reasoning points_

**$PARTNER_NAME:**
- _2-3 key decisions/reasoning points from their file_

---

### What Is Next

**You — Next action:** _your immediate next step_
**You — Blockers:** _your blockers, or "None"_

**$PARTNER_NAME — Next action:** _their immediate next step_
**$PARTNER_NAME — Blockers:** _their blockers, or "None"_

---

### Files Changed

**You:** _comma-separated file list or short summary_
**$PARTNER_NAME:** _comma-separated file list or short summary_

---

### ⚠️ Potential Conflicts or Overlaps

Scan both file lists and next-steps for overlap. If any file appears in both lists, or if both people are working toward the same area:

> **Heads-up:** Both of you touched `<file>` / are working on `<area>`. Coordinate before the next push.

If no overlap exists, omit this section entirely.

---

### Skills Used (Combined)

List all unique skills used by both of you this session — useful for the team's retrospective.

---

After displaying the summary, add one natural-language synthesis paragraph:

> _Both of you are [making good progress / heading toward a conflict / in sync / diverging on X]. Suggested coordination: [one concrete action if needed]._

## Error Handling

| Situation | Action |
|---|---|
| `$ARGUMENTS` is empty | Stop, show usage |
| No `collab/` and no git repo found | Ask user for repo path |
| `git pull` has merge conflicts | Stop, ask user to resolve |
| No git remote configured | Stop, explain how to add remote |
| Partner file does not exist | Show your summary only, explain partner hasn't synced yet |
| `git push` fails after retry | Save locally, warn user, continue to display |
| Partner file is very old (>2 hours) | Add note: "Partner's update is from <time> — may be stale" |

## Quality Gate

Before finishing, confirm:
- Your `update.md` contains real content (no placeholder text left behind)
- The side-by-side summary is legible and scannable in under 30 seconds
- Any file overlap or blocker collision is highlighted
- The partner staleness note is shown if their file is older than 2 hours
