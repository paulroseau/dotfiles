# Nvim resize windows

This small plugins aims at improving window resizing. It mimicks the behaviour of tmux or wezterm panes. 

## The goal

The goal is to have:
- '>' move the right border towards the right
- '<' move the right border towards the left
- '+' move the bottom border towards the bottom
- '-' move the bottom border towards the top

Unless the window is at the right edge, then we want to have:
- '>' move the left border is towards to the right
- '<' move the left border is moved towards the left

Unless the window is at the bottom edge, then we want to have:
- '+' move the top border towards the bottom
- '-' move the top border towards the top

Instead of thinking that we are expanding or reducing a window like nvim does natively, we visualize moving an identifiable border in one direction or the other.

## Limitations

Unfortunately, neovim always picks the smaller border to expand or shrink a window. This border can be the left or the top border depending on the order in which you split you windows. When this happens, one trick consists in going to the adjacent window on the right or the bottom and trying to perform the opposite action (shrink if we want to expand the original window and expand if we want to shrink the original window). If the common border between the adjacent window and the original window is the smaller border of the adjacent window, then it will be moved and create the desire effect. In the opposite case, we are out of luck since nvim does not provide any easy way to move that common border.

This behaviour is the same on tmux and wezterm. This could be intentional since this behaviour allows to modify only two windows. The behaviour described above may cause many windows (all of those which share the moved border with the current window) to be expanded/shrunk as a side effect.
