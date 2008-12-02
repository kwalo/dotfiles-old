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
autoload -U zsh-mime-setup
zsh-mime-setup
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
    NO_beep \
    always_to_end \
    auto_param_slash \
    rm_star_silent
bindkey -e
# End of lines configured by zsh-newuser-install
source ~/.zshprompt

# Environment variables
export EDITOR="vim" PAGER="less" 
WORDCHARS='.'

# Some aliases
alias ...=../..
alias ....=../../..
alias .....=../../../..
alias srm='sudo rm'
alias ls='/bin/ls --color=auto'
alias l='/bin/ls --color=auto'
alias ll='/bin/ls --color=auto -lh'
alias la='/bin/ls --color=auto -ah'
alias lla='/bin/ls --color=auto -lah'
alias lal='/bin/ls --color=auto -alh'
alias lw='/bin/ls | wc -l'
alias grep='/bin/grep --colour=auto'
alias emacs='emacs -nw'
alias git-cat='PAGER=/bin/cat git show'
alias pu='phpunit'
alias o='gnome-open'

# Pass output of command to view
function pg()
{
    $@ | view -
}
[[ -x '/usr/bin/htop' ]] && alias top='/usr/bin/htop'
#[[ -x '/usr/local/sbin/wifi.py' ]] && alias wifi='sudo /usr/local/sbin/wifi.py'
[[ -x '/usr/local/bin/log' ]] && alias log=/usr/local/bin/log
true

