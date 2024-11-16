return {
  'stevearc/conform.nvim',

  event = { 'BufReadPre', 'BufNewFile' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format { async = false, lsp_format = 'fallback' }
      end,
      mode = { 'n', 'v' },
      desc = 'Format',
    },
  },
  opts = {
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 3000,
        lsp_format = lsp_format_opt,
      }
    end,
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
