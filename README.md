This repo contains my personal dotfiles configuration.

## Setup

Symlink the files to their expected locations:

```bash
ln -sf ~/git/dotfiles/shell/profile ~/.profile
ln -sf ~/git/dotfiles/git/gitconfig ~/.gitconfig
```

Then create the Oh My Zsh bridge so `.profile` gets sourced automatically:

```bash
echo 'source ~/.profile' > ~/.oh-my-zsh/custom/profile.zsh
```

I don't symlink `.zshrc` because too many tools (conda, nvm, etc.) modify it during installation, which breaks symlinks or pollutes the repo with machine-specific paths. I use that one for any machine-specific stuff. All the portable config lives in `.profile` instead.

