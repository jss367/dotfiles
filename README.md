This repo contains my personal dotfiles configuration.

The files exist in this repo and are then symlinked to their other location. For example, .profile is symlinked like so: 

* `ln -sf "$DOTFILES/shell/profile" "$HOME/.profile"`.
* `ln -sf "$DOTFILES/shell/zshrc" "$HOME/.zshrc"`.
* `ln -sf "$DOTFILES/git/gitconfig" "$HOME/.gitconfig"`.

Note that the zshrc file is for Apple Silicon, so you might not want it on all systems.

You might not have $DOTFILES set, so you may need to:

* cd dotfiles
* `ln -sf "shell/profile" "$HOME/.profile"`.
* `ln -sf "shell/zshrc" "$HOME/.zshrc"`.
* `ln -sf "git/gitconfig" "$HOME/.gitconfig"`.
