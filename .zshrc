HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt autocd beep extendedglob
bindkey -v

source "${HOME}/.zgenom/zgenom.zsh"

if ! zgenom saved; then

	zgenom oh-my-zsh

	zgenom oh-my-zsh plugins/sudo
	zgenom oh-my-zsh plugins/command-not-found
	zgenom oh-my-zsh plugins/colored-man-pages

	zgenom prezto


	zgenom load jeffreytse/zsh-vi-mode
	zgenom load zsh-users/zsh-autosuggestions
	zgenom load zsh-users/zsh-syntax-highlighting

	zgenom save
fi

prompt pure

# Kitty terminal alias
alias icat="kitty +kitten icat"

# Spaceship prompt
# SPACESHIP_CHAR_SYMBOL=' '
# SPACESHIP_VI_MODE_SHOW=true;

# autoload -U promptinit; promptinit

