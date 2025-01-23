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

# sudo pacman -S python-virtualenv python-uv
alias mkvenv='virtualenv .venv && source .venv/bin/activate && uv pip install --upgrade python-lsp-black python-lsp-ruff pylsp-mypy ipdb'
alias rmvenv='deactivate && \rm -r .venv'

gitclone() { git clone git@github.com:"$1".git && cd ${1:t}; }
ast() { astpretty --no "$1" | less -FX }
astlines() { astpretty "$1" | less -FX }
gitconfigfork() {
    git fetch --all &&
    git config remote.pushDefault jakkdl &&
    git config push.autoSetupRemote true &&
    git config branch.main.rebase true &&
    git config branch.main.pushRemote no_push
}
gitaddfork() {
    git remote add jakkdl git@github.com:jakkdl/$(basename `git rev-parse --show-toplevel`).git &&
    gitconfigfork
}


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
    INHIBIT_THEME_HIST=1 /usr/bin/theme.sh "$last_scheme"
}
INHIBIT_THEME_HIST=1 /usr/bin/theme.sh $(tail -n 1 ~/.config/.theme_history)

function toggle_theme() {
    last_scheme=$(tail -n 1 ~/.config/.theme_history)
    echo "last scheme $last_scheme"
    if [ "$last_scheme" = "gruvbox-dark" ];then
        /usr/bin/theme.sh gruvbox
    elif [ "$last_scheme" = "gruvbox" ]; then
        /usr/bin/theme.sh gruvbox-dark
    fi
    new_scheme=$(tail -n 1 ~/.config/.theme_history)
    echo "new scheme $new_scheme"
    pkill -USR2 zsh
    sleep 0.1
    echo $new_scheme > ~/.config/.theme_history
}

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

# pytest does not handle PYTHONBREAKPOINT perfectly, e.g. not disabling faulthandler_timeout
# but if we supply the same with --pdbcls then we're fine
alias pytest='pytest --pdbcls=IPython.terminal.debugger:TerminalPdb'


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
    git fetch --all &&
    gitdir=$(git rev-parse --git-common-dir) &&
    cd ${gitdir:h} &&
    git rebase &&
    git branch --no-track $1 origin/main &&
    git worktree add $1 $1 &&
    cd $1 &&
    yes n | ln -rs ../tox.ini
}
function newpr_master() {
    git fetch --all &&
    gitdir=$(git rev-parse --git-common-dir)
    cd ${gitdir:h} &&
    git branch --no-track $1 origin/master &&
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

function relpyright() {
    pyright --outputjson "$@" | jq -r -f ~/.local/bin/pyright_rel_path.jq --arg cwd "$(pwd)"
}
# recreating colored-man-pages
export MANROFFOPT="-c"
function color_man() {
    env \
    LESS_TERMCAP_md=$(tput bold; tput setaf 4) \
    LESS_TERMCAP_me=$(tput sgr0) \
    LESS_TERMCAP_mb=$(tput blink) \
    LESS_TERMCAP_us=$(tput setaf 2) \
    LESS_TERMCAP_ue=$(tput sgr0) \
    LESS_TERMCAP_so=$(tput smso) \
    LESS_TERMCAP_se=$(tput rmso) \
    man "$@"
}
# requires package "extra/expect" for unbuffer, to trick the program to think we're
# outputting to a terminal and keep color w/o having to pass --color=always or similar
function man() {
    color_man "$@" || { which $@ && unbuffer $@ --help |& less -R }
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

# STARSHIP (prompt)
# sudo pacman -S starship ttf-firacode-nerd
eval "$(starship init zsh)"
