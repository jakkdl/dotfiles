# Lines configured by zsh-newuser-install
HISTFILE=~/.data/zsh/histfile
HISTSIZE=100000
SAVEHIST=50000
setopt appendhistory
setopt hist_ignore_dups
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/h/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# PATH modifications
# requested by pip for mypy
path+=('/home/hatten/.local/bin')
# export to sub-processes (make it inherited by child processes)
export PATH

alias l='/usr/bin/ls --color=auto --group-directories-first'
alias ll='/usr/bin/ls -lh --color=auto --group-directories-first'
alias vim=nvim
alias ls='echo "use l or ll"'

alias movie='mplayer -vf expand=::0:0::16/9 -af scaletempo'

