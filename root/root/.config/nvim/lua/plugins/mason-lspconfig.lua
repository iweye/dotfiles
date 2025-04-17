return {
  'williamboman/mason-lspconfig.nvim',
  event = 'VeryLazy',
  config = function()
    require('mason-lspconfig').setup({
      ensure_installed = {
        'html',
        'cssls',
        'css_variables',
        'ts_ls',
        'emmet_ls',
        'bashls',
        'lua_ls'
      },
      automatic_installation = true
    })
  end
}
