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
