-- NOTE: Plugins can specify dependencies.
--
-- The dependencies are proper plugin specifications as well - anything
-- you do for a plugin at the top level, you can do for a dependency.
--
-- Use the `dependencies` key to specify the dependencies of a particular plugin

return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- customized (more efficient) find function
      local function find_command()
        if 1 == vim.fn.executable 'rg' then
          return { 'rg', '--files', '--color', 'never', '-g', '!.git' }
        elseif 1 == vim.fn.executable 'fd' then
          return { 'fd', '--type', 'f', '--color', 'never', '-E', '.git' }
        elseif 1 == vim.fn.executable 'fdfind' then
          return { 'fdfind', '--type', 'f', '--color', 'never', '-E', '.git' }
        elseif 1 == vim.fn.executable 'find' and vim.fn.has 'win32' == 0 then
          return { 'find', '.', '-type', 'f' }
        elseif 1 == vim.fn.executable 'where' then
          return { 'where', '/r', '.', '*' }
        end
      end

      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      telescope.setup {
        pickers = {
          find_files = {
            find_command = find_command,
            hidden = true,
          },
        },
        path_display = { 'smart' },
        mappings = {
          i = {
            ['<C-k>'] = actions.move_selection_previous, -- move to prev result
            ['<C-j>'] = actions.move_selection_next, -- move to next result
            ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      local utils = require 'telescope.utils'

      -- For convenience
      local keymap = vim.keymap

      -- LazyVim mappings
      keymap.set('n', '<leader>,', '<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>', { desc = 'Switch Buffer' })
      keymap.set('n', '<leader>/', builtin.live_grep, { desc = 'Grep (Root Dir)' })
      keymap.set('n', '<leader>:', '<cmd>Telescope command_history<cr>', { desc = 'Command History' })
      keymap.set('n', '<leader><leader>', builtin.find_files, { desc = 'Find Files (Root Dir)' })

      -- find
      keymap.set('n', '<leader>fc', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = 'Find Config File' })
      keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files (Root Dir)' })
      keymap.set('n', '<leader>fF', function()
        builtin.find_files { cwd = utils.buffer_dir() }
      end, { desc = 'Find Files (cwd)' })
      keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Find Files (git-files)' })
      keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent' })
      keymap.set('n', '<leader>fR', function()
        builtin.oldfiles { cwd = utils.buffer_dir() }
      end, { desc = 'Recent (cwd)' })
      keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })

      -- git
      keymap.set('n', '<leader>gc', '<cmd>Telescope git_commits<CR>', { desc = 'Commits' })
      keymap.set('n', '<leader>gs', '<cmd>Telescope git_status<CR>', { desc = 'Status' })

      -- search
      keymap.set('n', '<leader>st', '<cmd>TodoTelescope<CR>', { desc = 'Todo' })
      keymap.set('n', '<leader>s"', builtin.registers, { desc = 'Registers' })
      keymap.set('n', '<leader>sd', function()
        builtin.diagnostics {
          bufnr = 0,
        }
      end, { desc = 'Diagnostics (Document)' })
      keymap.set('n', '<leader>sD', builtin.diagnostics, { desc = 'Diagnostics (Workspace)' })
      keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Resume' })
      keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Grep (Root Dir)' })
      keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Help Pages' })
      keymap.set('n', '<leader>so', builtin.vim_options, { desc = 'Options' })
      keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'Keymaps' })
      keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Word (Root Dir)' })
      keymap.set('n', '<leader>sW', function()
        builtin.grep_string { cwd = utils.buffer_dir() }
      end, { desc = 'Word (cwd)' })
      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = 'Grep (Open Files)' })

      -- Slightly advanced example of overriding default behavior and theme
      -- keymap.set('n', '<leader>/', function()
      --   -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      --   builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      --     winblend = 10,
      --     previewer = false,
      --   })
      -- end, { desc = '[/] Fuzzily search in current buffer' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
