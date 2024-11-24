eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/opt/binutils/bin:$PATH"
eval "$(rbenv init - zsh)"
export LANG=en_US.UTF-8
export PATH="$HOME/.cargo/bin:$PATH"
export CPATH=/opt/homebrew/include
export LIBRARY_PATH=/opt/homebrew/lib
export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"
export CONDA_AUTO_ACTIVATE_BASE=true
export CLICOLOR=1
export DISPLAY=:0
export KEYTIMEOUT=1
export PS1='[%F{green}%n@%m%f:%F{blue}%1~%f]$ '
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
unset command_not_found_handle
bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char
bindkey -a -r ':'
alias nv='nvim'
