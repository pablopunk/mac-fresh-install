sudo echo # require sudo perms

# VARIABLES

dotfiles_folder="$HOME/.dotfiles"
dotfiles_repo="git@github.com:pablopunk/dotfiles" # The repo should have an install.sh script
node_version="$(curl -s https://versions.pablopunk.com/api/node/v14/latest)"

# SCRIPT

echo

# install homebrew for both mac/linux
hash brew 2>/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

function install_cask {
if [ "$(uname)" = "Darwin" ]
then
  ls /usr/local/Caskroom/$1 > /dev/null 2>&1 || brew install --cask $@
elif [ "$(uname)" = "Linux" ]
then
  ls /home/linuxbrew/.linuxbrew/Caskroom/$1 > /dev/null 2>&1 || brew install --cask $@
fi
}

function install_brew {
  if [ "$(uname)" = "Darwin" ]
  then
    ls /usr/local/Cellar/$1 > /dev/null 2>&1 || brew install $@
  elif [ "$(uname)" = "Linux" ]
  then
    ls /home/linuxbrew/.linuxbrew/Cellar/$1 > /dev/null 2>&1 || brew install $@
  fi
}

if [ "$(uname)" = "Darwin" ]
then
  echo "* macOS *"
  echo
  xcode-select -p 1>/dev/null || ( echo "Install xcode tools with `xcode-select --install`" && exit )

  echo "Cask apps"
  install_cask appcleaner
  install_cask google-chrome
  install_cask hyperswitch
  install_cask karabiner-elements
  install_cask kitty
  install_cask raycast
  install_cask slack
  install_cask spotify
  install_cask telegram-desktop
  install_cask whatsapp

  echo "Homebrew tools"
  install_brew bash-completion
  install_brew coreutils
  install_brew git-delta
  install_brew neovim
  install_brew nvm
  install_brew python
  install_brew ripgrep
  install_brew tmux
  install_brew tmuxinator
  install_brew watchman
  install_brew wget

  echo "Apple configs"
  # don't restore apps on reboot
  defaults write -g ApplePersistence -bool no
  # tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # mission control on three fingers up and app windows on down
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
  # disable hold keys to show keyboard popup keys
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  # better key repeat
  defaults write NSGlobalDomain InitialKeyRepeat -int 15
  defaults write NSGlobalDomain KeyRepeat -int 1
  # no delay for dock hiding
  defaults write com.apple.dock autohide-delay -float 0
  dscacheutil -flushcache
  # windows minimize on app icons
  defaults write com.apple.dock minimize-to-application -bool true
  # scaling effect on minimize
  defaults write com.apple.dock mineffect -string "scale"
  # make mission control work like exposé
  defaults write com.apple.dock expose-group-by-app -bool false
  # make Dock icons of hidden applications translucent
  defaults write com.apple.dock showhidden -bool true
  # zoom with ctrl+trackpad
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  # show status bar and path on Finder
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder ShowPathbar -bool true
  # show all file extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # drag with trackpad (not sure if it works)
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true


elif [ "$(uname)" = "Linux" ]
then
  echo "* linux *"

  function install_apt {
    sudo apt install $@ -y
  }

  echo "APT tools"
  sudo apt update
  install_apt build-essential
  install_apt curl
  install_apt git
  install_apt software-properties-common
  install_apt tmux
  install_apt vim
  install_apt zsh

  echo "Homebrew tools"
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
  install_brew git-delta
  install_brew neovim
  install_brew nvm
  install_brew python
  install_brew ripgrep
  install_brew tmuxinator
  install_brew watchman
fi

echo "Configure NVM"
export NVM_DIR="$HOME/.nvm"
mkdir -p $NVM_DIR
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # this loads nvm on macOS
[ -s "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" ] && . "/home/linuxbrew/.linuxbrew/opt/nvm/nvm.sh" # this one on linux
nvm install $node_version
nvm use $node_version
nvm alias default $node_version

echo "NPM tools"
function install_npm {
  [[ -d "$NVM_DIR/versions/node/$(<$NVM_DIR/alias/default)/lib/node_modules/$1" ]] || \
    npm i -g $@
}
install_npm bashy
install_npm eslint
install_npm eslint-config-standard
install_npm eslint-plugin-import
install_npm eslint-plugin-node
install_npm eslint-plugin-promise
install_npm eslint-plugin-react
install_npm eslint-plugin-standard
install_npm fd-find
install_npm neovim
install_npm odf
install_npm prettier
install_npm tldr
install_npm trash-cli
install_npm typescript
install_npm vercel

echo "Python tools"
function install_pip3 {
  python3 -m pip install $@
}
install_pip3 neovim --user
install_pip3 grip

echo "oh-my-zsh"
if [ ! -d $HOME/.oh-my-zsh ]
then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# echo "rust & cargo"
# hash cargo 2>/dev/null || curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y

echo
echo "Dotfiles"
if [ ! -d $dotfiles_folder ]
then
  git clone $dotfiles_repo $dotfiles_folder
  bash $dotfiles_folder/install.sh
fi

echo
