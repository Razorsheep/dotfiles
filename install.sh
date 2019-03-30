#!/bin/bash

echo "Setting up computer..."

# Install Homebrew if not present
if [ -x "$(command -v brew)" ]; then
  echo "Homebrew already installed"
else
  echo "Installing Homebrew..."
  xcode-select install
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo "Homebrew installed"
fi

# creates symbol link $1 -> $2 iff $2 doesnt exists
ln_if () {
  if [ ! -f "$2" ]; then
    ln -s "$1" "$2"
  fi
}

ln_if $HOME/.dotfiles/git/gitignore_global $HOME/.gitignore_global
ln_if $HOME/.dotfiles/zsh/zshrc $HOME/.zshrc
ln_if $HOME/.dotfiles/vim/vimrc $HOME/.vimrc

mkdir -p "$HOME/Library/Application Support/Code/User"
ln_if $HOME/.dotfiles/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
ln_if $HOME/.dotfiles/vscode/keybindings.json "$HOME/Library/Application Support/Code/User/keybindings.json"


# Update Homebrew
brew bundle --file=brewfile

# Install nvm if it doesnt exists
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
fi

# set iterm2 config
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string $HOME/.dotfiles/iterm2
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true


# Install oh-my-zsh if it doesnt exists
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
  chsh -s $(grep /zsh$ /etc/shells | tail -1)
fi
# macos stuff
source .macos
