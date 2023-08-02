if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Environment variables
export EDITOR="nvim"
export VISUAL="nvim"
# Necessary for packages complaining about Locale in nix cf. https://github.com/NixOS/nix/issues/4829 
# For instance it causes issues with nix installed starship which leaves characters when using Tab completion in zsh
# cf. https://stackoverflow.com/questions/19305291/remnant-characters-when-tab-completing-with-zsh
export LC_ALL="C.UTF-8"

# Prompt
eval "$(starship init zsh)"

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
setopt HIST_SAVE_NO_DUPS # not so useful since SHARE_HISTORY adds timestamps to each line
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Aliases
alias diff='diff --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'

# Default keymap

# Zsh sets keymap to viins if the EDITOR environment variable is set to nvim.
# Because the emulation is not exact, it is better to use default emacs bindings
# and resort to full on nvim if advanced editing is needed (cf. edit-command-line)
bindkey -A emacs main 

# Edit current command in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M main '^v' edit-command-line

# Completion

# Init completion
autoload -Uz compinit
compinit

# Configure completion
zstyle ':completion:*' menu select

# Naviagte the completion menu with vi style bindings
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'j' vi-down-line-or-history

# Add zsh completion for nix installed tools
if [ -e $HOME/.nix-profile/share/zsh/site-functions ]
then 
  fpath+=($HOME/.nix-profile/share/zsh/site-functions $fpath)
fi

# FZF
if [ -f $HOME/.nix-profile/share/fzf/completion.zsh ]; then source $HOME/.nix-profile/share/fzf/completion.zsh; fi
if [ -f $HOME/.nix-profile/share/fzf/key-bindings.zsh ]; then source $HOME/.nix-profile/share/fzf/key-bindings.zsh; fi

# Zsh-z
if [ -f $HOME/.nix-profile/share/zsh-z/zsh-z.plugin.zsh ]; then source $HOME/.nix-profile/share/zsh-z/zsh-z.plugin.zsh; fi

# Zsh-autosuggestions
if [ -f $HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then source $HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh; fi

# Syntax highlighting
if [ -f $HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]
then
  source $HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -e /home/proseau/.nix-profile/etc/profile.d/nix.sh ]; then . /home/proseau/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
