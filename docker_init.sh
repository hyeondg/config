#!/bin/bash
if [[ -z "${BASH_VERSION:-}" ]]; then
    abort "Bash is required to interpret this script."
fi

pushd $HOME > /dev/null
curl -fsSL 'https://raw.githubusercontent.com/hyeondg/cfg/main/.bashrc' >> $HOME/.bashrc
curl -fsSL 'https://raw.githubusercontent.com/hyeondg/cfg/main/.vimrc' >> $HOME/.vimrc
curl -fsSL 'https://raw.githubusercontent.com/hyeondg/cfg/main/.screenrc' >> $HOME/.screenrc
curl -fsSL 'https://raw.githubusercontent.com/hyeondg/cfg/main/.tmux.conf' >> $HOME/.tmux.conf
popd
