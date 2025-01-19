return {
  'nvim-neo-tree/neo-tree.nvim',
  event = 'VeryLazy',
  branch = 'v3.x',
  dependencies = {
    { 'nvim-lua/plenary.nvim', event = 'VeryLazy' },
    { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' },
    { 'MunifTanjim/nui.nvim', event = 'VeryLazy' },
  },
  config = function()
    -- If you want icons for diagnostic errors, you'll need to define them somewhere:
    vim.fn.sign_define('DiagnosticSignError',
      { text = ' ', texthl = 'DiagnosticSignError' })
    vim.fn.sign_define('DiagnosticSignWarn',
      { text = ' ', texthl = 'DiagnosticSignWarn' })
    vim.fn.sign_define('DiagnosticSignInfo',
      { text = ' ', texthl = 'DiagnosticSignInfo' })
    vim.fn.sign_define('DiagnosticSignHint',
      { text = '󰌵', texthl = 'DiagnosticSignHint' })

    require("neo-tree").setup({
      filesystem = {
        hijack_netrw_behavior = "open_current",
      }
    })
  end
}
