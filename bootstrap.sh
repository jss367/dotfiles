#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$1"; }
success() { printf "\033[1;32m==>\033[0m %s\n" "$1"; }

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
else
    success "Homebrew already installed"
fi

# Persist Homebrew in .zprofile
if ! grep -qF 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
    info "Adding Homebrew to .zprofile..."
    echo >> "$HOME/.zprofile"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> "$HOME/.zprofile"
fi

# --- Brew packages ---
info "Installing brew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# --- iTerm2 appearance ---
info "Configuring iTerm2 dark theme, colors, and font..."

# Dark window chrome (1 = Dark)
defaults write com.googlecode.iterm2 TabStyleWithAutomaticOption -int 1

# Use a Dynamic Profile — iTerm2 picks these up automatically, no plist hacking needed
DYNAMIC_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$DYNAMIC_DIR"
cat > "$DYNAMIC_DIR/dotfiles.json" << 'EOF'
{
    "Profiles": [{
        "Name": "Default",
        "Guid": "dotfiles-dark-profile",
        "Dynamic Profile Parent Name": "Default",
        "Background Color": {
            "Color Space": "sRGB",
            "Red Component": 0.12,
            "Green Component": 0.12,
            "Blue Component": 0.14
        },
        "Foreground Color": {
            "Color Space": "sRGB",
            "Red Component": 0.85,
            "Green Component": 0.85,
            "Blue Component": 0.85
        },
        "Normal Font": "MesloLGS-NF-Regular 13"
    }]
}
EOF

# Note: don't override Default Bookmark Guid — let iTerm2 manage it.
# The dynamic profile inherits from "Default" and iTerm2 picks it up on restart.

# --- Oh My Zsh ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    success "Oh My Zsh already installed"
fi

# --- Powerlevel10k ---
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    success "Powerlevel10k already installed"
fi

# --- zsh-autosuggestions ---
ZSH_AS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [[ ! -d "$ZSH_AS_DIR" ]]; then
    info "Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_AS_DIR"
else
    success "zsh-autosuggestions already installed"
fi

# --- MesloLGS Nerd Font ---
FONT_DIR="$HOME/Library/Fonts"
if [[ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]]; then
    info "Installing MesloLGS Nerd Font..."
    FONT_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master"
    curl -fsSL -o "$FONT_DIR/MesloLGS NF Regular.ttf"      "$FONT_BASE/MesloLGS%20NF%20Regular.ttf"
    curl -fsSL -o "$FONT_DIR/MesloLGS NF Bold.ttf"          "$FONT_BASE/MesloLGS%20NF%20Bold.ttf"
    curl -fsSL -o "$FONT_DIR/MesloLGS NF Italic.ttf"        "$FONT_BASE/MesloLGS%20NF%20Italic.ttf"
    curl -fsSL -o "$FONT_DIR/MesloLGS NF Bold Italic.ttf"   "$FONT_BASE/MesloLGS%20NF%20Bold%20Italic.ttf"
else
    success "MesloLGS Nerd Font already installed"
fi

# --- nvm ---
export NVM_DIR="$HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
    info "Installing nvm..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v node &>/dev/null; then
    info "Installing Node.js (LTS)..."
    nvm install --lts
fi

# --- Claude Code ---
if ! command -v claude &>/dev/null; then
    info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
else
    success "Claude Code already installed"
fi

# --- Linux GUI apps (Flatpak) ---
if [[ "$(uname)" == "Linux" ]]; then
    if ! command -v flatpak &>/dev/null; then
        warn "Flatpak not found — install it via your distro's package manager, then re-run"
    else
        info "Installing Linux GUI apps via Flatpak..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak install -y flathub \
            com.visualstudio.code \
            org.sublimetext.three \
            md.obsidian.Obsidian \
            org.libreoffice.LibreOffice \
            com.google.Chrome \
            com.brave.Browser \
            org.mozilla.firefox \
            org.doublecmd.DoubleCommander
    fi

    # --- Kitty terminal ---
    if ! command -v kitty &>/dev/null; then
        info "Installing Kitty..."
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    else
        success "Kitty already installed"
    fi

    # --- Miniconda ---
    if [[ ! -d "$HOME/miniconda3" ]]; then
        info "Installing Miniconda..."
        curl -fsSL -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        bash /tmp/miniconda.sh -b -p "$HOME/miniconda3"
        rm /tmp/miniconda.sh
    else
        success "Miniconda already installed"
    fi
