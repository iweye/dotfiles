return {
  'phaazon/hop.nvim',
  event = 'VeryLazy',
  branch = 'v2', -- optional but strongly recommended
  config = function()
    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<leader>h', ':HopWord<CR>', opts)
    require'hop'.setup {
      keys = 'etovxqpdygfblzhckisuran',
    }
  end
}
