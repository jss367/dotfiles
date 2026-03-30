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

# --- Brew packages ---
info "Installing brew packages..."
brew install --quiet zoxide fzf zsh-syntax-highlighting

# --- iTerm2 ---
if [[ ! -d "/Applications/iTerm.app" ]]; then
    info "Installing iTerm2..."
    brew install --cask iterm2
else
    success "iTerm2 already installed"
fi

# --- iTerm2 appearance ---
ITERM_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
if [[ -f "$ITERM_PLIST" ]]; then
    info "Configuring iTerm2 dark theme, colors, and font..."
    PB="/usr/libexec/PlistBuddy"
    PROF=":New Bookmarks:0"

    # Dark background
    $PB -c "Set '${PROF}:Background Color:Red Component'   0.12" "$ITERM_PLIST"
    $PB -c "Set '${PROF}:Background Color:Green Component' 0.12" "$ITERM_PLIST"
    $PB -c "Set '${PROF}:Background Color:Blue Component'  0.14" "$ITERM_PLIST"

    # Light foreground
    $PB -c "Set '${PROF}:Foreground Color:Red Component'   0.85" "$ITERM_PLIST"
    $PB -c "Set '${PROF}:Foreground Color:Green Component' 0.85" "$ITERM_PLIST"
    $PB -c "Set '${PROF}:Foreground Color:Blue Component'  0.85" "$ITERM_PLIST"

    # Font
    $PB -c "Set '${PROF}:Normal Font' 'MesloLGS-NF-Regular 13'" "$ITERM_PLIST"

    # Dark window chrome (1 = Dark)
    defaults write com.googlecode.iterm2 TabStyleWithAutomaticOption -int 1
else
    warn "iTerm2 plist not found — open iTerm2 once, then re-run this script"
fi

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

# --- Symlinks ---
info "Setting up symlinks..."
ln -sf "$DOTFILES_DIR/shell/profile" "$HOME/.profile"
ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

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

# --- AeroSpace ---
if [[ ! -d "/Applications/AeroSpace.app" ]]; then
    info "Installing AeroSpace..."
    brew install --cask nikitabobko/tap/aerospace
else
    success "AeroSpace already installed"
fi

# --- Karabiner ---
KARABINER_DIR="$HOME/.config/karabiner"
if [[ -d "$DOTFILES_DIR/karabiner" ]]; then
    info "Linking Karabiner config..."
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_DIR/karabiner" "$KARABINER_DIR"
fi

echo ""
success "Done! Open a new iTerm2 window to see everything in action."
info "iTerm2 is configured with dark theme, MesloLGS NF font, and preferences from dotfiles"
warn "Remember: .zshrc is machine-specific — set ZSH_THEME=\"powerlevel10k/powerlevel10k\" and plugins=(git zsh-autosuggestions) manually"
warn "Remember: add 'for f in ~/git/dotfiles/shell/rc.d/*.zsh(N); do source \"\$f\"; done' to .zshrc for portable shell scripts"
