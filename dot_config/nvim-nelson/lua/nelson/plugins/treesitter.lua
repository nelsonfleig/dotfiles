return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require('nvim-treesitter')

      local parsers = {
        'bash', 'c', 'css', 'diff', 'dockerfile', 'html',
        'javascript', 'json', 'lua', 'luadoc', 'markdown',
        'markdown_inline', 'python', 'query', 'toml', 'tsx',
        'typescript', 'vim', 'vimdoc', 'yaml',
      }

      -- Only install parsers if tree-sitter CLI is available
      if vim.fn.executable('tree-sitter') == 1 then
        local installed = {}
        for _, lang in ipairs(ts.get_installed()) do
          installed[lang] = true
        end
        local to_install = vim.tbl_filter(function(lang)
          return not installed[lang]
        end, parsers)
        if #to_install > 0 then
          ts.install(to_install, { summary = true })
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('nelson_treesitter', { clear = true }),
        callback = function(ev)
          local buf = ev.buf
          if vim.bo[buf].buftype ~= '' then
            return
          end
          if not pcall(vim.treesitter.get_parser, buf) then
            return
          end
          pcall(vim.treesitter.start, buf)
          vim.wo[0][0].foldmethod = 'expr'
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          local lang = vim.treesitter.language.get_lang(ev.match)
          if lang ~= 'ruby' then
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Incremental selection
      local _selection_nodes = {}

      vim.keymap.set({ 'n', 'x' }, '<C-space>', function()
        local buf = vim.api.nvim_get_current_buf()
        if not pcall(vim.treesitter.get_parser, buf) then
          return
        end
        local node
        if vim.fn.mode() == 'n' then
          node = vim.treesitter.get_node()
          if not node then return end
          _selection_nodes[buf] = { node }
        else
          local nodes = _selection_nodes[buf]
          if not nodes or #nodes == 0 then return end
          node = nodes[#nodes]:parent()
          if not node then return end
          table.insert(nodes, node)
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx')
        end
        local r1, c1, r2, c2 = node:range()
        local end_row, end_col = r2 + 1, math.max(c2 - 1, 0)
        if c2 == 0 and r2 > r1 then
          end_row = r2
          end_col = math.max(#(vim.api.nvim_buf_get_lines(buf, r2 - 1, r2, false)[1] or '') - 1, 0)
        end
        vim.api.nvim_win_set_cursor(0, { r1 + 1, c1 })
        vim.cmd('normal! v')
        vim.api.nvim_win_set_cursor(0, { end_row, end_col })
      end, { desc = 'Treesitter incremental selection' })

      vim.keymap.set('x', '<bs>', function()
        local buf = vim.api.nvim_get_current_buf()
        local nodes = _selection_nodes[buf]
        if not nodes or #nodes <= 1 then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx')
          _selection_nodes[buf] = nil
          return
        end
        table.remove(nodes)
        local node = nodes[#nodes]
        local r1, c1, r2, c2 = node:range()
        local end_row, end_col = r2 + 1, math.max(c2 - 1, 0)
        if c2 == 0 and r2 > r1 then
          end_row = r2
          end_col = math.max(#(vim.api.nvim_buf_get_lines(buf, r2 - 1, r2, false)[1] or '') - 1, 0)
        end
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx')
        vim.api.nvim_win_set_cursor(0, { r1 + 1, c1 })
        vim.cmd('normal! v')
        vim.api.nvim_win_set_cursor(0, { end_row, end_col })
      end, { desc = 'Treesitter decrement selection' })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local function attach(buf)
        if vim.bo[buf].buftype ~= '' or vim.bo[buf].filetype == '' then
          return
        end
        if not pcall(vim.treesitter.get_parser, buf) then
          return
        end

        local ts_select = require('nvim-treesitter-textobjects.select')
        local ts_move = require('nvim-treesitter-textobjects.move')
        local ts_swap = require('nvim-treesitter-textobjects.swap')

        -- Text object selection
        local select_maps = {
          { 'aa', '@parameter.outer', 'Select outer parameter/argument' },
          { 'ia', '@parameter.inner', 'Select inner parameter/argument' },
          { 'al', '@loop.outer', 'Select outer loop' },
          { 'il', '@loop.inner', 'Select inner loop' },
          { 'af', '@call.outer', 'Select outer function call' },
          { 'if', '@call.inner', 'Select inner function call' },
          { 'am', '@function.outer', 'Select outer method/function definition' },
          { 'im', '@function.inner', 'Select inner method/function definition' },
          { 'ac', '@class.outer', 'Select outer class' },
          { 'ic', '@class.inner', 'Select inner class' },
        }
        for _, m in ipairs(select_maps) do
          vim.keymap.set({ 'x', 'o' }, m[1], function()
            ts_select.select_textobject(m[2], 'textobjects')
          end, { buffer = buf, desc = m[3], silent = true })
        end

        -- Move keymaps
        local move_maps = {
          { 'goto_next_start', ']f', '@call.outer', 'Next function call start' },
          { 'goto_next_start', ']m', '@function.outer', 'Next method/function def start' },
          { 'goto_next_start', ']c', '@class.outer', 'Next class start' },
          { 'goto_next_start', ']i', '@conditional.outer', 'Next conditional start' },
          { 'goto_next_start', ']l', '@loop.outer', 'Next loop start' },
          { 'goto_next_start', ']s', '@scope', 'Next scope', 'locals' },
          { 'goto_next_start', ']z', '@fold', 'Next fold', 'folds' },
          { 'goto_next_end', ']F', '@call.outer', 'Next function call end' },
          { 'goto_next_end', ']M', '@function.outer', 'Next method/function def end' },
          { 'goto_next_end', ']C', '@class.outer', 'Next class end' },
          { 'goto_next_end', ']I', '@conditional.outer', 'Next conditional end' },
          { 'goto_next_end', ']L', '@loop.outer', 'Next loop end' },
          { 'goto_previous_start', '[f', '@call.outer', 'Prev function call start' },
          { 'goto_previous_start', '[m', '@function.outer', 'Prev method/function def start' },
          { 'goto_previous_start', '[c', '@class.outer', 'Prev class start' },
          { 'goto_previous_start', '[i', '@conditional.outer', 'Prev conditional start' },
          { 'goto_previous_start', '[l', '@loop.outer', 'Prev loop start' },
          { 'goto_previous_end', '[F', '@call.outer', 'Prev function call end' },
          { 'goto_previous_end', '[M', '@function.outer', 'Prev method/function def end' },
          { 'goto_previous_end', '[C', '@class.outer', 'Prev class end' },
          { 'goto_previous_end', '[I', '@conditional.outer', 'Prev conditional end' },
          { 'goto_previous_end', '[L', '@loop.outer', 'Prev loop end' },
        }
        for _, m in ipairs(move_maps) do
          local query_group = m[5] or 'textobjects'
          vim.keymap.set({ 'n', 'x', 'o' }, m[2], function()
            if vim.wo.diff and m[2]:find('[cC]') then
              return vim.cmd('normal! ' .. m[2])
            end
            ts_move[m[1]](m[3], query_group)
          end, { buffer = buf, desc = m[4], silent = true })
        end

        -- Swap keymaps
        local swap_maps = {
          { 'swap_next', '<leader>na', '@parameter.inner', 'Swap parameter with next' },
          { 'swap_next', '<leader>n:', '@property.outer', 'Swap property with next' },
          { 'swap_next', '<leader>nm', '@function.outer', 'Swap function with next' },
          { 'swap_previous', '<leader>pa', '@parameter.inner', 'Swap parameter with prev' },
          { 'swap_previous', '<leader>p:', '@property.outer', 'Swap property with prev' },
          { 'swap_previous', '<leader>pm', '@function.outer', 'Swap function with prev' },
        }
        for _, s in ipairs(swap_maps) do
          vim.keymap.set('n', s[2], function()
            ts_swap[s[1]](s[3], 'textobjects')
          end, { buffer = buf, desc = s[4], silent = true })
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('nelson_ts_textobjects', { clear = true }),
        callback = function(ev)
          attach(ev.buf)
        end,
      })
      -- Attach to already-loaded buffers (plugin loaded via VeryLazy)
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          attach(buf)
        end
      end
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local toggle_context = function()
        return Snacks.toggle {
          name = 'Code Context',
          get = function()
            return vim.g.show_ts_context
          end,
          set = function(state)
            if state == true then
              vim.cmd 'TSContext enable'
            else
              vim.cmd 'TSContext disable'
            end
            vim.g.show_ts_context = state
          end,
        }
      end
      toggle_context():map '<leader>uc'
    end,
  },
}
