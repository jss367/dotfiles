# Tmux Project Colors Redesign — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite `tmux-project-colors.zsh` to use golden-angle HSL color generation, coloring only the status bar tab and pane borders (not pane backgrounds) for readable, vivid, distinguishable per-project colors.

**Architecture:** Single zsh script with three internal functions: MD5 hashing (cross-platform), HSL-to-RGB conversion (pure zsh arithmetic), and the main hook that generates colors and applies tmux styles. The hook fires on `chpwd` and shell start.

**Tech Stack:** zsh, tmux

**Spec:** `docs/superpowers/specs/2026-03-28-tmux-project-colors-redesign.md`

---

### Task 1: Write the HSL-to-RGB conversion function

**Files:**
- Modify: `shell/rc.d/tmux-project-colors.zsh`

This is the core math. HSL-to-RGB in pure zsh integer arithmetic. We scale everything by 1000 to avoid floating point (zsh only has integers).

**Step 1: Replace the entire file with the HSL-to-RGB function and a test harness**

Replace the contents of `shell/rc.d/tmux-project-colors.zsh` with:

```zsh
# Tmux project-aware pane coloring and window naming
# Auto-colors tmux status bar tab and pane borders based on git project.

# HSL to hex RGB (pure zsh integer math, no external tools)
# H: 0-360, S: 0-100, L: 0-100
# Outputs: sets _r, _g, _b (0-255)
_hsl_to_rgb() {
  local h=$1 s=$2 l=$3

  if (( s == 0 )); then
    _r=$(( l * 255 / 100 ))
    _g=$_r
    _b=$_r
    return
  fi

  # Scale to thousandths for integer math
  local s1000=$(( s * 10 ))  # 0-1000
  local l1000=$(( l * 10 ))  # 0-1000

  local q
  if (( l1000 < 500 )); then
    q=$(( l1000 * (1000 + s1000) / 1000 ))
  else
    q=$(( l1000 + s1000 - l1000 * s1000 / 1000 ))
  fi
  local p=$(( 2 * l1000 - q ))

  _hue_to_rgb() {
    local t=$1
    (( t < 0 )) && t=$(( t + 3600 ))
    (( t > 3600 )) && t=$(( t - 3600 ))
    if (( t < 600 )); then
      echo $(( p + (q - p) * t / 600 ))
    elif (( t < 1800 )); then
      echo $q
    elif (( t < 2400 )); then
      echo $(( p + (q - p) * (2400 - t) / 600 ))
    else
      echo $p
    fi
  }

  # H scaled to 0-3600 (tenths of degrees * 10)
  local h10=$(( h * 10 ))
  local r1000=$(_hue_to_rgb $(( h10 + 1200 )))
  local g1000=$(_hue_to_rgb $h10)
  local b1000=$(_hue_to_rgb $(( h10 - 1200 )))

  _r=$(( r1000 * 255 / 1000 ))
  _g=$(( g1000 * 255 / 1000 ))
  _b=$(( b1000 * 255 / 1000 ))
}
```

**Step 2: Verify the function produces correct values**

Source the file and test with known HSL values:

```bash
source shell/rc.d/tmux-project-colors.zsh
# Red: HSL(0, 70, 50) should be approximately #D92626
_hsl_to_rgb 0 70 50 && printf '#%02x%02x%02x\n' $_r $_g $_b
# Green: HSL(120, 70, 50) should be approximately #26D926
_hsl_to_rgb 120 70 50 && printf '#%02x%02x%02x\n' $_r $_g $_b
# Blue: HSL(240, 70, 50) should be approximately #2626D9
_hsl_to_rgb 240 70 50 && printf '#%02x%02x%02x\n' $_r $_g $_b
# Grey: HSL(0, 0, 50) should be #7f7f7f
_hsl_to_rgb 0 0 50 && printf '#%02x%02x%02x\n' $_r $_g $_b
```

Expected: four hex colors close to the targets above (exact values may differ slightly due to integer rounding, but should be within a few points).

**Step 3: Commit**

```bash
git add shell/rc.d/tmux-project-colors.zsh
git commit -m "feat(tmux-colors): add HSL-to-RGB conversion in pure zsh"
```

---

### Task 2: Add cross-platform MD5 and golden-angle hue generation

**Files:**
- Modify: `shell/rc.d/tmux-project-colors.zsh`

**Step 1: Add the MD5 helper and hue generation function below `_hsl_to_rgb`**

Append after the `_hsl_to_rgb` function:

