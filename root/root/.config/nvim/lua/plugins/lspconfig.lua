return {
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  config = function()
    local lspconfig = require('lspconfig')
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    lspconfig.html.setup {}

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    require'lspconfig'.cssls.setup {
      capabilities = capabilities
    }

    require'lspconfig'.css_variables.setup{}

    lspconfig.ts_ls.setup {}

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    lspconfig.emmet_ls.setup({
      capabilities = capabilities,
      filetypes = { 'css', 'html', 'javascript', 'javascriptreact', 'less', 'sass', 'scss', 'typescriptreact' },
      init_options = {
        html = {
          options = {
            ['bem.enabled'] = true
          }
        }
      }
    })

    lspconfig.bashls.setup {}

    lspconfig.lua_ls.setup {}
  end
}
