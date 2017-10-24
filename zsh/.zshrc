#!/bin/zsh

#-----------------------------------------------------------------------------
### Notes
#
# Inspiration for some of the commands and aliases:
#  - http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc

#-----------------------------------------------------------------------------
### Environment variables

export SHELL='/bin/zsh'
export PAGER=${PAGER:-less}
export EDITOR=${EDITOR:-vim}

if [[ `uname` == 'Darwin' ]]; then
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:/usr/local/opt/python/libexec/bin:/usr/local/bin:$PATH:/usr/local/texlive/2017/bin/x86_64-darwin"
fi

# Are we connected via SSH?
if [[ -z "$SSH_CONNECTION" ]] ; then
    PROMPT_HOST=""
else
    # Display @host in prompt when connected with SSH
    PROMPT_HOST="%{[33m%}@%{[37m%}%m"
    export TMOUT=7200
fi

# Automatically logout after timeout when connected as root
if [ "`id -u`" -eq 0 ]; then
    # Temps fixé ici à 10 mins
    export TMOUT=600
fi

# Set python variables
if [[ -f ~/.pythonrc.py ]] ; then
    export PYTHONSTARTUP=~/.pythonrc.py
fi
export PYTHONPATH=$PYTHONPATH:'.':$HOME'/Code'

# support colors in less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'


#-----------------------------------------------------------------------------
### Prompt handling

set_prompt() {
    # Displays the return code on the right side if last command's return code was not 0
    RPROMPT="%{[31;1m%}%(?..[%?])%{[0m%} ${TIMEREM}"
    
    if [ "`id -u`" -eq 0 ]; then
        PROMPT="%{[36;1m%}%T %{[31;1m%}%n${PROMPT_HOST} %{[32m%}%35<...<%~%{[33m%}%#%{[0m%} "
    else
        PROMPT="%{[36;1m%}%T %{[34;1m%}%n${PROMPT_HOST} %{[32m%}%35<...<%~%{[33m%}%#%{[0m%} "
    fi
}

set_title() {
    # Titre de la fenêtre d'un xterm
    case $TERM in
        xterm*)
            set_title() { print -Pn "\e]0;%n@%m: %~\a" } ;;
        *rxvt*)
            set_title() { print -Pn "\e]0;%n@%m: %~\a" } ;;
        *)
            set_title() { } ;;
    esac
}
set_title
set_prompt
precmd () { set_title }


#-----------------------------------------------------------------------------
### Aliases

if [ "`id -u`" -eq 0 ]; then
    # Aliases only defined for root
    alias aa='aptitude update && aptitude upgrade'
    alias ac='aptitude clean'
    alias au='aptitude upgrade'
    alias ad='aptitude dist-upgrade'
    alias as='apt-cache search'

    alias setdate='date +%T -s'
    alias settime='date +%Y%m%d -s'
else
    # Aliases only defined as non-root
    alias h='sudo halt'
    alias reboot='sudo reboot'
fi

alias x='startx -- -dpi 110'
alias s='screen -xaAR'
alias t='if tmux has; then tmux attach; else tmux new; fi'
if [[ `uname` == 'Darwin' ]]; then
    alias ls='gls --classify --tabsize=0 --literal --color=auto --show-control-chars --human-readable --group-directories-first --hide="*~"'
else
    alias ls='ls --classify --tabsize=0 --literal --color=auto --show-control-chars --human-readable --group-directories-first --hide="*~"'
fi
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias grep='grep --color=auto --line-number'
alias ack='ack-grep'
alias i='grep'
alias less='less -R'
alias ps='ps -ef'
alias df='df -h'
alias du='du -h'
alias tree='tree -F --dirsfirst'
alias killuser='skill -KILL -u'

alias svnignore='svn propedit svn:ignore .'
svndiff() {
    svn diff $1 | colordiff | less
}
svnautoremove () {
    svn status | grep '^!' | sed "s/^[^ ]*\s*//" | sed 's/./\\&/g' | xargs svn remove
}
svnautoadd () {
    svn status | grep '^?' | sed "s/^[^ ]*\s*//" | sed 's/./\\&/g' | xargs svn add
}

if [[ `uname` == 'Darwin' ]]; then
    cdf () {
        # Goes to the folder currently opened in Finder
        # From: https://github.com/herrbischoff/awesome-osx-command-line
        cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
    }
fi


