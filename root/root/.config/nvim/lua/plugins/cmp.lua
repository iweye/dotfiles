return {
  'hrsh7th/nvim-cmp',
  event = 'VeryLazy',
  dependencies = {
    { 'onsails/lspkind.nvim', event = 'VeryLazy' },
    { 'hrsh7th/cmp-nvim-lsp', event = 'VeryLazy' },
    { 'hrsh7th/cmp-buffer', event = 'VeryLazy' },
    { 'hrsh7th/cmp-path', event = 'VeryLazy' },
    { 'hrsh7th/cmp-cmdline', event = 'VeryLazy' },
    { 'dmitmel/cmp-cmdline-history', event = 'VeryLazy' },
    { 'hrsh7th/cmp-calc', event = 'VeryLazy' },
    { 'hrsh7th/cmp-emoji', event = 'VeryLazy' },
    { 'f3fora/cmp-spell', event = 'VeryLazy' },
    { 'hrsh7th/cmp-nvim-lsp-signature-help', event = 'VeryLazy' },
    {
      'L3MON4D3/LuaSnip',
      event = 'VeryLazy',
      version = 'v2.*',
      build = 'make install_jsregexp',
      dependencies = {
        { 'rafamadriz/friendly-snippets', event = 'VeryLazy' },
        { 'saadparwaiz1/cmp_luasnip', event = 'VeryLazy' }
      },
      config = function()
        local opts = { noremap = true, silent = true }
        local ls = require('luasnip')
        vim.keymap.set({'i'}, '<C-K>', function() ls.expand() end, opts)
        vim.keymap.set({'i', 's'}, '<C-K>', function() ls.jump( 1) end, opts)
        vim.keymap.set({'i', 's'}, '<C-J>', function() ls.jump(-1) end, opts)
        vim.keymap.set({'i', 's'}, '<C-E>', function()
          if ls.choice_active() then
            ls.change_choice(1)
          end
        end, opts)
        require('luasnip.loaders.from_vscode').lazy_load()
      end
    }
  },
  config = function()
    local cmp = require('cmp')
    local lspkind = require('lspkind')

    cmp.setup({
      mapping = {
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { 'i', 's' })
      },
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      sources = cmp.config.sources(
        {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'calc' },
          { name = 'path' },
          { name = 'emoji' },
          { name = 'nvim_lsp_signature_help' },
          {
            name = "spell",
            option = {
              keep_all_entries = false,
              enable_in_context = function()
                return true
              end,
              preselect_correct_word = true,
            },
          },
        },
        {
          { name = 'buffer' },
        }
      ),
      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          maxwidth = 50,
          ellipsis_char = '...',
          show_labelDetails = true,
          menu = {
            luasnip = "[Snip]",
            nvim_lsp = "[LSP]",
            nvim_lsp_signature_help = "[Sign]",
            emoji = "[Emoji]",
            buffer = "[Buf]",
            copilot = "[GHub]",
            crates = "[Crate]",
            path = "[Path]",
            cmdline = "[Cmd]",
            cmdline_history = "[Hist]",
            git = "[Git]",
            conventionalcommits = "[Conv]",
            calc = "[Calc]"
          },

          before = function (entry, vim_item)
            return vim_item
          end
        })
      }
    })

    -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
    -- Set configuration for specific filetype.
    --[[ cmp.setup.filetype('gitcommit', {
          sources = cmp.config.sources({
            { name = 'git' },
          }, {
            { name = 'buffer' },
          })
        })
        require('cmp_git').setup() ]]--

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
          { name = 'cmdline' },
          { name = 'cmdline_history' },
          { name = 'path' },

        }),
      matching = { disallow_symbol_nonprefix_matching = false }
    })
  end
}
