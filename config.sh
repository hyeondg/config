#!/bin/bash
GITNAME='hyeondg'
set -u

abort() {
  printf "%s\n" "$@"
  exit 1
}

# string formatters
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

pt() {
  printf "${tty_blue}===>${tty_bold} %s${tty_reset}\n" "$@"
}

if [ -z "${BASH_VERSION:-}" ]; then
    abort "Bash is required to interpret this script."
fi

# Check OS. Linux or Darwin.
OS="$(uname)"
WHEREAMI="$(pwd)"
DISTRO="$(uname -a | grep Ubuntu)"

if [[ "$OS" == "Darwin" ]]; then
  pt "Configuring Xcode command line developer tool"
  xcode-select --install 
  
  pt "Configuring homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  brew update && brew upgrade
  
  pt "Configuring bash"
  brew install bash
  sudo chsh -s /usr/local/bin/bash $USER
  
  pt "Configuring tmux"
  brew install tmux 

  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/macos/.bash_profile > ~/.bash_profile
  source ~/.bash_profile
  
  pt "Configuring vim"
  brew install vim

  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/macos/.tmux.conf > ~/.tmux.conf
  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/macos/.inputrc > ~/.inputrc
  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/macos/.vimrc > ~/.vimrc
  
  pt "Configuring python"
  brew install python3
  pip3 install --upgrade pip
  
  pt "Configuring ipython"
  pip3 install ipython
  
  cd
  mkdir -p .colorschemes
  cd .colorschemes 
  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/macos/Snazzy.terminal > Snazzy.terminal 
  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/macos/ProRes.terminal > ProRes.terminal
  
elif [[ "$OS" == "Linux" ]]; then #ubuntu
  sudo apt update && sudo apt upgrade
  # sudo dnf update
  
  pt "Configuring bash"
  sudo apt install bash
  # sudo dnf install bash
  sudo chsh -s /usr/bin/bash $USER
  # sudo usermod -s /usr/bin/bash $USER
  
  pt "Configuring tmux"
  sudo apt install tmux
  # sudo dnf install tmux
  
  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/ubuntu/.bashrc >> ~/.bashrc
  source ~/.bashrc
  
  #pt "Configuring gnome-tweak-tool"
  #sudo apt install gnome-tweak-tool
  
  #pt "Configuring chrome-gnome-shell"
  #sudo apt install chrome-gnome-shell

  pt "Configuring vim"
  sudo apt install vim
  # sudo dnf install vim
  
  pt "Configuring git"
  sudo apt install git
  
  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/ubuntu/.tmux.conf > ~/.tmux.conf
  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/ubuntu/.inputrc > ~/.inputrc
  curl -fsSl https://raw.githubusercontent.com/$GITNAME/configuration/HEAD/ubuntu/.vimrc > ~/.vimrc
fi 
pt "Configuring vundle"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

tmux source-file ~/.tmux.conf

mkdir -p ~/Workspace
cd $WHEREAMI
