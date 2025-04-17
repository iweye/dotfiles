return {
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  config = function()
    vim.keymap.set('n', '<leader>lD', vim.diagnostic.open_float)
    vim.keymap.set('n', '[', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<leader>ld', vim.diagnostic.setloclist)

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        local opts = { buffer = ev.buf }
        vim.keymap.set('n', '<leader>ld', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>la', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<leader>lR', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>lf',
          function() vim.lsp.buf.format { async = true } end, opts)
      end
    })

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
