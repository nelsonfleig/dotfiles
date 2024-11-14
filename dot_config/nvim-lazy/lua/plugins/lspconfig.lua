return {
  {
    "williamboman/mason.nvim",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "bash-language-server",
        "pyright",
        "typescript-language-server",
        "prettier",
      },
    },
  },
  -- If your project is using eslint with eslint-plugin-prettier, then this will automatically fix eslint errors and format with prettier on save.
  -- NOTE: make sure not to add prettier to null-ls, otherwise this won't work!
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = { eslint = {} },
      setup = {
        eslint = function()
          require("lazyvim.util").lsp.on_attach(function(client)
            if client.name == "eslint" then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == "tsserver" then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
        end,
      },
    },
  },
}
