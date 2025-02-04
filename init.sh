#!/bin/bash

if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_green="$(tty_mkbold 32)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

version="052024_0"
input=0
FETCHONLY=0
INTERACTIVE=0
ALL=0
FORDOCKER=0
SKIP=0

abort() {
  error "$@"
  exit 1
}

chomp() {
  printf "%s" "${1/"$'n'"/}"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
}

error() {
  printf "${tty_red}Error${tty_reset}: %s\n" "$(chomp "$1")" >&2
}

print() {
  printf "${tty_blue}===>${tty_bold} %s${tty_reset}\n" "$@"
}

ask() {
  while true; do
    printf "${tty_green}>>${tty_bold} %s?" "$@"
    read -p "${tty_bold} (y/n) ${tty_reset}" input
    if [[ "$input" = "y" ]]; then
      break
    elif [[ "$input" = "n" ]]; then
      break
    else
      error "Invalid input: $input"
    fi
  done

}

usage() {
  echo "usage: init.sh [-adifhv] [-c progress]"
  echo "  -a            all"
  echo "  -d            minimal setup for docker containers"
  echo "  -i            install the packages interactively"
  echo "  -f            only fetch the config files"
  echo "  -h            help!"
  echo "  -v            version"
  echo "  -c progress   specify the starting point"
  exit 0
}

ver() {
  echo "version: $version"
  exit 0
}

ask_install() {
  if [[ "$INTERACTIVE" -eq 1 ]]; then
    ask "$1"
    if [[ "$input" = "n" ]]; then
      SKIP=1
    fi
  fi
}

run_install() {
  if [[ "$SKIP" -eq 0 ]]; then
    print "$1"
    case "$2" in
    "clt")
      run() { xcode-select --install; }
      ;;
    "rst")
      run() { softwareupdate --install-rosetta --agree-to-license; }
      ;;
    "fch")
      run() { Fetch; }
      ;;
    "hbr")
      run() {
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        (echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >>$HOME/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
      }
      ;;
    "hbr_b")
      run() { brew bundle --file brewfile --verbose; }
      ;;
    "vim_p")
      run() {
        /bin/sh -c 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
      }
      ;;
    "vag_p")
      run() { vagrant plugin install vagrant-parallels; }
      ;;
    *)
      run() { echo "nothing is going on:("; }
      ;;
    esac
    run
  fi
  SKIP=0
}

ForDocker() {
  print 'Configuring profiles'
}

Fetch() {
  print 'Configuring profiles'
  curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.zprofile' >$HOME/.zshrc
  curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.tmux.conf' >$HOME/.tmux.conf
  curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.screenrc' >$HOME/.screenrc
  curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.vimrc' >$HOME/.vimrc
  curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/brewfile' >$HOME/brewfile
}

# #################################################################################################################

if [[ -z "${BASH_VERSION:-}" ]]; then
  abort "Bash is required to interpret this script."
fi

[ $# -eq 0 ] && usage

while getopts ":ahfiv" opt; do
  case $opt in
  a)
    ALL=1
    ;;
  d)
    FORDOCKER=1
    ;;
  f)
    FETCHONLY=1
    ;;
  i)
    INTERACTIVE=1
    ;;
  v)
    ver
    ;;
  h)
    usage
    ;;
  *)
    abort "Undefined option: $OPTARG"
    ;;
  esac
done

OS="$(uname)"
pushd $HOME >/dev/null
if [[ "$OS" == "Darwin" ]]; then
  if [[ "$FETCHONLY" -eq 1 ]]; then
    if [[ "$ALL" -eq 1 ]]; then
      abort "Wrong option $OPTARG"
    else
      Fetch
      exit 0
    fi
  fi

  ask_install "Install Command Line Tools"
  run_install "Installing Command Line Tools" "clt"

  if [[ "$(uname -m | grep -i 'arm64')" ]]; then
    ask_install "Install Rosetta 2"
    run_install "Installing Rosetta 2" "rst"
  fi

  ask_install "Override the config files"
  run_install "Fetch" "fch"

  ask_install "Install Homebrew"
  run_install "Installing Homebrew" "hbr"

  ask_install "Unpack Homebrew Bundle"
  run_install "Unpacking Homebrew Bundle" "hbr_b"

  ask_install "Install vim-plug"
  run_install "Installing vim-plug" "vim_p"

  # ask_install "Install vagrant-parallels"
  # run_install "Installing vagrant-parallels" "vag_p"

  print "Cleaning Up"
  rm brewfile 2>/dev/null
  defaults write -g ApplePressAndHoldEnabled -bool false # disable diacritics suggestion
  defaults write com.apple.dock autohide-delay -float 0  # faster dock animation
  defaults write com.apple.dock autohide-time-modifier -float 0
  defaults write com.apple.dock persistent-apps -array # remove all items from dock
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///System/Applications/Launchpad.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
  killall cfprefsd
  killall Dock
  
