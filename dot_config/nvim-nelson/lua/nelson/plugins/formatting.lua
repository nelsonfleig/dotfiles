return { -- Autoformat
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
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable with a global
      if not vim.g.autoformat then
        return
      end

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
      javascript = { 'eslint_d', 'prettierd' },
      typescript = { 'eslint_d', 'prettierd' },
      javascriptreact = { 'eslint_d', 'prettierd' },
      typescriptreact = { 'eslint_d', 'prettierd' },
      css = { 'eslint_d', 'prettierd' },
      html = { 'eslint_d', 'prettierd' },
      json = { 'eslint_d', 'prettierd' },
      yaml = { 'eslint_d', 'prettierd' },
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      python = { 'isort', 'black' },
      -- python = { 'isort', 'ruff' }, -- will be needed once formatting with ruff is enabled in codespaces
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
  config = function(_, opts)
    require('conform').setup(opts)

    local toggle_autoformat = function()
      return Snacks.toggle {
        name = 'Auto Format',
        get = function()
          return vim.g.autoformat
        end,
        set = function(state)
          vim.g.autoformat = state
        end,
      }
    end

    toggle_autoformat():map '<leader>uf'
  end,
}
