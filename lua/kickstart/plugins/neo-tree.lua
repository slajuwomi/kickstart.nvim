-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
--
-- Shortcuts:
--   <leader>e  toggle file tree
--   <leader>o  reveal current file in tree
--   \          reveal current file in tree (kickstart default)
--   q or \     close tree when focused inside it

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '<leader>e', ':Neotree filesystem toggle left<CR>', desc = 'Toggle file [E]xplorer', silent = true },
    { '<leader>o', ':Neotree filesystem reveal left<CR>', desc = 'Reveal file in expl[O]rer', silent = true },
    { '\\', ':Neotree filesystem reveal left<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      hijack_netrw_behavior = 'open_default',
      window = {
        width = 32,
        mappings = {
          ['\\'] = 'close_window',
          ['q'] = 'close_window',
          ['<leader>e'] = 'close_window',
        },
      },
    },
  },
}
