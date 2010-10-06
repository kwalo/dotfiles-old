# The following lines were added by compinstall

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _complete _correct _expand
zstyle ':completion:*' completions 1
zstyle ':completion:*' menu select=long
zstyle ':completion:*' expand prefix
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format 'Completing %d:'
zstyle ':completion:*' glob 1
zstyle ':completion:*' group-name ''
zstyle ':completion:*' ignore-parents parent
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list 'r:|[._-]=** r:|=**'
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' prompt 'Corrections:'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' substitute 1
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.cpp~' '*?.pyc' '*?.java~'
zstyle :compinstall filename '/home/kaw/.zshrc'
zstyle ':mime:*' mailcap ~/.mailcap

autoload -U compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install

HISTFILE="${HOME}/.histfile"
HISTSIZE=500
SAVEHIST=500

setopt autocd \
    extendedglob \
    check_jobs \
    notify \
    multios \
    hist_ignore_all_dups \
    hist_ignore_space \
    NO_beep \
    always_to_end \
    auto_param_slash \
    rm_star_silent
bindkey -e
# End of lines configured by zsh-newuser-install
test -f ~/.zsh/prompt && source ~/.zsh/prompt
if [ -d ~/.zsh/functions ]; then
    fpath=(~/.zsh/functions $fpath)
fi

autoload -U venvinit; venvinit

# Environment variables
export EDITOR="vim" PAGER="less" 
if [[ -d ~/.local/bin ]]; then
    export PATH=~/.local/bin:$PATH
fi
WORDCHARS='.'

# Some aliases
alias ...=../..
alias ....=../../..
alias .....=../../../..
alias srm='sudo rm'
alias j="jobs"
alias ls='/bin/ls --color=auto'
alias l='/bin/ls --color=auto'
alias ll='/bin/ls --color=auto -lh'
alias la='/bin/ls --color=auto -ah'
alias lla='/bin/ls --color=auto -lah'
alias lal='/bin/ls --color=auto -alh'
alias lw='/bin/ls | wc -l'
alias grep='/bin/grep --colour=auto'
alias o='gnome-open'
alias gut=git
alias j512='java -Xmx512m -Xms512m'

[[ -x '/usr/bin/htop' ]] && alias top='/usr/bin/htop'

# rvm installer added line:
if [ -s ~/.rvm/scripts/rvm ] ; then source ~/.rvm/scripts/rvm ; fi

VENV_PRESERVE_PS1=1
source /home/kwalo/.profile
