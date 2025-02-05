if [[ ! -d $XDG_CACHE_HOME/zsh ]]; then
  mkdir $XDG_CACHE_HOME/zsh
fi
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/zcompcache
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;:sg=30;46:tw=30;42:ow=30;43'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# case and hypen-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}'

# export MANPATH="/usr/local/man:$MANPATH"

#### sheldon ####
eval "$(sheldon source)"

# Update sheldon plugins if 36 hours have passed since last check
SHELDON_UPDATE_FILE="$XDG_CACHE_HOME/sheldon_last_update"
if [[ ! -f $SHELDON_UPDATE_FILE ]] || \
   [[ $(( ($(date +%s) - $(stat -c %Y "$SHELDON_UPDATE_FILE")) / 3600 )) -gt 36 ]]; then
    echo "Updating sheldon plugins..."
    sheldon lock --update
    touch "$SHELDON_UPDATE_FILE"
fi

#gitfast -- supposedly adds faster git completion? I'm gonna try to run without it and see if there's a difference
#git-escape-magic -- I don't think this one is necessary when `nomatch` is unset

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


# initialize or load ssh-agent
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 24h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

# initialize/load gnome-keyring
if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start)
    export SSH_AUTH_SOCK
fi

# Trap SIGUSR1 signal, sent by pacman hook, to rehash the tab completion cache
TRAPUSR1() { rehash }
# pkill -USR2 zsh
TRAPUSR2() {
    last_scheme=$(tail -n 1 ~/.config/.theme_history)
    INHIBIT_THEME_HIST=1 /usr/bin/theme.sh "$last_scheme"
}
INHIBIT_THEME_HIST=1 /usr/bin/theme.sh $(tail -n 1 ~/.config/.theme_history)


# enable vi mode
bindkey -v

# remove esc-/ keybind, since it collides with esc, /
bindkey -r '^[/'


# debug in ipdb
export PYTHONBREAKPOINT=ipdb.set_trace

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

# enable C-S-n
function osc7-pwd() {
    emulate -L zsh # also sets localoptions for us
    setopt extendedglob
    local LC_ALL=C
    printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
}

function chpwd-osc7-pwd() {
    (( ZSH_SUBSHELL )) || osc7-pwd
}
add-zsh-hook -Uz chpwd chpwd-osc7-pwd

source ~/.config/zsh/aliases.zsh

# STARSHIP (prompt)
# sudo pacman -S starship ttf-firacode-nerd
eval "$(starship init zsh)"
