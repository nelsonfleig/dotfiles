-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Close Neotree on quit to prevent issue with persistence plugin
vim.api.nvim_create_autocmd('VimLeavePre', {
  command = ':Neotree close',
})

-- Load Snacks statuscolumn after nvim-treesitter loads. Crashes when set in options.lua
-- HACK: This requires a restart but at least prevents Neovim from crashing due to missing nvim-treesitter
vim.api.nvim_create_autocmd('User', {
  pattern = 'nvim-treesitter',
  callback = function()
    vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
  end,
})
