return {
  'echasnovski/mini.comment',
  version = '*',
  event = 'VeryLazy',
  config = function ()
  require('mini.comment').setup({
    mappings = {
      comment = '<C-/>',
      comment_line = '<C-/>',
      comment_visual = '<C-/>',
      textobject = '<C-/>'
    }
  })
  end
}
