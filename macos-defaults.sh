#!/usr/bin/env bash
#
# macOS defaults — run once on a fresh machine, or after a preferences reset.
# Many changes require a logout or a process restart (noted inline).
#
set -e

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }

info "Applying macOS defaults..."

# ──────────────────────────────────────────────
# Keyboard
# ──────────────────────────────────────────────
# Fast key repeat (lower = faster, default is 6, minimum via UI is 2)
defaults write NSGlobalDomain KeyRepeat -int 2

# Short delay before key repeat starts (default 25, lower = faster)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for accented characters (enables real key repeat everywhere)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart quotes and dashes (annoying in code)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# ──────────────────────────────────────────────
# Trackpad
# ──────────────────────────────────────────────
# Faster tracking speed (default ~1.0, max via UI is 3.0)
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5

# Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Disable "natural" (inverted) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# ──────────────────────────────────────────────
# Dock
# ──────────────────────────────────────────────
# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Remove the auto-hide delay
defaults write com.apple.dock autohide-delay -float 0

# Faster hide/show animation
defaults write com.apple.dock autohide-time-modifier -float 0.3

# Smaller icons
defaults write com.apple.dock tilesize -int 36

# Don't show recent apps in Dock
defaults write com.apple.dock show-recents -bool false

# Minimize windows into their app icon
defaults write com.apple.dock minimize-to-application -bool true

# Don't animate opening applications
defaults write com.apple.dock launchanim -bool false

# ──────────────────────────────────────────────
# Finder
# ──────────────────────────────────────────────
# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar at bottom
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Default to list view (icnv = icon, Nlsv = list, clmv = column, glyv = gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Search the current folder by default (not all of Mac)
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# ──────────────────────────────────────────────
# Mission Control / Spaces
# ──────────────────────────────────────────────
# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Don't switch to a Space that has an open window for an app (Airlock manages this)
defaults write com.apple.dock workspaces-auto-swoosh -bool false

# ──────────────────────────────────────────────
# Screenshots
# ──────────────────────────────────────────────
# Save screenshots to ~/Screenshots
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Save as PNG (default)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ──────────────────────────────────────────────
# Misc
# ──────────────────────────────────────────────
# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# ──────────────────────────────────────────────
# Restart affected apps
# ──────────────────────────────────────────────
info "Restarting Dock and Finder..."
killall Dock
killall Finder
killall SystemUIServer 2>/dev/null || true

printf "\n\033[1;32m==>\033[0m Done! Some changes (keyboard, trackpad) require a logout to take effect.\n"
