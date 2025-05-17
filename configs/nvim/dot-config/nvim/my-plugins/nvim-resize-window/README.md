# Nvim resize windows

This small plugins allows to resize windows in a more "intuitive" way, just like wezterm or tmux.

Basically the goal is to have:
- '>' always move the right border towards the right if there is one, and if the window is at the right edge, move its left border towards the right.
- '<' always move the right border towards the left if there is one, and if the window is at the right edge, move its left border towards the left.
- '+' always move the bottom border towards the bottom if there is one, and if the window is at the bottom edge, move its top border towards the bottom.
- '-' always move the bottom border towards the top if there is one, and if the window is at the bottom edge, move its top border towards the top.

Said differently, we want to always move the right border or the bottom border of a window, unless the window is at the right or bottom edge, in which case we move the left or top border but by swapping the keys. Instead of thinking that we are expanding or reducing a window, we visualize moving a predictable border in one direction or the other.

Unfortunately, when nesting a lot of windows inside one another, nvim can decide to move the left border or the top border of the window. This inconsistency makes it impossible to implement the above behaviour correctly, but since such a complex window layout is pretty rare, we keep this plugin around because it achieves the above behaviour in most real life case.
