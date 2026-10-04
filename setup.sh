#!/bin/bash

echo "Installing Dependencies"

# Install xCode cli tools
# xcode-select --install only opens the installer dialog and returns
# immediately, so wait until the tools actually exist before continuing
if ! xcode-select -p &>/dev/null; then
  echo "Installing commandline tools..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do sleep 5; done
fi

# Install Homebrew if missing, and make sure it's on PATH for this script
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Essentials
brew install lua
brew tap FelixKratz/formulae
brew install sketchybar
brew install wezterm
brew install borders
brew install --cask nikitabobko/tap/aerospace
brew install wget
brew install jq
brew install fzf

# Nice to have
brew install --cask raycast
brew install btop
brew install switchaudio-osx
brew install nowplaying-cli
brew install thefuck
brew install htop

# Terminal
brew install neovim
brew install zoxide
brew install eza
brew install starship
brew install neofetch

# Fonts
brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro
brew install --cask font-sketchybar-app-font
brew install --cask font-fira-code-nerd-font

# SbarLua 
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)





# Symlink configs
mkdir -p "$HOME/.config"

# Remove and recreate sketchybar symlink
rm -rf "$HOME/.config/sketchybar"
ln -sf "$HOME/.dotfiles/sketchybar" "$HOME/.config/sketchybar"
ln -sf "$HOME/.dotfiles/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
ln -sfn "$HOME/.dotfiles/wezterm" "$HOME/.config/wezterm"

# Symlink Starship config
echo "Setting up Starship prompt..."
mkdir -p "$HOME/.config"
ln -sf "$HOME/.dotfiles/starship.toml" "$HOME/.config/starship.toml"





# Add useful aliases and zoxide init to .zshrc
echo "Setting up aliases..."

# Ensure starship is initialized in .zshrc
if ! grep -q 'starship init zsh' "$HOME/.zshrc"; then
  echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
fi
# Ensure zoxide is initialized
if ! grep -q 'zoxide init zsh' "$HOME/.zshrc"; then
  echo 'eval "$(zoxide init zsh)"' >> "$HOME/.zshrc"
fi
# Add aliases for eza and zoxide
if ! grep -q 'alias ls=' "$HOME/.zshrc"; then
  echo 'alias ls="eza --icons"' >> "$HOME/.zshrc"
fi
if ! grep -q 'alias tree=' "$HOME/.zshrc"; then
  echo 'alias tree="eza --tree --icons"' >> "$HOME/.zshrc"
fi
if ! grep -q 'alias cd=' "$HOME/.zshrc"; then
  echo 'alias cd="z"' >> "$HOME/.zshrc"
fi





# Hide Default Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 1000 # Set to 0 to revert to default
killall Dock


# Start Services
# Launch once so the apps appear in the Accessibility list, then restart
# them after permissions are granted (they don't pick up permissions live)
echo "Starting Services (grant permissions)..."
open -a aerospace
brew services start sketchybar
brew services start borders

echo "Please grant Accessibility permissions for Aerospace and SketchyBar in System Settings."
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
read -p "Press [Enter] after granting permissions to continue..."

echo "Restarting services with permissions..."
osascript -e 'quit app "AeroSpace"'
sleep 2
open -a aerospace
brew services restart sketchybar
brew services restart borders
