# Tmux Project Colors Redesign

## Problem

The current `tmux-project-colors.zsh` script hashes project names into RGB space directly, producing:
- Ugly, muddy colors (all three RGB channels vary independently)
- Hard-to-distinguish projects (similar hashes land on similar tints)
- Poor text readability (pane background tinting reduces contrast)
- Underused status bar (just a brighter version of the same tint)

## Design

### Color Generation: Golden-Angle HSL

1. Hash the project name with MD5 (cross-platform: BSD `md5` / Linux `md5sum`)
2. Take the first 8 hex characters, convert to an integer
3. Multiply by the golden angle (137.508 degrees), mod 360 to get the hue
4. Fix saturation at 70%, lightness at 50% — bold, vivid colors that pop on dark terminals
5. Convert HSL to hex RGB using pure zsh integer arithmetic (no external tools)

The golden angle ensures that even arbitrary hash-derived integers produce hues that are maximally spread around the color wheel. The result is deterministic: "vireo" always produces the same color, on any machine, in any order.

For pane borders, use the same hue and saturation but lower lightness (~35%) so the border is visible but not overwhelming.

### What Gets Colored

| Element | Behavior |
|---|---|
| **Status bar window tab** | Active window tab gets project color background + white text |
| **Status bar (left/right)** | Stays default — only the window tab is colored |
| **Active pane border** | Project color at lower lightness (~35%) |
| **Inactive pane borders** | Default/dim |
| **Pane background** | Always default — no more tinted backgrounds |
| **Window name** | Renamed to git project name; reverts to automatic when outside a git repo |

### Hook Mechanism

Same file (`shell/rc.d/tmux-project-colors.zsh`), same loading mechanism (zsh `chpwd` hook + runs on shell start). On each directory change:

1. Check if inside tmux — bail if not
2. `git rev-parse --show-toplevel` — if not in a git repo, reset all styles to defaults
3. Hash project name -> golden-angle hue -> HSL to hex (two variants: full lightness for tab, reduced for border)
4. Clear pane background: `tmux select-pane -P 'bg=default'`
5. Set active window tab style: `tmux set-window-option window-status-current-style "bg=#XXXXXX,fg=#ffffff"`
6. Set active pane border: `tmux set-option pane-active-border-style "fg=#YYYYYY"`
7. Rename window to project name

### Edge Cases

- **Multiple projects in one window:** Each pane's shell runs its own hook, so the window tab reflects whichever pane last triggered the hook. Pane borders still differentiate projects within a window.
- **Not in a git repo:** All styles reset to defaults, window name reverts to automatic.
- **Cross-platform:** MD5 hashing works on both macOS (BSD `md5`) and Linux (`md5sum`).

### What's NOT Changing

- File location: stays at `shell/rc.d/tmux-project-colors.zsh`
- Loading mechanism: sourced by `~/.zshrc` glob over `rc.d/*.zsh`
- Hook system: `add-zsh-hook chpwd` + initial run on shell start
- No external dependencies added

## Constraints

- Pure zsh — no `bc`, `python`, or other external tools for math
- 2-5 concurrent projects typical, up to 7 windows
- Dark terminal background assumed
- Must be deterministic and stateless (same project name = same color everywhere)
