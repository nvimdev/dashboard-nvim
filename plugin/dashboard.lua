--version 0.3.0
if vim.g.loaded_dashboard then
  return
end

vim.g.loaded_dashboard = 1

vim.api.nvim_create_user_command('Dashboard', function() end, {})
