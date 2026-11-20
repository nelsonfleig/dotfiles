-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- quit
vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })

-- Just don't use Q
vim.keymap.set('n', 'Q', '<nop>')

-- Ctrl-hjkl moves between nvim splits; at the edge it hands off to the
-- surrounding multiplexer (tmux via vim-tmux-navigator, or the Herdr app).
vim.g.tmux_navigator_no_mappings = 1

local function navigate(wincmd, direction, tmux_cmd)
  return function()
    if vim.env.TMUX then
      return vim.cmd(tmux_cmd)
    end
    local before = vim.fn.winnr()
    vim.cmd('wincmd ' .. wincmd)
    if vim.fn.winnr() == before and vim.env.HC_TERMINAL_ID and vim.fn.executable('herdr-app') == 1 then
      vim.system({ 'herdr-app', 'do', 'pane.go', '--direction', direction })
    end
  end
end

vim.keymap.set('n', '<C-h>', navigate('h', 'left', 'TmuxNavigateLeft'), { desc = 'Move focus left (window or pane)' })
vim.keymap.set('n', '<C-j>', navigate('j', 'down', 'TmuxNavigateDown'), { desc = 'Move focus down (window or pane)' })
vim.keymap.set('n', '<C-k>', navigate('k', 'up', 'TmuxNavigateUp'), { desc = 'Move focus up (window or pane)' })
vim.keymap.set('n', '<C-l>', navigate('l', 'right', 'TmuxNavigateRight'), { desc = 'Move focus right (window or pane)' })
vim.keymap.set('n', '<C-\\>', function()
  if vim.env.TMUX then
    vim.cmd('TmuxNavigatePrevious')
  else
    vim.cmd('wincmd p')
  end
end, { desc = 'Move focus to the previous window or pane' })

-- Buffer Navigation
vim.keymap.set('n', '[b', ':bprevious<CR>', { desc = 'Previous Buffer' })
vim.keymap.set('n', ']b', ':bnext<CR>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { desc = 'Previous Buffer' })
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>bb', ':b#<CR>', { desc = 'Switch to Other Buffer' })

-- Move highlighted text
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Append line below to current line
-- vim.keymap.set('n', 'J', 'mzJ`z')

-- Scroll and maintain cursor in center
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Paste and substitute text without losing the current paste buffer
vim.keymap.set('x', '<leader>p', [["_dP]])

-- Yank into system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'which_key_ignore' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'which_key_ignore' })

-- In visual mode, replace the selected text with the unnamed register,
-- without yanking the deleted text.
vim.keymap.set('x', 'p', [["_dP]])

-- vim: ts=2 sts=2 sw=2 et
