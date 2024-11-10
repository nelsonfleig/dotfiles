return {
  'akinsho/bufferline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  version = '*',
  keys = {
    { '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', desc = 'Toggle Pin' },
    { '<leader>bP', '<Cmd>BufferLineGroupClose ungrouped<CR>', desc = 'Delete Non-Pinned Buffers' },
    { '<leader>br', '<Cmd>BufferLineCloseRight<CR>', desc = 'Delete Buffers to the Right' },
    { '<leader>bl', '<Cmd>BufferLineCloseLeft<CR>', desc = 'Delete Buffers to the Left' },
    { '<S-h>', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { '<S-l>', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '[b', '<cmd>BufferLineCyclePrev<cr>', desc = 'Prev Buffer' },
    { ']b', '<cmd>BufferLineCycleNext<cr>', desc = 'Next Buffer' },
    { '[B', '<cmd>BufferLineMovePrev<cr>', desc = 'Move buffer prev' },
    { ']B', '<cmd>BufferLineMoveNext<cr>', desc = 'Move buffer next' },
  },
  opts = {
    options = {
      always_show_bufferline = false,
      offsets = {
        {
          filetype = 'neo-tree',
          text = 'Neo-tree',
          highlight = 'Directory',
          text_align = 'left',
        },
      },
    },
  },
  config = function(_, opts)
    require('bufferline').setup(opts)
    -- Fix bufferline when restoring a session
    vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete' }, {
      callback = function()
        vim.schedule(function()
          pcall(nvim_bufferline)
        end)
      end,
    })

    -- Function to close empty and unnamed buffers
    local close_empty_unnamed_buffers = function()
      -- Get a list of all buffers
      local buffers = vim.api.nvim_list_bufs()

      -- Iterate over each buffer
      for _, bufnr in ipairs(buffers) do
        -- Check if the buffer is empty and doesn't have a name
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) == '' and vim.api.nvim_buf_get_option(bufnr, 'buftype') == '' then
          -- Get all lines in the buffer
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

          -- Initialize a variable to store the total number of characters
          local total_characters = 0

          -- Iterate over each line and calculate the number of characters
          for _, line in ipairs(lines) do
            total_characters = total_characters + #line
          end

          -- Close the buffer if it's empty:
          if total_characters == 0 then
            vim.api.nvim_buf_delete(bufnr, {
              force = true,
            })
          end
        end
      end
    end

    -- Clear the mandatory, empty, unnamed buffer when a real file is opened:

    vim.api.nvim_create_autocmd('BufReadPost', {
      callback = function()
        close_empty_unnamed_buffers()
      end,
    })
    -- vim.api.nvim_command 'autocmd BufReadPost * lua require("config.bufferline_setup").close_empty_unnamed_buffers()'
  end,
}
