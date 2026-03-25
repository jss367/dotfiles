This repo contains my personal dotfiles configuration.

## Quick Start

```bash
git clone https://github.com/julius/dotfiles.git ~/git/dotfiles
cd ~/git/dotfiles
./bootstrap.sh
```

The bootstrap script installs and configures:
- **Homebrew** and packages (zoxide, fzf, zsh-syntax-highlighting)
- **iTerm2**
- **Oh My Zsh** with **Powerlevel10k** theme and **zsh-autosuggestions**
- **MesloLGS Nerd Font** (required by Powerlevel10k)
- **nvm** and Node.js
- **Claude Code**
- **Karabiner** config
- Symlinks for `profile` and `gitconfig`

The script is idempotent — safe to re-run on an already-configured machine.

## Manual Steps After Bootstrap

1. Set iTerm2 font to **MesloLGS NF** size 13 in Preferences > Profiles > Text
2. Configure `.zshrc` with `ZSH_THEME="powerlevel10k/powerlevel10k"` and `plugins=(git zsh-autosuggestions)`

## Design Decisions

I don't symlink `.zshrc` because too many tools (conda, nvm, etc.) modify it during installation, which breaks symlinks or pollutes the repo with machine-specific paths. I use that one for any machine-specific stuff. All the portable config lives in `.profile` instead.

