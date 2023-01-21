local api = vim.api

api.nvim_create_autocmd('Vimenter', {
  group = api.nvim_create_augroup('Dashboard', { clear = true }),
  callback = function()
    if vim.fn.argc() == 0 and vim.fn.line2byte('$') == -1 then
      require('dashboard'):instance()
    end
  end,
})
