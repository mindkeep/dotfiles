#!/usr/bin/env bash
# Claude Code statusline:  Opus 5 ━━━···· 10% (103K/1M) │ repo:🏡2⎇ branch  repo⎇ branch
#
# A treehouse slot renders as repo:🏡<slot>⎇ branch, dropping to repo:🏡<slot>
# when the row is tight. Anything else is repo⎇ branch.
#
# Repo segments show what THIS session is actually working in, newest first,
# derived from paths its own transcript addressed a tool at (file_path /
# notebook_path / cwd). Mentions in prose or shell strings don't count.
#
# Scope (WS) is discovered, not configured:
#   inside a git repo      -> that repo (plus its worktrees and their siblings)
#   a dir of git repos     -> that dir (plus worktrees of the repos under it)
#   neither                -> no repo segments
#
# Optional: prefixes a [🧩 name:mode] badge per active plugin (ponytail, caveman,
# anything else using the same flag-file convention), collapsed to [N🧩] when the
# row is tight. None installed means no badges.
#
# Requires jq. Wire it up in ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "bash \"$HOME/.claude/statusline.sh\"" }

# Usable width. COLUMNS can arrive empty or 0 when the statusline is run without a
# tty. Off it come three reservations:
#   PAD  statusLine.padding -- extra indent Claude Code adds to our content
#   RC   the "/rc" remote-control badge the TUI parks at the end of our row,
#        4 cols with its leading space. It is a live connection state with no
#        on-disk trace, so the best available signal is the startup setting;
#        export STATUSLINE_RC=1/0 if you toggle it at runtime with /remote-control.
#   STATUSLINE_MARGIN  slack, for anything else sharing the row.
CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
COLS=${COLUMNS:-0}; [ "$COLS" -ge 20 ] 2>/dev/null || COLS=$(tput cols 2>/dev/null || echo 120)
IFS=$'\t' read -r PAD RC < <(jq -r '[(.statusLine.padding // 0),
  (if .remoteControlAtStartup then 1 else 0 end)] | @tsv' "$CFG/settings.json" 2>/dev/null)
RC=${STATUSLINE_RC:-${RC:-0}}
BUDGET=$(( COLS - ${PAD:-0} - (RC ? 4 : 0) - ${STATUSLINE_MARGIN:-2} ))
MAX_SEGS=${STATUSLINE_MAX_REPOS:-4}

