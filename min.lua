vim.opt.rtp:append('~/workspace/dashboard-nvim')
vim.opt.rtp:append('~/workspace/dashboard-doom')
require('dashboard').setup()

vim.opt.termguicolors = true
vim.api.nvim_set_hl(0, 'DashboardHeader', {
  fg = 'yellow',
})

vim.api.nvim_set_hl(0, 'DashboardCenter', {
  fg = 'green',
})

vim.api.nvim_set_hl(0, 'DashboardFooter', {
  fg = 'gray',
})