elif [[ "$OS" == "Linux" ]]; then
  mkdir -p $HOME/.config/nvim/
  mkdir -p $HOME/bin/

  IS_UBUNTU=$(cat /etc/*-release | grep 'ubuntu')

  if [[ $IS_UBUNTU = "" ]]; then
    # Fedora
    sudo echo -e "[main]\nfastestmirror=True\nmax_parallel_downloads=10\ngpgcheck=True\ninstallonly_limit=3\nclean_requirements_on_remove=True\nbest=False\nskip_if_unavailable=True\n" | sudo tee /etc/dnf/dnf.conf > /dev/null
    sudo dnf update -y
    sudo dnf install -y vim git cmake clang wget htop tmux xclip xrdp certbot firewall-config wl-clipboard luarocks
    sudo dnf install 'dnf-command(versionlock)'
    sudo dnf install dnf-plugins-core fedora-repos-rawhide fedora-workstation-repositories
    # sudo dnf install -y fcitx5 fcitx5-hangul fcitx5-anthy kcm-fcitx5 fcitx5-autostart
    # sudo dnf install -y langpacks-ja langpacks-ko terminus-fonts-console
    # sudo dnf install -y plasma-workspace-x11
    # sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
    # sudo dnf install -y kernel-devel kernel-headers dkms libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
    # sudo dnf install -y gmp-devel mpfr-devel libmpc-devel glibc-devel.i686 libgcc.i686
    # sudo dnf group install -y "Development Tools"

    # RPM Fusion
    sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf update @core

    # Docker
    # dnf4
    # sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    # sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # dnf5 workaround
    REPO_URL="https://download.docker.com/linux/fedora/docker-ce.repo"
    TMP_REPO_FILE="$(mktemp --dry-run)"
    curl -fsSL "${REPO_URL}" | tr -s '\n' > "${TMP_REPO_FILE}"
    sudo dnf5 config-manager addrepo --save-filename=docker-ce.repo --from-repofile="${REPO_URL}"
    sudo dnf5 install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service

    # HiDPI
    sudo /bin/bash -c 'echo FONT=\"ter-m32n\" >> /etc/vconsole.conf'

    # Nvidia
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo | \
    sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
    
    # TODO: DNF5 support
    sudo dnf config-manager --enable nvidia-container-toolkit-experimental
    sudo dnf install -y nvidia-container-toolkit

    # code
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    sudo dnf install -y code # or code-insiders

  else
    # Ubuntu

    print "Running apt-get"
    sudo apt-get update
    sudo apt-get install curl certbot firewall-config git cmake clang wget htop tmux vim xclip xrdp fcitx5 fcitx5-hangul fcitx5-anthy language-pack-ko language-pack-ja openssh-server wl-clipboard

    sudo apt-get install -y flatpak
    flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # Nvidia
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit

    # Add Docker's official GPG key:
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo systemctl enable firewalld
    sudo systemctl enable xrdp
    sudo systemctl enable ssh
    
    # xrdp into ssl-cert group
    sudo adduser xrdp ssl-cert  
    
    # langauge support
    sudo apt install $(check-language-support -l en)
  fi

  # Fetch config files
  print "Fetching config files"
  curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.bashrc' >> $HOME/.bashrc
  curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.tmux.conf' > $HOME/.tmux.conf
  curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.vimrc' > $HOME/.vimrc
  curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/init.vim' > $HOME/.config/nvim/init.vim

  # Installing miniconda (user)
  mkdir -p ~/miniconda3
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
  bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
  rm -rf ~/miniconda3/miniconda.sh
  ~/miniconda3/bin/conda init bash
  ~/miniconda3/bin/conda config --set auto_activate_base false

  # Save git credential 
  git config --global user.name 'hyeondg'
  git config --global user.email 'me@hyeondg.org'
  git config --global credential.helper cache

  # Install vimplug
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  # code-server
  curl -fsSL https://code-server.dev/install.sh | sh

  # coder
  curl -L https://coder.com/install.sh | sh

fi

popd >/dev/null

# vim-plug before nvim initialization
# vagrant plugin install vagrant-parallels is needed
# defaults write -g ApplePressAndHoldEnabled -bool false : disable diacritics suggestion
