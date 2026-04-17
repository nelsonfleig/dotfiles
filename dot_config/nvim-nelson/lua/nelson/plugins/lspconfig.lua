local lsp_action = require('nelson.utils.lsp').action

-- LSP Plugins
return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
          map('gr', require('telescope.builtin').lsp_references, 'Goto References')
          map('gI', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
          map('gD', vim.lsp.buf.declaration, 'Goto Declaration')
          map('gK', vim.lsp.buf.signature_help, 'Signature Help')
          map('<c-k>', vim.lsp.buf.signature_help, 'Signature Help', { 'i' })
          map('<leader>cD', require('telescope.builtin').lsp_type_definitions, 'Type Definition')
          map('<leader>ss', require('telescope.builtin').lsp_document_symbols, 'Goto Symbol')
          map('<leader>sS', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Goto Symbol (Workspace)')
          map('<leader>cR', Snacks.rename.rename_file, 'Rename File')
          map('<leader>cr', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
          map('<leader>cd', vim.diagnostic.open_float, 'Line Diagnostics')
          map('gl', vim.diagnostic.open_float, 'Line Diagnostics')
          map(']d', vim.diagnostic.goto_next, 'Go to next diagnostic')
          map('[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic')

          -- Navigate references
          if Snacks.words.is_enabled() then
            -- stylua: ignore
            map(']]', function() Snacks.words.jump(vim.v.count1, true) end, 'Next Reference')
            -- stylua: ignore
            map('[[', function() Snacks.words.jump(-vim.v.count1, true) end, 'Prev Reference')
          end

          -- Highlight references under cursor. See `:help CursorHold`
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Toggle inlay hints if the language server supports them
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>ch', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Toggle Inlay Hints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }


      -- blink.cmp extends Neovim's default LSP capabilities (e.g. snippet support)
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {}, -- for C and C++
        -- NOTE: Formatting is done with eslint_d. See `formatting.lua` file
        eslint = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectories = { mode = 'auto' },
          },
        },
        ts_ls = {},
        -- vtsls = {
        --   keys = {
        --     {
        --       '<leader>co',
        --       lsp_action['source.organizeImports'],
        --       desc = 'Organize Imports',
        --     },
        --     {
        --       '<leader>cM',
        --       lsp_action['source.addMissingImports.ts'],
        --       desc = 'Add missing imports',
        --     },
        --   },
        -- },
        -- NOTE: Make sure your PYTHONPATH is set correctly to detect
        -- installed python packages
        pyright = {},
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        tailwindcss = {
          settings = {
            tailwindCSS = {
              experimental = {
                -- Intellisense for tailwind
                classRegex = {
                  -- class variance authority
                  { 'cva\\(((?:[^()]|\\([^()]*\\))*)\\)', '["\'`]([^"\'`]*).*?["\'`]' },
                  { 'cx\\(((?:[^()]|\\([^()]*\\))*)\\)', "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  -- tailwind-variants
                  { '(["\'`][^"\'`]*.*?["\'`])', '["\'`]([^"\'`]*).*?["\'`]' },
                },
              },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup {
        ui = {
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗',
          },
        },
      }

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'emmet-language-server',
        'stylua', -- Used to format Lua code
        { 'black', version = '23.7.0' }, -- Version used in Rover codespace (will soon be replaced for ruff)
        -- 'flake8', -- Used in Rover codespace (currently being replaced for ruff)
        'ruff',
        'isort',
        'prettierd', -- faster than "prettier"
        -- TODO: Find a fix to use latest eslint_d version and provide code actions
        -- Fixed version to 13 because latest version doesn't recognize eslintrc.js
        -- See https://www.reddit.com/r/neovim/comments/1fdpap9/eslint_error_could_not_parse_linter_output_due_to/
        { 'eslint_d', version = '13.1.2' }, -- NOTE: Only used for formatting
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})

            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      -- Supress "No Information Available" notifications
      vim.lsp.handlers['textDocument/hover'] = function(_, result, ctx, config)
        config = config or {}
        config.focus_id = ctx.method
        if not (result and result.contents) then
          return
        end
        local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
        ---@diagnostic disable-next-line: deprecated
        markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
        if vim.tbl_isempty(markdown_lines) then
          return
        end
        return vim.lsp.util.open_floating_preview(markdown_lines, 'markdown', config)
      end
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
