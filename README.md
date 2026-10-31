# dotfiles

## Overview

This project seeks to provide a somewhat unified environment, regardless of
whether I'm running on bash, zsh, ksh, or even dash/sh on Linux, Solaris, or
OSX. zsh is where most of my work is done and is most feature rich.

### WARNING

There was a recent rename of files, which would break old symlinks created by
ln_dotfiles. This will need to be rerun to fix the links.

## *sh env files

The various .*shrc, .*profile, and .*logout files are sh specific and primarily
responsible for setting up the prompt for each shell. Each of these will also
source .shrc.common and .shrc.local (if present, not in this repo). The
.shrc.common and .shrc.local files should be written POSIX shell so that they
are portable to to the other *sh implementations.

## misc other files

.vim and .vimrc - Live and die by vi

.config/nvim - Neovim config that uses LazyVim as a base

.screenrc - tweaked for zsh, but other settings may be interesting to people

.Xdefaults - seems to be mostly ignored these days, but common enough that I
included it

.xinitrc - most display managers will ignore this, but if you ever run startx
from a vt, this might be useful

.claude/statusline.sh - status line for Claude Code, showing the model, a
context-usage meter, and the git repo:branch each session is actually working
in, truncated to fit the terminal. Requires jq. Nothing in it is configured by
hand - scope and plugin badges are discovered - but it is inert until referenced
from ~/.claude/settings.json, which is not in this repo since it carries
account-specific settings:

    "statusLine": { "type": "command", "command": "bash \"$HOME/.claude/statusline.sh\"" }

.claude/skills/model-routing - global skill telling Claude which model to hand
work to via subagents: haiku for broad searches and summarizing, sonnet for
everyday coding, opus for planning, hard debugging and reviews, fable as a last
resort. It assumes sonnet as the session default and opus as the advisor.

.claude/CLAUDE.md - global rules loaded into every Claude Code session:
verification honesty, review before push, CI must be green, comment style.
Project CLAUDE.md/AGENTS.md files override it.

Every machine's ~/.claude/settings.json should carry this shared baseline.
Keep machine-local choices (effortLevel, tui, notifications) out of it:

    "model": "sonnet",
    "advisorModel": "opus",
    "statusLine": { "type": "command", "command": "bash \"$HOME/.claude/statusline.sh\"" },
    "enabledPlugins": { "ponytail@ponytail": true },
    "extraKnownMarketplaces": {
      "ponytail": { "source": { "source": "github", "repo": "DietrichGebert/ponytail" } }
    }

