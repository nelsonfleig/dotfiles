return {
  'mfussenegger/nvim-lint',
  events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
  config = function()
    local lint = require 'lint'

    -- NOTE: Linting for JS/TS is provided by `eslint` lsp server
    -- NOTE: Linting for python is provided by `ruff` lsp server on save
    lint.linters_by_ft = {
      -- javascript = { 'eslint_d' },
      -- typescript = { 'eslint_d' },
      -- javascriptreact = { 'eslint_d' },
      -- typescriptreact = { 'eslint_d' },
      -- python = { 'ruff' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set('n', '<leader>cl', function()
      lint.try_lint()
    end, { desc = 'Lint' })
  end,
}