#-----------------------------------------------------------------------------
### Terminal configuration

# Disable beeps
unsetopt beep
unsetopt hist_beep
unsetopt list_beep
unsetopt rm_star_silent

# Try to avoid the 'zsh: no matches found...'
setopt nonomatch

# Nice auto-completion
unsetopt list_ambiguous
autoload -U compinit
compinit

# Various completion options
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BNo matches for: %d%b'
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# Cache completion in /tmp/.zsh_cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path /tmp/.zsh_cache

# Auto-completion of process id for kill command
zstyle ':completion:*:processes' command 'ps -ef'
# zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=31"

# Auto-completion of host for SSH/SCP/SFTP
if [[ -f ~/.ssh/known_hosts ]] ; then
    local _myhosts
    _myhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} )
    zstyle ':completion:*:(ssh|scp|sftp)' hosts $_myhosts
fi

# Complete everywhere, not just at the end
setopt completeinword

# Activate color-completion
zmodload zsh/complist
autoload colors
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors 'reply=( "=(#b)(*$VAR)(?)*=00=$color[green]=$color[bg-green]" )'

# Ignore duplicate entries
zstyle ':completion:*:history-words'   remove-all-dups yes
zstyle ':completion:*:history-words'   stop yes

# Separate matches into groups
zstyle ':completion:*:matches'         group 'yes'
zstyle ':completion:*'                 group-name ''

# Describe options in full
zstyle ':completion:*:options'         description 'yes'

# Provide verbose completion information
zstyle ':completion:*'                 verbose true

# Complete manual by their section
#~ zstyle ':completion:*:manuals'    separate-sections true
#~ zstyle ':completion:*:manuals.*'  insert-sections   true
#~ zstyle ':completion:*:man:*'      menu yes select

zstyle ':completion:*'                 rehash

setopt auto_remove_slash
# Disable completion on dotfiles
#~ unsetopt glob_dots

# Handles links
setopt chase_links

setopt hist_verify
setopt hist_reduce_blanks

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_silent
setopt pushd_to_home

# Background process settings
unsetopt bg_nice
unsetopt hup

setopt nullglob


#-----------------------------------------------------------------------------
### Commands history settings

export HISTORY=100000
export SAVEHIST=100000

export HISTFILE=$HOME/.history

setopt append_history
setopt inc_append_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_expire_dups_first
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt extended_history

bindkey -e
bindkey '^[[5~' history-search-backward # PgUp
bindkey '^[[6~' history-search-forward  # PgDn


#-----------------------------------------------------------------------------
### Usefull mini command-line tools

# Starts a HTTP server serving the current wording directory
# Usage: http <listen port>
http() {
    if [ "`id -u`" -eq 0 ]; then
        PORT=${1:-80}
    else
        PORT=${1:-8080}
    fi
    if [ "$PORT" == 80 ]; then
        ip addr | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}/' | sed 's/\///' | awk '{print "\033[34;01mhttp://"$1"\033[00m"}'
    else
        ip addr | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}/' | sed "s/\//:$PORT/" | awk '{print "\033[34;01mhttp://"$1"\033[00m"}'
    fi
    python -m SimpleHTTPServer $PORT
}

# Starts a FTP server serving the current wording directory
# Usage: ftp <listen port>
ftp() {
    if [ "`id -u`" -eq 0 ]; then
        PORT=${1:-21}
    else
        PORT=${1:-2121}
    fi
    python -m pyftpdlib -p $PORT -w
}

# Converts Dia files to PDF through EPS output
# Usage: dia2pdf [filename]
dia2pdf() {
    dia --export /tmp/temp.eps $1 && epstopdf /tmp/temp.eps /tmp/temp.pdf && rm /tmp/temp.eps && mv /tmp/temp.pdf $1:r.pdf
}

# Converts .svg to .pdf
# Usage: svg2pdf [filename]
svg2pdf() {
    # inkscape -f $1 -A $1.pdf
    inkscape -D -z --file=$1 --export-pdf=$1:r.pdf
}

# Converts .tcx (Garmin Training File) to .gpx
# Usage: tcx2gpx [filename]
tcx2gpx() {
    gpsbabel -i gtrnctr -f $1 -o gpx -F $1:r.gpx
}


#-----------------------------------------------------------------------------

if type "direnv" > /dev/null; then
    eval "$(direnv hook zsh)"
fi
