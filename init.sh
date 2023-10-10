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

version="092023_0"
input=0
FETCHONLY=0
INTERACTIVE=0
ALL=0
FORDOCKER=0
SKIP=0

abort() 
{
    error "$@"
    exit 1
}

chomp() 
{
    printf "%s" "${1/"$'\n'"/}"
}

warn() 
{
    printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")" >&2
}

error() 
{
    printf "${tty_red}Error${tty_reset}: %s\n" "$(chomp "$1")" >&2
}

print() 
{
    printf "${tty_blue}===>${tty_bold} %s${tty_reset}\n" "$@"
}

ask() 
{
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

usage() 
{
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

ver()
{
    echo "version: $version"
    exit 0
}

ask_install()
{
    if [[ "$INTERACTIVE" -eq "1" ]]; then
        ask "$1"
        if [[ "$input" = "n" ]]; then
            SKIP=1
        fi
    fi
}

run_install()
{
    if [[ "$SKIP" -eq "0" ]]; then
        print "$1"
        case "$2" in 
            "clt") run() { xcode-select --install; }
                ;;
            "rst") run() { softwareupdate --install-rosetta --agree-to-license; }
                ;;
            "fch") run() { Fetch; }
                ;;
            "hbr") run() 
                {
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; 
                    (echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile;
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                }
                ;;
            "hbr_b") run() { brew bundle --file brewfile --verbose; }
                ;;
            "vim_p") run()
                {
                    /bin/sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
                    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
                }
                ;;
            "vag_p") run() { vagrant plugin install vagrant-parallels; }
                ;;
            *) run() { abort "nothing"; }
                ;;
        esac
        run
    fi
    SKIP=0
}




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
    esac
done

ForDocker()
{
    print 'Configuring profiles'
}

Fetch()
{
    print 'Configuring profiles'
    curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.zprofile' > $HOME/.zshrc
    curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.tmux.conf' > $HOME/.tmux.conf
    curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.screenrc' > $HOME/.screenrc
    curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.vimrc' > $HOME/.vimrc
    curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/brewfile' > $HOME/brewfile
    mkdir $HOME/.config
    curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/init.vim' > $HOME/.config/init.vim
    curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.vscodevimrc' > $HOME/.vscodevimrc
    curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.clang-format' > $HOME/.clang-format
}

OS="$(uname)"
pushd $HOME > /dev/null
if [[ "$OS" -eq "Darwin" ]]; then 
    mkdir -p .config/nvim
    if [[ "$FETCHONLY" -eq "1" ]]; then
        if [[ "$ALL" -eq "1" ]]; then
            abort "Wrong option $OPTARG"
        else 
            Fetch
            exit 0;
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

    ask_install "Install vagrant-parallels"
    run_install "Installing vagrant-parallels" "vag_p"

    print "Cleaning Up"
    rm brewfile 2> /dev/null
    defaults write -g ApplePressAndHoldEnabled -bool false               # disable diacritics suggestion
    defaults write com.apple.dock autohide-delay -float 0             # faster dock animation
    defaults write com.apple.dock autohide-time-modifier -float 0     
    defaults write com.apple.dock persistent-apps -array              # remove all items from dock
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file:///System/Applications/Launchpad.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
    killall cfprefsd; killall Dock 
else
    print "NOTHING"
    if [[ "$FORDOCKER" -eq "1" ]]; then
        print "Only for docker containers"
    fi
fi

popd > /dev/null

# vim-plug before nvim initialization
# vagrant plugin install vagrant-parallels is needed
# defaults write -g ApplePressAndHoldEnabled -bool false : disable diacritics suggestion


