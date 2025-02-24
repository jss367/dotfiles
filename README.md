This repo contains my personal dotfiles configuration.

The way to use this repo is to symlink the files you want to their respective locations. For example, if you want to use `.profile`, you would symlink it like so:

* `ln -sf "$DOTFILES/shell/profile" "$HOME/.profile"`.

Before you do that, you should `export DOTFILES=/Users/julius/git/dotfiles`. Otherwise, you will need to use absolute paths.

For completeness, here are the symlinks you might use: 

* `ln -sf "$DOTFILES/shell/profile" "$HOME/.profile"`.
* `ln -sf "$DOTFILES/shell/zshrc" "$HOME/.zshrc"`.
* `ln -sf "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"`.

Note that the zshrc file is for Apple Silicon, so you might not want it on all systems.


