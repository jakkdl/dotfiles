# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH


if [[ ! -d $XDG_CACHE_HOME/zsh ]]; then
  mkdir $XDG_CACHE_HOME/zsh
fi
zstyle ':completion:*' use-cache on
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
    virtualenv
    git-prompt
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
#export ZPLUG_HOME=$XDG_DATA_HOME/zplug
#export ZPLUG_CACHE_DIR=$XDG_CACHE_HOME/zplug

#source "$ZPLUG_HOME/init.zsh"
#source "$SYS_ROOT/usr/share/zsh/scripts/zplug/init.zsh"
#zplug 'MichaelAquilina/zsh-autoswitch-virtualenv'

# source plugins and add commands to $PATH
#zplug load --verbose
#

# rip zplug, long live sheldon
#### sheldon ####
eval "$(sheldon source)"


#### zsh-autoswitch-virtualenv ####
export AUTOSWITCH_VIRTUAL_ENV_DIR=".venv"



if [[ ! -d $XDG_DATA_HOME/zsh ]]; then
  mkdir $XDG_DATA_HOME/zsh
fi
HISTFILE=$XDG_DATA_HOME/zsh/histfile
HISTSIZE=100000
SAVEHIST=50000
setopt appendhistory
setopt hist_ignore_dups

setopt nosharehistory
setopt nohistverify




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
    ssh-agent -t 24h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

#setopt prompt_subst
#export VIRTUAL_ENV_DISABLE_PROMPT=0
#autoload -Uz add-zsh-hook
# Configure Prompt
#function virtualenv_info(){
#    # Get Virtual Env
#    if [[ -n "$VIRTUAL_ENV" ]]; then
#        # Strip out the path and just leave the env name
#        venv="${VIRTUAL_ENV##*/}"
#    else
#        # In case you don't have one activated
#        venv=''
#    fi
#    [[ -n "$venv" ]] && echo "(venv:$venv) "
#}
#function virtualenv_info { 
    #[ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
#}
#virtualenv_prompt_info=""
#function update_virtualenv_prompt_info() {
#    if [ -n "${VIRTUAL_ENV+1}" ]; then
#        virtualenv_prompt_info=$(basename $VIRTUAL_ENV)
#    else
#        virtualenv_prompt_info=""
#    fi
#    echo poop
#    PROMPT='
#%{%(?.$fg_bold[green].$fg_bold[red])%}%~%{$reset_color%}$(git_prompt_info)$(virtualenv_prompt_info) ⌚ %{$fg_bold[red]%}%*%{$reset_color%}
#$ '
#}
#add-zsh-hook chpwd update_virtualenv_prompt_info
#VENV="\$(virtualenv_info)";
#PROMPT='
#%{%(?.$fg_bold[green].$fg_bold[red])%}%~%{$reset_color%}$(git_prompt_info)${VENV} ⌚ %{$fg_bold[red]%}%*%{$reset_color%}
#$ '
#PROMPT+='%{$fg[green]%}$(virtualenv_info)%{$reset_color%}%'

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
alias rm='rm -I'
alias ln='ln -vi'
alias pacmanremoveorphans='pacman -Qqtd | sudo pacman -Rns -'

alias sway='sway &> ~/.local/state/sway.log'

# install using `pipx install gpt-command-line`
alias claude='gpt --model claude-3-5-sonnet-latest'

alias mkvenv='python -m venv .venv && source .venv/bin/activate && pip install --upgrade pip python-lsp-black python-lsp-ruff pylsp-mypy ipdb'

gitclone() { git clone git@github.com:"$1".git && cd ${1:t}; }
ast() { astpretty --no "$1" | less -FX}
astlines() { astpretty "$1" | less -FX}
gitaddfork() { git remote add jakkdl git@github.com:jakkdl/$(basename `git rev-parse --show-toplevel`).git && git fetch --all && git config remote.pushDefault jakkdl && git config push.autoSetupRemote true}


# make sudo use aliases as well
alias sudo='sudo '

# alias movie='mplayer -vf expand=::0:0::16/9 -af scaletempo'
# alias plocate='plocate -d /home/h/.local/share/plocate/home.db'

#TODO: automatically update plocate database, and write alias to use the one in
#home

function pip() { command pip $@ && /usr/bin/pkill zsh --signal=USR1 }
# Trap SIGUSR1 signal, sent by pacman hook, to rehash the tab completion cache
TRAPUSR1() { rehash }
# pkill -USR2 zsh
TRAPUSR2() {
    last_scheme=$(tail -n 1 ~/.config/.theme_history)
    if [ "$last_scheme" = "gruvbox-dark" ];then
        /usr/bin/theme.sh gruvbox
    elif [ "$last_scheme" = "gruvbox" ]; then
        /usr/bin/theme.sh gruvbox-dark
    fi
}
/usr/bin/theme.sh $(tail -n 1 ~/.config/.theme_history)

