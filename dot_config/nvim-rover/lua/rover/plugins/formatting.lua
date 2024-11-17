return {
  'stevearc/conform.nvim',

  event = { 'BufReadPre', 'BufNewFile' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format({ async = false, lsp_format = 'fallback' })
      end,
      mode = { 'n', 'v' },
      desc = 'Format',
    },
  },
  opts = {
    format_on_save = {
      timeout_ms = 3000,
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'isort', 'black' },
      -- We use eslint_d to process fixable problems on save
      javascript = { 'eslint_d', 'prettierd' },
      typescript = { 'eslint_d', 'prettierd' },
      javascriptreact = { 'eslint_d', 'prettierd' },
      typescriptreact = { 'eslint_d', 'prettierd' },
      css = { 'eslint_d', 'prettierd' },
      html = { 'eslint_d', 'prettierd' },
      json = { 'eslint_d', 'prettierd' },
      yaml = { 'eslint_d', 'prettierd' },
    },
  },
}