fi

# --- Symlinks ---
info "Setting up symlinks..."
ln -sf "$DOTFILES_DIR/shell/profile" "$HOME/.profile"
ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
if [[ "$(uname)" == "Darwin" ]]; then
    ln -sf "$DOTFILES_DIR/git/gitconfig-local-macos" "$HOME/.gitconfig-local"
else
    ln -sf "$DOTFILES_DIR/git/gitconfig-local-linux" "$HOME/.gitconfig-local"
fi

# --- p10k config ---
if [[ ! -f "$HOME/.p10k.zsh" ]]; then
    info "Copying Powerlevel10k config..."
    cp "$DOTFILES_DIR/shell/p10k.zsh" "$HOME/.p10k.zsh"
else
    warn ".p10k.zsh already exists, skipping (diff with: diff ~/.p10k.zsh $DOTFILES_DIR/shell/p10k.zsh)"
fi

# --- Oh My Zsh bridge ---
OMZ_BRIDGE="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/profile.zsh"
if [[ ! -f "$OMZ_BRIDGE" ]]; then
    info "Creating Oh My Zsh bridge to source .profile..."
    echo 'source ~/.profile' > "$OMZ_BRIDGE"
else
    success "Oh My Zsh bridge already exists"
fi

# --- Claude Code ---
info "Linking Claude Code config..."
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
ln -sf "$DOTFILES_DIR/claude/settings.local.json" "$HOME/.claude/settings.local.json"
ln -sfn "$DOTFILES_DIR/claude/skills" "$HOME/.claude/skills"

# --- VS Code & Cursor ---
info "Linking VS Code and Cursor config..."
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$VSCODE_USER_DIR" "$CURSOR_USER_DIR"
ln -sf "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"
ln -sf "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
ln -sf "$DOTFILES_DIR/vscode/settings.json" "$CURSOR_USER_DIR/settings.json"
ln -sf "$DOTFILES_DIR/vscode/keybindings.json" "$CURSOR_USER_DIR/keybindings.json"

# --- Karabiner ---
KARABINER_DIR="$HOME/.config/karabiner"
if [[ -d "$DOTFILES_DIR/karabiner" ]]; then
    info "Linking Karabiner config..."
    mkdir -p "$HOME/.config"
    ln -sfn "$DOTFILES_DIR/karabiner" "$KARABINER_DIR"
fi

# --- macOS defaults ---
info "Applying macOS defaults..."
bash "$DOTFILES_DIR/macos-defaults.sh"

# --- Patch .zshrc ---
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
    # Set theme to powerlevel10k
    if grep -q 'ZSH_THEME="robbyrussell"' "$ZSHRC"; then
        info "Setting ZSH_THEME to powerlevel10k..."
        sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
    fi

    # Set plugins
    if grep -q 'plugins=(git)' "$ZSHRC"; then
        info "Setting plugins to (git zsh-autosuggestions)..."
        sed -i '' 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' "$ZSHRC"
    fi

    # Source rc.d scripts
    RC_D_LINE='for f in ~/git/dotfiles/shell/rc.d/*.zsh(N); do source "$f"; done'
    if ! grep -qF 'rc.d/*.zsh' "$ZSHRC"; then
        info "Adding rc.d sourcing to .zshrc..."
        printf '\n# Source portable dotfiles scripts\n%s\n' "$RC_D_LINE" >> "$ZSHRC"
    fi

    # Source p10k config to suppress the configuration wizard
    if ! grep -qF 'p10k.zsh' "$ZSHRC"; then
        info "Adding p10k.zsh sourcing to .zshrc..."
        printf '\n# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh\n[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh\n' >> "$ZSHRC"
    fi
fi

echo ""
success "Done! Open a new iTerm2 window to see everything in action."
info "iTerm2 is configured with dark theme, MesloLGS NF font, and preferences from dotfiles"
