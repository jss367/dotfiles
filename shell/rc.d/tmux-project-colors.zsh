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
