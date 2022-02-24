# Set XDG Base Directories
## Where user-specific configurations should be written (analogous to /etc).
export XDG_CONFIG_HOME=$HOME/.config
## Where user-specific non-essential (cached) data should be written (analogous
## to /var/cache).
export XDG_CACHE_HOME=$HOME/.cache
## Where user-specific data files should be written (analogous to /usr/share).
export XDG_DATA_HOME=$HOME/.local/share

## Where user-specific state files should be written (analogous to /var/lib).
export XDG_STATE_HOME=$HOME/.local/state

#XDG_RUNTIME_DIR
#Used for non-essential, user-specific data files such as sockets, named pipes,
#etc. Not required to have a default value; warnings should be issued if not
#set or equivalents provided.
#Must be owned by the user with an access mode of 0700.
#Filesystem fully featured by standards of OS.
#Must be on the local filesystem.
#May be subject to periodic cleanup.
#Modified every 6 hours or set sticky bit if persistence is desired.
#Can only exist for the duration of the users login.
#Should not store large files as it may be mounted as a tmpfs.
#pam_systemd sets this to /run/user/$UID.

## System directories
export XDG_DATA_DIRS=/usr/local/share:/usr/share.
export XDG_CONFIG_DIRS=/etc/xdg.

# Make zsh use XDG directories
export HISTFILE="$XDG_STATE_HOME"/zsh/history

# didn't work, and I don't really care for putting it in custom directory
#if [[ ! -d $XDG_CACHE_HOME/zsh ]]
#then
#    mkdir $XDG_CACHE_HOME/zsh
#fi
#compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
export VISUAL=$EDITOR

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# PATH modifications
# requested by pip for mypy
path+=('/home/h/.local/bin')
path+=('/home/h/Bin')
# export to sub-processes (make it inherited by child processes)
export PATH
