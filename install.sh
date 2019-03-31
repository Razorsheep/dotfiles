#!/bin/bash

#inspiration https://github.com/adityarpillai/jumpstart/blob/master/jumpstart

set -e

# Display logo
echo -e "\n\033[38;5;255m\033[48;5;234m\033[1m                         \033[0m"
echo -e "\033[38;5;255m\033[48;5;234m\033[1m       .dotfiles         \033[0m"
echo -e "\033[38;5;255m\033[48;5;234m\033[1m       by @praffn        \033[0m"
echo -e "\033[38;5;255m\033[48;5;234m\033[1m                         \033[0m\n"

read -p "This script will install a lot of stuff, and change your settings. Press [enter] to continue..."; echo;

# creates symbol link $1 -> $2 iff $2 doesnt exists
ln_if () {
  if [ ! -f "$2" ]; then
    ln -s "$1" "$2"
  fi
}

# symlinks

echo "Setting up symbolic links"; echo;
ln_if $HOME/.dotfiles/git/gitignore_global $HOME/.gitignore_global
ln_if $HOME/.dotfiles/zsh/zsh-aliases $HOME/.zsh-aliases
ln_if $HOME/.dotfiles/zsh/zshrc $HOME/.zshrc
ln_if $HOME/.dotfiles/vim/vimrc $HOME/.vimrc

mkdir -p "$HOME/Library/Application Support/Code/User"
ln_if $HOME/.dotfiles/vscode/settings.json "$HOME/Library/Application Support/Code/User/settings.json"
ln_if $HOME/.dotfiles/vscode/keybindings.json "$HOME/Library/Application Support/Code/User/keybindings.json"


# Install Xcode Command Line tools
if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
  test -d "${xpath}" && test -x "${xpath}" ; then
  echo "Xcode Command Line Tools are already installed..."; echo;
else
  echo "Installing Xcode Command Line Tools..."; echo;
  xcode-select --install
fi

# Install Homebrew
if test ! $(which brew); then
  echo "Installing Homebrew";
  yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
else
  echo "Homebrew is already installed...";
fi

echo "Updating and upgrading Homebrew...";
yes | brew update &> /dev/null
yes | brew upgrade &> /dev/null

echo "Installing Homebrew packages..."; echo;
yes | brew bundle --file=brewfile &> /dev/null

# ZSH and oh-my-sh

# Install oh-my-zsh if it doesnt exists
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "oh-my-zsh is already installed..."
else
  echo "Installing oh-my-zsh..."
  git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh &> /dev/null
fi

# change shell to zsh if it isnt already
TEST_CURRENT_SHELL=$(basename "$SHELL")
if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
  echo "Changing shell to zsh"
  chsh -s $(grep /zsh$ /etc/shells | tail -1)
else
  echo "Shell is already zsh..."
fi

echo;


# nvm

# Install nvm if it doesnt exists
if [ -d "$HOME/.nvm" ]; then
  echo "NVM already installed...";
else
  echo "Installing NVM...";
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
fi

source ~/.nvm/nvm.sh
echo "Installing latest Node LTS via NVM..."; echo;
nvm install --lts &> /dev/null

# macos stuff
echo "Updating macOS preferences and settings..."; echo;
source .macos

echo -e "\033[1;92mDone!\033[0m"
echo "Close and open your terminal again, or source \$HOME/.zshrc"; echo;
