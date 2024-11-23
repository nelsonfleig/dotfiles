return {
  'mfussenegger/nvim-lint',
  events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
  config = function()
    local lint = require('lint')

    -- NOTE: Linting for JS/TS is provided by `eslint` lsp server
    lint.linters_by_ft = {
      python = { 'flake8' },
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