# enable vi mode
bindkey -v

# remove esc-/ keybind, since it collides with esc, /
bindkey -r '^[/'

function brightness() {
	ddcutil --brief --noverify -d 2 setvcp 10 $1 &&
	ddcutil --brief --noverify -d 1 setvcp 10 $1
}

# debug in ipdb
export PYTHONBREAKPOINT=ipdb.set_trace
# don't have irritating spinners in tox
# currently bugged, see https://github.com/tox-dev/tox/issues/3193
# export TOX_PARALLEL_NO_SPINNER=1
# always use --develop to save setup time
alias tox='tox --develop'
alias toxall='tox --develop -qp -- --no-cov'
gitpruneremote() {
    git fetch --all --prune &&

    for branch in $(git branch -v |
            awk '/\[gone\]/ {sub(/^[\+*]/, "");print $1}'); do
        git worktree list |
            awk "/$branch/"' {print $1}' |
            xargs basename |
            xargs git worktree remove
    done

    git branch -v |
    grep -v '^[\+*]' |
    awk '/\[gone\]/ {print $1}' |
    #awk '/\[gone\]/ {sub(/^[\+*]/, "");print $1}' |
    xargs -I{} git branch -D {}
}
alias gfpush="git commit -a --amend --no-edit && git push --force-with-lease"
alias tox='tox -q'

# if running with pre-commit, and `git commit -a` fails with autofixes
# it's nontrivial to actually find what changes were made.
# So we first add the files to the index, and only afterwards commit, so
# if it fails we can do `git diff` and see the changes.
alias gitac='git add -u && git commit'

function newpr() {
    gitdir=$(git rev-parse --git-common-dir)
    cd ${gitdir:h} &&
    git branch $1 origin/main &&
    git worktree add $1 $1 &&
    cd $1 &&
    yes n | ln -rs ../tox.ini
}
function newpr_master() {
    gitdir=$(git rev-parse --git-common-dir)
    cd ${gitdir:h} &&
    git branch $1 origin/master &&
    git worktree add $1 $1 &&
    cd $1 &&
    yes n | ln -rs ../tox.ini
}
function resetfile() {
    git reset $1 -- $2
    git restore $2
    git restore --staged $2
}
function ghpr() {
    gh pr checkout $1
    git push -u $(git rev-parse --abbrev-ref --symbolic-full-name @\{u\} | cut -d '/' -f 1)
}
function mybranches() {
    git branch --remote --list --sort=-committerdate 'jakkdl/*' |
        awk -F '/' '{print $2}' |
        grep -vE 'main|master'
}
function darkmode() {
    #foreground
    echo -ne '\e]10;#ebdbb2\e\'
    # background
    echo -ne '\e]11;#282828\e\'
}
function lightmode() {
    #foreground
    echo -ne '\e]10;#3c3836\e\'
    #background
    echo -ne '\e]11;#fbf1c7\e\'
}
# requires package "extra/expect" for unbuffer, to trick the program to think we're
# outputting to a terminal and keep color w/o having to pass --color=always or similar
function man() {
    /usr/bin/man "$@" || { which $@ && unbuffer $@ --help |& less -R }
}
cst() { cstpretty "$1" | less --quit-if-one-screen --no-init --quit-at-eof --LINE-NUMBERS --incsearch }
export PYRIGHT_PYTHON_FORCE_VERSION=latest

PATH="/home/h/perl5/bin:/usr/bin/core_perl${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/h/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/h/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/h/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/h/perl5"; export PERL_MM_OPT;
#compdef toggl
_toggl() {
  eval $(env COMMANDLINE="${words[1,$CURRENT]}" _TOGGL_COMPLETE=complete-zsh  toggl)
}
if [[ "$(basename -- ${(%):-%x})" != "_toggl" ]]; then
  compdef _toggl toggl
fi

# open current line in external editor
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line


# home assistant
#source ~/.config/zsh/hass_token
#export HASS_SERVER=http://192.168.1.100:8123
# auto-completion
#source <(_HASS_CLI_COMPLETE=zsh_source hass-cli)


# enable Ctrl-Shift-g in foot for copying the output of last command to pastebuffer
function precmd {
    # also enable jumping between prompts (C-S-x/z)
    print -Pn "\e]133;A\e\\"
    if ! builtin zle; then
        print -n "\e]133;D\e\\"
    fi
}

function preexec {
    print -n "\e]133;C\e\\"
}
