HISTFILE=~/.config/zsh/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt autocd beep extendedglob
bindkey -v

# load zgenoma

source "${HOME}/.zgenom/zgenom.zsh"

if ! zgenom saved; then

	zgenom oh-my-zsh

	zgenom oh-my-zsh plugins/sudo
	zgenom oh-my-zsh plugins/command-not-found
	zgenom oh-my-zsh plugins/colored-man-pages

	zgenom load zsh-users/zsh-autosuggestions
	zgenom load zsh-users/zsh-syntax-highlighting
	zgenom load spaceship-prompt/spaceship-prompt spaceship

	zgenom save
fi

#SPACESHIP_PROMPT_ADD_NEWLINE = false