```zsh
# Cross-platform md5
if command -v md5 &>/dev/null; then
  _tmux_hash() { md5 -qs "$1"; }
else
  _tmux_hash() { echo -n "$1" | md5sum | cut -c1-32; }
fi

# Project name -> hue via golden angle
# Deterministic: same name = same hue, always
_project_hue() {
  local name=$1
  local hash=$(_tmux_hash "$name")
  # Take first 8 hex chars -> integer, multiply by golden angle (137.508 deg)
  # We use 137508 and divide by 1000 to stay in integer math
  local idx=$(( 16#${hash:0:8} ))
  local hue=$(( (idx * 137508 / 1000) % 360 ))
  echo $hue
}
```

**Step 2: Verify hue generation is deterministic and well-distributed**

```bash
source shell/rc.d/tmux-project-colors.zsh
# Same name should always give same hue
echo "vireo: $(_project_hue vireo) $(_project_hue vireo)"
# Different names should give different hues
echo "vireo: $(_project_hue vireo)"
echo "blog: $(_project_hue blog)"
echo "dotfiles: $(_project_hue dotfiles)"
echo "api: $(_project_hue api)"
echo "frontend: $(_project_hue frontend)"
```

Expected: each name prints the same hue every time; different names produce visibly different hue numbers.

**Step 3: Commit**

```bash
git add shell/rc.d/tmux-project-colors.zsh
git commit -m "feat(tmux-colors): add MD5 helper and golden-angle hue generation"
```

---

### Task 3: Rewrite the main hook function

**Files:**
- Modify: `shell/rc.d/tmux-project-colors.zsh`

**Step 1: Replace any remaining old code and add the main hook**

Remove any leftover `_tmux_project_color` function and the old `add-zsh-hook` / startup lines from the file. Then append at the bottom:

```zsh
_tmux_project_color() {
  [[ -z "$TMUX" ]] && return

  local project_dir
  project_dir=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ -z "$project_dir" ]]; then
    # Not in a git repo — reset everything
    tmux select-pane -P 'bg=default'
    tmux set-window-option window-status-current-style 'default'
    tmux set-option pane-active-border-style 'default'
    tmux set-window-option automatic-rename on
    return
  fi

  local project_name="${project_dir:t}"
  local hue=$(_project_hue "$project_name")

  # Status bar tab: S=70, L=50 (vivid)
  _hsl_to_rgb $hue 70 50
  local tab_color=$(printf '#%02x%02x%02x' $_r $_g $_b)

  # Pane border: S=70, L=35 (subdued)
  _hsl_to_rgb $hue 70 35
  local border_color=$(printf '#%02x%02x%02x' $_r $_g $_b)

  # Apply styles
  tmux select-pane -P 'bg=default'
  tmux set-window-option window-status-current-style "bg=${tab_color},fg=#ffffff"
  tmux set-option pane-active-border-style "fg=${border_color}"
  tmux rename-window "$project_name"
}

add-zsh-hook chpwd _tmux_project_color
_tmux_project_color  # run on shell start
```

**Step 2: Verify in tmux**

Open a tmux session and run:

```bash
source ~/.zshrc
cd ~/git/dotfiles
# Should see: window renamed to "dotfiles", tab colored, border colored
cd ~/git/vireo  # or any other git repo
# Should see: different color, different name
cd /tmp
# Should see: defaults restored, automatic window name
```

Visually confirm:
- Tab colors are vivid and distinct between projects
- Pane borders show the project color (dimmer)
- Pane background is default (no tint)
- Text is fully readable
- Window name matches project

**Step 3: Commit**

```bash
git add shell/rc.d/tmux-project-colors.zsh
git commit -m "feat(tmux-colors): rewrite hook to color status tab and border only"
```

---

### Task 4: Final cleanup and verification

**Files:**
- Modify: `shell/rc.d/tmux-project-colors.zsh` (only if needed)

**Step 1: Read the final file end-to-end**

Read through the complete file and verify:
- No leftover old code (old `_tmux_project_color` body, old status-style commands)
- No duplicate function definitions
- Clean structure: helpers at top, hook at bottom

**Step 2: Test the reset path**

In tmux:

```bash
cd /tmp  # not a git repo
```

Verify: pane background is default, tab style is default, border is default, window name is automatic.

**Step 3: Test persistence across new panes**

In tmux, while in a git project:
- Split pane (Ctrl-b %)
- New pane should also pick up the project color on shell start

**Step 4: Commit if any cleanup was needed**

```bash
git add shell/rc.d/tmux-project-colors.zsh
git commit -m "chore(tmux-colors): final cleanup"
```
