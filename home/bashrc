
# initialize or load ssh-agent

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi



set -o vi
set +o noclobber
export VISUAL=vim
export EDITOR="$VISUAL"
export PS1='\[\033[0;32m\][\[\033[0m\033[0;36m\]\u\[\033[0;32m\]@\[\033[0m\033[0;36m\]\h\[\033[0;32m\]]=[\[\033[0m\033[0;36m\]\t\[\033[0;32m\]]=[\[\033[0m\033[0;36m\]\w\[\033[0;32m\]]\n\[\033[0;32m\]=[\[\033[0m\033[0;36m\]\$\[\033[0;32m\]]>\[\033[0m\] '
export IGNOREEOF=0

LANG="en_US.UTF-8"

#alias touch="echo -n '' >>"
alias l='ls -Fh --color'
alias ll='ls -lh --color'
alias g++11='\g++  -std=c++11 -Wall -Wextra -Wpedantic -Weffc++ -L/sw/gcc-4.9.1/lib -static-libstdc++ -g'
alias pylint='pylint -f colorized'
alias vim=nvim
alias mv='mv -vb'
alias cp='cp -i'

alias sshliu='ssh johli603@ssh.edu.liu.se'

zathura () {
  \tabbed -c \zathura $1 -e
}

ansi () {
  \gcc -ansi -Wall -Wextra -Wpedantic $1 -lm
}

gansi () {
  \gcc -ansi -g -Wall -Wextra -Wpedantic $1 -lm
}

c99 () {
    gcc -Wall -Wextra -Wpedantic -std=gnu99 -g $@ -lm
}

# TDIU16 pintos
export PATH=$PATH:~/Bin:$HOME/Courses/tdiu16/pintos/src/utils
