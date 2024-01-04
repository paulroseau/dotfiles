# Issues you already interacted on
- https://github.com/neovim/neovim/issues/26881

# Download and extract neovim
cd $(mktemp -d)
curl -LO https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
tar -zxf nvim-linux64.tar.gz
cd nvim-linux64/bin

# Write example config file
cat >example.lua <<EOF
-- Window switching
vim.keymap.set({'', 't'} , '<M-h>', '<cmd>wincmd h<CR>')
vim.keymap.set({'', 't'} , '<M-j>', '<cmd>wincmd j<CR>')
vim.keymap.set({'', 't'} , '<M-k>', '<cmd>wincmd k<CR>')
vim.keymap.set({'', 't'} , '<M-l>', '<cmd>wincmd l<CR>')

-- Window moving
vim.keymap.set({'', 't'} , '<M-H>', '<cmd>wincmd H<CR>')
vim.keymap.set({'', 't'} , '<M-J>', '<cmd>wincmd J<CR>')
vim.keymap.set({'', 't'} , '<M-K>', '<cmd>wincmd K<CR>')
vim.keymap.set({'', 't'} , '<M-L>', '<cmd>wincmd L<CR>')
EOF

# Start
./nvim -u example.lua
