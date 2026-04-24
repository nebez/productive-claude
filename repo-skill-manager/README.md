# 🎛️ repo-skill-manager

Toggle Claude Code project-level skills on and off locally without touching git.

## The Problem

Teams share skills in `.claude/skills/` — checked into git, loaded into every Claude Code session. Each skill's name and description gets injected into the system prompt, costing tokens whether you use them or not. With 20+ skills, that's ~2,000 tokens of overhead per turn.

## How It Works

Uses `git skip-worktree` to let you empty SKILL.md files locally while git sees no changes. Disabling a skill empties its SKILL.md so Claude Code has nothing to load. Enabling restores the original content from HEAD.

## Install

```bash
# Copy the script somewhere gitignored in your repo
# .claude/bin/ is typically gitignored — check your .gitignore
mkdir -p .claude/bin
cp claude-skills .claude/bin/skills
chmod +x .claude/bin/skills

# One-time setup: mark all SKILL.md files as skip-worktree
.claude/bin/skills init

# Disable all team skills
.claude/bin/skills disable-all
```

## Usage

```bash
.claude/bin/skills list                  # show all skills and their status
.claude/bin/skills enable investigate    # restore one skill
.claude/bin/skills disable investigate   # empty one skill
.claude/bin/skills enable-all            # restore all (team mode)
.claude/bin/skills disable-all           # empty all (personal mode)
.claude/bin/skills sync                  # pick up new skills after git pull
.claude/bin/skills deinit                # undo everything, restore all files
```

## After `git pull`

If teammates add new skills, they won't have skip-worktree set yet. Run `sync` to catch them:

```bash
.claude/bin/skills sync
```

Sets skip-worktree on any new SKILL.md files and disables them.

## Uninstalling

```bash
.claude/bin/skills deinit
```

Restores all SKILL.md files to their git content and removes skip-worktree flags. Clean slate.
