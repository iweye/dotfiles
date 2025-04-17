return {
  'nvim-treesitter/nvim-treesitter',
  event = 'VeryLazy',
  run = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'bash',
        'regex',
        'json',
        'toml',
        'lua',
        'html',
        'css',
        'scss',
        'sql',
        'python',
        'javascript',
        'typescript',
        'gitcommit',
        'gitignore',
        'markdown',
        'markdown_inline',
        'regex'
      },
      auto_install = true,
      highlight = {
        enable = true,
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = true,
      },
      indent = {
        enable = true,
      },
    }
  end
}
