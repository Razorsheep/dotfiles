#!/bin/bash

FLAG_UPDATE_BREW=true
FLAG_MACOS_PREF=true

while test $# -gt 0; do
  case "$1" in
    --no-brew-update|-nb)
      shift
      FLAG_UPDATE_BREW=false
      ;;
    --no-macos-preferences|-nm)
      shift
      FLAG_MACOS_PREF=false
      ;;
    *)
      echo "Uknown option '$1'"
      shift
      ;;
  esac
done

bold=$(tput bold)
green=$(tput setaf 76)
reset=$(tput sgr0)
grey=$(tput setaf 239)

put_header() {
  printf "\n${bold}===== %s =====${reset}\n" "$@"
}

put_step() {
  printf "➜ %s\n" "$@"
}

put_info() {
  printf "${grey}! %s\n${reset}" "$@"
}

put_success() {
  printf "${green}✔ %s${reset}\n" "$@"
}

set -e

# Display logo
echo -e "\n\033[38;5;255m\033[48;5;234m\033[1m                         \033[0m"
echo -e "\033[38;5;255m\033[48;5;234m\033[1m       .dotfiles         \033[0m"
echo -e "\033[38;5;255m\033[48;5;234m\033[1m       by @praffn        \033[0m"
echo -e "\033[38;5;255m\033[48;5;234m\033[1m                         \033[0m\n"

read -p "This script will install a lot of stuff, and change your settings. Press [enter] to continue..."; echo;

put_header "Symbolic Links"

# creates symbol link $1 -> $2 iff $2 doesnt exists
ln_if () {
  if [ ! -f "$2" ]; then
    ln -s "$1" "$2"
  fi
}

# symlinks

put_step "Setting up symbolic links"
# ln_if ./git/gitignore_global $HOME/.gitignore_global
ln_if ./dotfiles/zsh/zsh-aliases $HOME/.zsh-aliases
ln_if ./dotfiles/zsh/zshrc $HOME/.zshrc
put_success "Symbolic links created"

# Install Xcode Command Line tools
put_header "XCode Command Line Tools"

if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
  test -d "${xpath}" && test -x "${xpath}" ; then
  put_success "Xcode Command Line Tools are already installed...";
else
  put_step "Installing Xcode Command Line Tools..."; echo;
  xcode-select --install
  put_success "Xcode Command Line tools installed"
fi


# Install Homebrew
put_header "Homebrew"

if test ! $(which brew); then
  put_step "Installing Homebrew..."
  yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &> /dev/null
else
  put_info "Homebrew is already installed...";
fi

if $FLAG_UPDATE_BREW; then
  put_step "Updating and upgrading Homebrew...";
  yes | brew update &> /dev/null
  yes | brew upgrade &> /dev/null
  put_step "Installing Homebrew packages...";
  yes | brew bundle --file=brewfile &> /dev/null || true
  put_success "Homebrew installed, updated and upgraded"
else
  put_info "Skipping Homebrew update/upgrade...";
fi


# ZSH and oh-my-sh
put_header "ZSH and oh-my-zsh"

# Install oh-my-zsh if it doesnt exists
if [ -d "$HOME/.oh-my-zsh" ]; then
  put_info "oh-my-zsh is already installed..."
else
  put_step "Installing oh-my-zsh..."
  git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh &> /dev/null
fi

# change shell to zsh if it isnt already
TEST_CURRENT_SHELL=$(basename "$SHELL")
if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
  put_step "Changing shell to zsh"
  chsh -s $(grep /zsh$ /etc/shells | tail -1)
else
  put_info "Shell is already zsh..."
fi

put_success "oh-my-zsh installed and shell changed to zsh"


# nvm
put_header "NVM"

# Install nvm if it doesnt exists
if [ -d "$HOME/.nvm" ]; then
  put_info "NVM already installed...";
else
  put_step "Installing NVM...";
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash &> /dev/null
fi

source ~/.nvm/nvm.sh
put_step "Installing latest Node LTS via NVM..."
nvm install --lts &> /dev/null

put_success "NVM and latest Node LTS has been installed"

# Yarn Package Manager
put_header "Yarn"

if [ -d "$HOME/.yarn" ]; then
  put_step "Yarn already installed. Updating..."
else
  put_step "Installing Yarn..."
fi

curl -o- -L https://yarnpkg.com/install.sh 2> /dev/null | bash &> /dev/null

put_success "Yarn was successfully installed/updated!"


# macos stuff
put_header "macOS"
if $FLAG_MACOS_PREF; then
  put_step "Updating macOS preferences and settings (this might ask for password)..."; echo;
  source .macos
  put_success "macOS settings updated"
else
  put_info "Skipping updating macOS preferences..."
fi

printf "${bold}
            .     '     ,
               ${green}D O N E${reset}${bold}
              _________
           _ /_|_____|_\ _
             '. \   / .'
               '.\ /.'
                 '.'${reset}
\n"
put_info "Close and open your terminal again, or source \$HOME/.zshrc"
