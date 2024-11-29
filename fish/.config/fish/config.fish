set fish_greeting

set fish_color_error white --dim
set fish_color_param normal
set fish_color_command normal --bold

set -Ux GOPATH $HOME/gopath
fish_add_path $HOME/go/bin
fish_add_path $HOME/gopath/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.zig

alias t='tmux new-session -A -s default'
alias ls='ls --classify --tabsize=0 --literal --color=auto --show-control-chars --human-readable --group-directories-first --hide="*~"'
alias ll='ls -l'
alias la='ls -A'
alias lla='ls -lA'
alias grep='grep --color=auto'
alias ps='ps -ef'
alias df='df -h'
alias du='du -h'
alias tree='tree -F --dirsfirst'

if test -e /usr/bin/nvim
	alias vi='nvim'
	alias vim='nvim'
	alias v='nvim +FZF!'
	alias vg='nvim +FZFgit'
else
	alias vi='vim'
	alias v='vim +FZF!'
	alias vg='vim +FZFgit'
end

if test -e /usr/bin/direnv
	direnv hook fish | source
end

function fish_prompt
	# Show the username in red when user is root
	set -l ucolor blue
	if fish_is_root_user
		set -l ucolor red
	end

	# Displays the hostname when connected via SSH
	set phostname ""
	if test -n "$SSH_CONNECTION"
		set phostname (set_color -o yellow)@(set_color -o white)$hostname
	end

	printf '%s %s %s%s%s ' (set_color -o cyan)(date '+%H:%M') (set_color -o $ucolor)(whoami)$phostname (set_color -o green)(prompt_pwd) (set_color normal)(fish_git_prompt) (set_color yellow)%(set_color normal)
end