IFS=$'\t' read -r model pct used max cwd transcript < <(jq -r '[
  .model.display_name,
  (.context_window.used_percentage // 0),
  (.context_window.total_input_tokens // 0),
  (.context_window.context_window_size // 0),
  (.workspace.current_dir // .cwd // ""),
  (.transcript_path // "")] | @tsv')

fmt() { # 101528 -> 101K, 1000000 -> 1M
  if   [ "$1" -ge 1000000 ]; then printf '%sM' "$(($1 / 1000000))"
  elif [ "$1" -ge 1000    ]; then printf '%sK' "$(($1 / 1000))"
  else printf '%s' "$1"; fi
}

repo_root() { # walk up from $1 to the nearest dir containing .git
  local d="$1"
  while [ -n "$d" ] && [ "$d" != / ]; do
    [ -e "$d/.git" ] && { printf '%s' "$d"; return 0; }
    d=${d%/*}
  done
  return 1
}

# Sets GITDIR / GITCOMMON / BRANCH for a worktree root. GITCOMMON is the shared
# dir all worktrees of one repo point at, so it identifies the repo family.
git_info() {
  local g="$1/.git" h _x
  [ -e "$g" ] || return 1
  if [ -f "$g" ]; then read -r _x GITDIR < "$g"; else GITDIR="$g"; fi
  GITCOMMON=${GITDIR%/worktrees/*}
  read -r h 2>/dev/null < "$GITDIR/HEAD" || return 1  # 2> first: it must cover the <
  case "$h" in "ref: refs/heads/"*) BRANCH=${h#ref: refs/heads/} ;; *) BRANCH=${h:0:7} ;; esac
}

TREE=🏡  # marks a treehouse slot; 2 cols wide, so dw() counts it
BR="⎇ "  # precedes a branch name. Unicode calls it 1 col but fonts draw it
         # wider, so it overhangs and eats the next char -- the trailing space
         # absorbs that, and keeps 2 chars == 2 cols so dw() stays out of it

# Treehouse slot: <root>/.treehouse/<repo>-<hash>/<n>/<repo>. The slot number is
# where the work is happening, so it earns its place in the segment. The root is
# relocatable (TREEHOUSE_DIR, treehouse.toml), so match the shape, not $HOME.
th_slot() { # $1 repo root -> slot number, or nothing when it is not a slot
  local slot pool
  pool=${1%/*}; slot=${pool##*/}        # <n>
  pool=${pool%/*}; pool=${pool%/*}      # <root>/.treehouse
  [ "${pool##*/}" = .treehouse ] || return 1
  case "$slot" in ''|*[!0-9]*) return 1 ;; esac
  printf '%s' "$slot"
}

# Both segment forms for a repo root, using $BRANCH from git_info.
mkseg() { # $1 repo root -> SEG_L (long) SEG_S (short)
  local slot
  if slot=$(th_slot "$1"); then
    SEG_S="${1##*/}:$TREE$slot"; SEG_L="$SEG_S$BR$BRANCH"
  else
    SEG_S="${1##*/}$BR$BRANCH"; SEG_L="$SEG_S"
  fi
}

# --- scope --------------------------------------------------------------------
WS=$(repo_root "$cwd") || {
  [ -d "$cwd" ] && for d in "$cwd"/*/; do [ -e "$d.git" ] && { WS="$cwd"; break; }; done
}

# --- repo segments ------------------------------------------------------------
segs=() shorts=() cur="" WS_COMMON=""
if [ -n "$WS" ]; then
  if git_info "$WS"; then
    WS_COMMON=$GITCOMMON
    mkseg "$WS"; cur=$SEG_L; segs+=("$SEG_L"); shorts+=("$SEG_S")
  fi

  related() { # $1 repo root, $2 its GITCOMMON -- under WS, or the same repo family
    case "$1" in "$WS"|"$WS"/*) return 0 ;; esac
    case "$2" in "$WS"/*) return 0 ;; esac
    [ -n "$WS_COMMON" ] && [ "$2" = "$WS_COMMON" ]
  }

  [ -s "$transcript" ] && while read -r dir; do
    root=$(repo_root "$dir") || continue
    git_info "$root" || continue
    related "$root" "$GITCOMMON" || continue
    mkseg "$root"
    for seen in "${segs[@]}"; do [ "$seen" = "$SEG_L" ] && continue 2; done
    segs+=("$SEG_L"); shorts+=("$SEG_S")
    [ ${#segs[@]} -ge "$MAX_SEGS" ] && break
  done < <(grep -oE '"(file_path|notebook_path|cwd)":"/[^"]+' "$transcript" |
             sed 's/.*":"//' | tac | awk '!s[$0]++')
fi

# --- render -------------------------------------------------------------------
BADGE=🧩
dw() { local n=${1//$BADGE/}; n=${n//$TREE/}          # 🧩 and 🏡 are 2 cols each
       echo $(( ${#1} + ${#1} - ${#n} )); }

# Plugin badges, all optional -- nothing here is required for the statusline to
# work. Discovered, not configured: ponytail and caveman both record their mode
# in $CLAUDE_CONFIG_DIR/.<name>-active, with an optional .<name>-statusline-suffix
# for a short extra (caveman puts its token savings there). Any plugin following
# that convention gets a badge for free; none installed means no badges.
# Contents are plugin-written, so treat them as untrusted: clamp length, keep the
# mode to a bare word, and strip control bytes from the suffix. Names and modes
# render in whatever case the plugin chose.
cfg="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
bp="" bc="" nb=0 ncol=108
for flag in "$cfg"/.*-active; do
  [ -f "$flag" ] || continue
  name=${flag##*/.}; name=${name%-active}
  mode=$(head -c 32 "$flag" | head -n1 | tr -cd 'A-Za-z0-9._-'); mode=${mode:-full}
  [ "$mode" = "ultra" ] && { c=173; ncol=173; } || c=108
  sfx=""
  [ -f "$cfg/.$name-statusline-suffix" ] &&
    sfx=" $(head -c 24 "$cfg/.$name-statusline-suffix" | head -n1 | tr -d '\000-\037')"
  t="[$BADGE $name:$mode]$sfx"
  bp+="$t "
  bc+=$(printf '\033[38;5;%sm%s\033[0m ' "$c" "$t")
  nb=$((nb + 1))
done
# Collapsed form, used when the row is tight: badges yield space before repos do.
cp="" cc=""
[ $nb -gt 0 ] && { cp="[$nb$BADGE] "; cc=$(printf '\033[38;5;%sm%s\033[0m ' "$ncol" "[$nb$BADGE]"); }

# bar color: green < 60% < yellow < 85% < red
if   [ "$pct" -lt 60 ]; then c=71
elif [ "$pct" -lt 85 ]; then c=179
else                         c=167
fi
bar=""
for i in $(seq 0 24); do
  [ $((i * 4)) -lt "$pct" ] && bar+='━' || bar+='·'
done

mid_p="$model $bar $pct% ($(fmt "$used")/$(fmt "$max"))"
mid_c=$(printf '\033[38;5;110m%s\033[0m \033[38;5;%sm%s\033[0m \033[38;5;245m%s%% (%s/%s)\033[0m' \
  "$model" "$c" "$bar" "$pct" "$(fmt "$used")" "$(fmt "$max")")

# Full badges only if everything -- badges, meter, every repo -- fits as is.
rep_w=0 i=0
for s in "${segs[@]}"; do rep_w=$((rep_w + $(dw "$s") + (i == 0 ? 3 : 2))); i=1; done
if [ $(( $(dw "$bp") + $(dw "$mid_p") + rep_w )) -le $BUDGET ]; then
  out="$bc$mid_c"; len=$(( $(dw "$bp") + $(dw "$mid_p") ))
else
  out="$cc$mid_c"; len=$(( $(dw "$cp") + $(dw "$mid_p") ))
fi

first=1 i=0
for s in "${segs[@]}"; do
  sep="  "; [ $first = 1 ] && sep=" │ "
  [ $((len + ${#sep} + $(dw "$s"))) -gt $BUDGET ] && s=${shorts[i]}
  w=$(dw "$s"); [ $((len + ${#sep} + w)) -gt $BUDGET ] && break
  [ $first = 1 ] && [ -n "$cur" ] && col=150 || col=242
  out+=$(printf '\033[38;5;240m%s\033[0m\033[38;5;%sm%s\033[0m' "$sep" "$col" "$s")
  len=$((len + ${#sep} + w))
  first=0; i=$((i + 1))
done

printf '%s' "$out"
