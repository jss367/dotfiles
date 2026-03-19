# Karabiner-Elements Config

Windows-style keyboard shortcuts on macOS, plus custom mappings.

Files are named by keyboard type. Symlink the right one on each machine:

```
ln -s ~/git/dotfiles/karabiner/karabiner-ansi.json ~/.config/karabiner/karabiner.json
```

## Rules

| # | Shortcut | Action | Scope |
|---|----------|--------|-------|
| 1 | Ctrl+C / Ctrl+V / Ctrl+X | Cmd+C / Cmd+V / Cmd+X (Copy/Paste/Cut) | Excludes terminals, VMs, remote desktop |
| 2 | Ctrl+Z | Cmd+Z (Undo) | Excludes terminals, VMs, remote desktop |
| 3 | Ctrl+Y | Cmd+Shift+Z (Redo) | Excludes terminals, VMs, remote desktop |
| 4 | Ctrl+A | Cmd+A (Select all) | Excludes terminals, VMs, remote desktop |
| 5 | Ctrl+S | Cmd+S (Save) | Excludes terminals, VMs, remote desktop |
| 6 | Ctrl+N | Cmd+N (New) | Excludes terminals, VMs, remote desktop |
| 7 | Ctrl+F | Cmd+F (Find) | Excludes terminals, VMs, remote desktop |
| 8 | Ctrl+W | Cmd+W (Close) | Excludes terminals, VMs, remote desktop |
| 9 | Alt+F4 | Cmd+Q (Quit) | Excludes VMs, remote desktop |
| 10 | Home / Shift+Home | Cmd+Left / Cmd+Shift+Left (Start of line) | Excludes terminals, VMs |
| 11 | Ctrl+Home | Cmd+Up (Start of file) | Excludes terminals, VMs |
| 12 | End / Shift+End | Cmd+Right / Cmd+Shift+Right (End of line) | Excludes terminals, VMs |
| 13 | Ctrl+End | Cmd+Down (End of file) | Excludes terminals, VMs |
| 14 | Ctrl+T | Cmd+T (New tab) | Excludes terminals, VMs |
| 15 | Ctrl+B | Cmd+B (Bold) | Excludes terminals, VMs |
| 16 | Ctrl+I | Cmd+I (Italic) | Excludes terminals, VMs |
| 17 | Ctrl+L | Cmd+L (Address bar) | Browsers only |
| 18 | Ctrl+R | Cmd+R (Reload) | Browsers only |
| 19 | F5 | Cmd+R (Reload) | Excludes terminals, VMs, remote desktop |
| 20 | Alt+Tab | Cmd+Tab (Switch app) | Global |
| 21 | Ctrl+Left/Right | Alt+Left/Right (Word jump) | Excludes terminals, VMs, remote desktop |
| 22 | Ctrl+Esc | Open Launchpad | Excludes VMs, remote desktop |
| 23 | Ctrl+Shift+Esc | Open Activity Monitor | Excludes VMs, remote desktop |
| 24 | Enter | Cmd+O (Open) | Finder only |
| 25 | F2 | Enter (Rename) | Finder only |
| 26 | Delete | Cmd+Backspace (Delete) | Finder only |
| 27 | Backspace | Cmd+Up (Go up) | Finder only |
| 28 | Ctrl+Click | Cmd+Click (Multi-select) | Global |
| 29 | Caps Lock | Type email address | Global |
