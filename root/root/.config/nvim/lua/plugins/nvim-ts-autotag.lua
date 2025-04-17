return {
  'windwp/nvim-ts-autotag',
  event = 'VeryLazy',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('nvim-ts-autotag').setup()
  end
}
