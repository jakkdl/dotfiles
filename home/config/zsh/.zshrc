# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH


if [[ ! -d $XDG_CACHE_HOME/zsh ]]; then
  mkdir $XDG_CACHE_HOME/zsh
fi
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/zcompcache


#### oh-my-zsh ####
# Path to your oh-my-zsh installation.
ZSH="$SYS_ROOT/usr/share/oh-my-zsh/"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="amuse"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$XDG_CONFIG_HOME/zsh/custom/

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    colored-man-pages
    gitfast
    git-escape-magic
    poetry
    #git-prompt
    #github https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/github
)


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"


# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh

# end of /usr/share/oh-my-zsh/zshrc



#### ZPLUG ####
export ZPLUG_HOME=$XDG_DATA_HOME/zplug
export ZPLUG_CACHE_DIR=$XDG_CACHE_HOME/zplug

#source "$ZPLUG_HOME/init.zsh"
source "$SYS_ROOT/usr/share/zsh/scripts/zplug/init.zsh"
zplug 'MichaelAquilina/zsh-autoswitch-virtualenv'

# source plugins and add commands to $PATH
zplug load --verbose


#### zsh-autoswitch-virtualenv ####
export AUTOSWITCH_VIRTUAL_ENV_DIR=".virtualenv"



if [[ ! -d $XDG_DATA_HOME/zsh ]]; then
  mkdir $XDG_DATA_HOME/zsh
fi
HISTFILE=$XDG_DATA_HOME/zsh/histfile
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


### powerline
#powerline-daemon -q
#. /usr/share/powerline/bindings/zsh/powerline.zsh

# initialize or load ssh-agent
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi


# initialize/load gnome-keyring
if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

# aliases
alias l='/usr/bin/ls --color=auto --group-directories-first'
alias ls=l
alias ll='/usr/bin/ls -lh --color=auto --group-directories-first'
alias vim='nvim -p'
alias vimdiff='nvim -d'
alias pylint='pylint -f colorized'

alias mv='mv -vi'
alias cp='cp -vi'
alias rm='rm -vI'
alias ln='ln -vi'

alias sway='sway &> /tmp/sway.log'

gitclone() { git clone git@github.com:"$1".git; }

# make sudo use aliases as well
alias sudo='sudo '

# alias movie='mplayer -vf expand=::0:0::16/9 -af scaletempo'
# alias plocate='plocate -d /home/h/.local/share/plocate/home.db'

#TODO: automatically update plocate database, and write alias to use the one in
#home

# Trap SIGUSR1 signal, sent by pacman hook, to rehash the tab completion cache
TRAPUSR1() { rehash }
bindkey -v

# debug in ipdb
export PYTHONBREAKPOINT=ipdb.set_trace
