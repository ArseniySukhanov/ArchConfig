HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt autocd beep extendedglob

bindkey -v

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

autoload -U colors && colors

source $ZDOTDIR/zplugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZDOTDIR/zplugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/zplugins/zsh-colored-man-pages/colored-man-pages.plugin.zsh
source $ZDOTDIR/zplugins/zsh-vi-mode/zsh-vi-mode.zsh
source $ZDOTDIR/zplugins/spaceship-prompt/spaceship.zsh

# Alias
alias rm="rm -i"
alias mv="mv -i"
alias la="ls -A"
## Kitty terminal alias
## alias icat="kitty +kitten icat"

# Zsh prompt theme
SPACESHIP_CHAR_SYMBOL=' '
autoload -U promptinit; promptinit
