# sync-partner 🔄

**Share full session context with a hackathon teammate via a shared GitHub repo.**

A Claude Code skill that lets two teammates see exactly what the other accomplished, their thinking, blockers, and next steps — with one command.

---

## Why sync-partner?

When working on a hackathon in parallel:
- ❌ Slack updates are fragmented and get lost
- ❌ Commits don't show *why* you made decisions
- ❌ You don't know what your partner is blocked on
- ✅ `/sync-partner bob` captures everything in one structured update

## Features

✨ **What It Syncs**
- What you accomplished (concrete tasks, features, fixes)
- Skills you used (Claude Code skills invoked this session)
- Thinking & decisions (architecture, trade-offs, reasoning)
- What's next (immediate TODOs, blockers, integration points)
- Files changed (git diff automatically detected)

**Smart Side-by-Side View**
- See your progress vs. partner's progress at a glance
- Conflict detection (both working on same file? You get a warning)
- Staleness warnings (partner hasn't synced in 2+ hours?)

**Zero Friction**
- Git-based (no extra infrastructure)
- Path-scoped (merge conflicts are **structurally impossible**)
- Plain Markdown (readable on GitHub, in terminal, anywhere)

---

## Installation

### Quick Install (One-liner)

```bash
mkdir -p ~/.claude/skills/sync-partner && \
curl -o ~/.claude/skills/sync-partner/SKILL.md \
  https://raw.githubusercontent.com/rixav77/sync-partner/main/sync-partner/SKILL.md
```

### Manual Install

1. Clone this repo:
   ```bash
   git clone https://github.com/rixav77/sync-partner.git
   ```

2. Copy the skill:
   ```bash
   cp sync-partner/SKILL.md ~/.claude/skills/sync-partner/
   ```

3. Done! The skill is now available as `/sync-partner` in Claude Code.

---

## Setup (One Time)

### Step 1: Create Your Shared Hackathon Repo

One person (you or your partner) does this once:

```bash
# Create repo directory
mkdir -p ~/projects/hackathon-collab
cd ~/projects/hackathon-collab

# Initialize git
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Create collab skeleton (the skill will use this)
mkdir -p collab

# Push to GitHub (or your preferred git host)
git add .
git commit -m "init: hackathon collab skeleton"
git remote add origin https://github.com/YOUR-USERNAME/hackathon-collab.git
git push -u origin main
```

### Step 2: Both Clone It

```bash
git clone https://github.com/YOUR-USERNAME/hackathon-collab.git
cd hackathon-collab
git config user.name "Your Name"
```

That's it. You're ready to sync.

---

## Usage

### Run It

```bash
/sync-partner bob       # If you're Alice
/sync-partner alice     # If you're Bob
```

### What Happens

1. **Writes** your session update → `collab/your-name/update.md`
2. **Commits & pushes** to the shared repo
3. **Reads** partner's latest update
4. **Shows** a clean side-by-side summary with:
   - What each of you did
   - Thinking & decisions
   - Next steps & blockers
   - Files changed
   - ⚠️ Conflict warnings (if both touched the same file)

### Example Output

```
╔══════════════════════════════════════════════════════════════╗
║              HACKATHON SYNC                                 ║
╠══════════════════════════════════════╦═══════════════════════╣
║  YOU (alice)                         ║  PARTNER (bob)        ║
╚══════════════════════════════════════╩═══════════════════════╝

## What Was Done

**You:**
- Built login UI components
- Integrated auth middleware
- Set up user session store

**Bob** _(updated 23 minutes ago)_:
- Created database schema
- Wrote migrations
- Set up connection pooling

## Thinking and Decisions

**You:**
- Using JWT for stateless auth (scaling reason)
- Kept session store in-memory for MVP

**Bob:**
- PostgreSQL for strong ACID guarantees
- Connection pooling to handle load

## What Is Next

**You — Next action:** Implement API routes for login
**You — Blockers:** Need Bob's database schema to design endpoints

**Bob — Next action:** Connect Django to the DB
**Bob — Blockers:** None

## Files Changed

**You:** src/components/LoginForm.tsx, src/middleware/auth.ts, src/store/session.ts
**Bob:** db/migrations/001_init.sql, db/models.py, db/pool.py

---

⚠️ **Potential Conflicts or Overlaps**

**Heads-up:** Both of you touched `src/config.ts`. Coordinate before the next push.

---

_Both of you are in sync. No coordination needed right now. Keep shipping!_
```

---

## Workflow Tips

### Start of Each Session
```bash
git pull                    # Get partner's latest
/sync-partner your-partner  # Sync and see what they did
```

### End of Each Session
```bash
/sync-partner your-partner  # Write your update + read theirs
```

### When Blockers Appear
The summary shows **what's blocking you and your partner**. Message them on Slack/Discord to coordinate immediately.

### When Files Overlap
If the skill warns `⚠️ Both of you touched src/config.ts`:
- Don't push immediately
- Coordinate with partner first
- Merge carefully (it's a warning, not a blocker)

---

## How It Works

The skill uses **path-scoped git commits**, meaning:
- You only write to `collab/<your-name>/update.md`
- Partner only writes to `collab/<partner>/update.md`
- **Merge conflicts are structurally impossible** (different files)

Each update is a Markdown file with:
```
## What I Did
## Skills Used
## Thinking and Decisions
## What Is Next
  - Immediate (next action)
  - Queued TODOs
  - Blockers
## Files Changed
```

The skill reads your **live conversation** to populate these sections—no setup hooks required.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `Usage: /sync-partner <partner-username>` | You need to provide your partner's name, e.g., `/sync-partner bob` |
| "No update from bob yet" | Your partner hasn't run `/sync-partner` yet. Your update is published; they'll see it when they sync. |
| "Git pull failed with conflicts" | You have merge conflicts in your repo. Resolve them manually with `git status` and try again. |
| "No git remote configured" | You need to push to GitHub first. Run `git remote add origin <url>` in your hackathon repo. |
| Partner's update is stale (>2h) | They might be offline. Check with them on Slack/Discord. |

---

## Examples

See the `collab/example-alice/` and `collab/example-bob/` folders for sample update.md files.

---

## Contributing

Have ideas for improving sync-partner? 
1. Fork the repo
2. Edit `sync-partner/SKILL.md`
3. Test it: `cp sync-partner/SKILL.md ~/.claude/skills/sync-partner/` then run `/sync-partner`
4. Submit a PR

---

## License

MIT — Use it, fork it, share it.

---


