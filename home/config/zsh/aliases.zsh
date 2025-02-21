# split out so it can more easily be re-sourced without messing up stuff

# (%):-%x expands to current script path
alias re_source_aliases="source ${(%):-%x}"


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

# ts add timestamps, requires extra/moreutils
alias sway='sway | ts &> ~/.local/state/sway.log'

# install using `pipx install gpt-command-line`
alias claude='gpt --model claude-3-5-sonnet-latest'

# sudo pacman -S python-virtualenv python-uv
alias mkvenv='virtualenv .venv && source .venv/bin/activate && uv pip install --upgrade python-lsp-black python-lsp-ruff pylsp-mypy ipdb'
alias rmvenv='deactivate && \rm -r .venv'
ast() { astpretty --no "$1" | less -FX }
astlines() { astpretty "$1" | less -FX }

gitclone() { git clone git@github.com:"$1".git && cd ${1:t}; }
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
alias gwlist='git worktree list'

# use for `<operation that takes time> && vbeep` to get alerted when it finishes
# or C-z to suspend; then `fg && vbeep`
alias vbeep='echo -ne '\a''


# make sudo use aliases as well
alias sudo='sudo '

# alias movie='mplayer -vf expand=::0:0::16/9 -af scaletempo'
# alias plocate='plocate -d /home/h/.local/share/plocate/home.db'

#TODO: automatically update plocate database, and write alias to use the one in
#home

function pip() { command pip $@ && /usr/bin/pkill zsh --signal=USR1 }

function toggle_theme() {
    last_scheme=$(tail -n 1 ~/.config/.theme_history)
    echo "last scheme $last_scheme"
    if [ "$last_scheme" = "gruvbox-dark" ];then
        /usr/bin/theme.sh gruvbox
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    elif [ "$last_scheme" = "gruvbox" ]; then
        /usr/bin/theme.sh gruvbox-dark
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    fi
    new_scheme=$(tail -n 1 ~/.config/.theme_history)
    echo "new scheme $new_scheme"
    pkill -USR2 zsh
    sleep 0.1
    echo $new_scheme > ~/.config/.theme_history
}
function brightness() {
	ddcutil --brief --noverify -d 2 setvcp 10 $1 &&
	ddcutil --brief --noverify -d 1 setvcp 10 $1
}
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
    [[ $# -eq 0 ]] && echo "Error: Parameter required" && return 1
    MAIN_BRANCH=$(git rev-parse --verify main &> /dev/null && echo "main" || echo "master")
    git fetch --all &&
    gitdir=$(git rev-parse --git-common-dir) &&
    cd ${gitdir:h} &&
    git rebase &&
    git branch --no-track $1 origin/$MAIN_BRANCH &&
    git worktree add $1 $1 &&
    cd $1 &&
    yes n | ln -rs ../tox.ini
}
function gdwt() {
    git worktree remove $1 && git branch -d $1
}
_gdwt() {
    local -a worktrees
    #worktrees=(${(f)"$(git worktree list --porcelain | grep '^worktree' | cut -d' ' -f2-)"})
    worktrees=("${(@f)$(git worktree list --porcelain | grep '^worktree' | cut -d' ' -f2-)}")
    _describe 'worktrees' worktrees
}
#compdef _gdwt gdwt
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
