-- AI agent plugins (beyond claudecode.nvim which is in ide.lua)

local Plug = require('utils.plug_utils').Plug

return {
  -- Avante: agentic editing (describe changes → get inline diffs)
  -- Default provider: Anthropic (Claude) via API key from 1Password
  Plug 'yetone/avante.nvim' {
    event = 'VeryLazy',
    build = 'make',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {
      provider = 'anthropic',
      anthropic = {
        model = 'claude-sonnet-4-6',
      },
      behaviour = {
        auto_suggestions = false,  -- no inline autocomplete
      },
      windows = {
        width = 40,
        sidebar_header = {
          align = 'left',
        },
      },
    },
    keys = {
      { '<leader>aa', '<cmd>AvanteAsk<cr>',    desc = 'Avante: Ask' },
      { '<leader>ae', '<cmd>AvanteEdit<cr>',    desc = 'Avante: Edit', mode = 'v' },
      { '<leader>at', '<cmd>AvanteToggle<cr>',  desc = 'Avante: Toggle sidebar' },
    },
  };
}
