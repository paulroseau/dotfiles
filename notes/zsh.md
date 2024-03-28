# Autocompletion

- Useful links:
  - https://thevaluable.dev/zsh-completion-guide-examples/ (explains zstyle)

- TODO: autocompletion brief explanation

# ZLE

- Useful links:
  - https://thevaluable.dev/zsh-line-editor-configuration-mouseless/ (explains zle)

- The ZLE (Zsh Line Editor) has predefined "widgets" which are basically actions (eg. go to the end of the line, delete word, etc.)

- You can bind keys to widgets. Keys are organized in keymaps (this is very similar to tmux, emacs, ...), for example :
  ```sh
  autoload edit-command-line               # register edit-command-line function
  zle -N edit-command-line                 # make edit-command-line a new widget
  bindkey -M main '^v' edit-command-line   # bind <Ctrl-V> to the edit-command-line function
  ```
