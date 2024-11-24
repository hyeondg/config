export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=C.UTF-8
export CLICOLOR=1
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
export PATH=/home/hyeondg/bin/:/opt/nvim/:/opt/hyeondg/bin/:/usr/local/cuda/bin/:$PATH
export LD_LIBRARY_PATH=/opt/hyeondg/lib/:/usr/local/cuda/lib64/:$LD_LIBRARY_PATH
export EDITOR='vi'
export PS1='[\[\033[32m\]\u@\h\[\033[34m\] \w\[\033[31m\]${?#0}\[\033[00m\]]\$ '
unset command_not_found_handle
set -o vi
alias ls='ls --color'
