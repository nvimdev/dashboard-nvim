local api, uv = vim.api, vim.loop
local utils = require('dashboard.utils')

local function gen_shortcut(shortcut, elements)
  shortcut = shortcut or {}
  if vim.tbl_isempty(shortcut) then
    shortcut = {
      { desc = '[  Github]', group = 'Title' },
      { desc = '[  glepnir]', group = 'Title' },
      { desc = '[  0.2.3]', group = 'Title' },
    }
  end

  local lines = ''
  for _, item in pairs(shortcut) do
    lines = lines .. '  ' .. item.desc
  end

  local first_line = #elements.lines
  vim.list_extend(elements.lines, utils.center_align({ lines }))

  local shortcut_highlight = function(bufnr, _)
    local line = api.nvim_buf_get_lines(bufnr, first_line, first_line + 1, false)[1]
    local start = line:find('[^%s]') - 1
    for _, item in pairs(shortcut) do
      local _end = start + api.nvim_strwidth(item.desc) + 2
      api.nvim_buf_add_highlight(bufnr, 0, item.group, first_line, start, _end)
      start = _end + 2
    end
  end

  table.insert(elements.fns, shortcut_highlight)

  if shortcut[1].keymap then
    local apply_map = function(bufnr, _)
      for _, item in pairs(shortcut) do
        vim.keymap.set('n', item.keymap, function()
          vim.cmd(item.action)
        end, { buffer = bufnr, nowait = true, silent = true })
      end
    end
    table.insert(elements.fns, apply_map)
  end
end

local function load_packages(packages, elements)
  packages = packages or {}
  if vim.tbl_isempty(packages) then
    packages = {
      '',
      'neovim loaded ' .. utils.get_packages_count() .. ' packages',
      '',
      '',
    }
  end
  local first_line = #elements.lines
  vim.list_extend(elements.lines, utils.center_align(packages))
  local packages_higlight = function(bufnr, _)
    api.nvim_buf_add_highlight(bufnr, 0, 'Comment', first_line + 1, 0, -1)
  end
  table.insert(elements.fns, packages_higlight)
end

local function project_list(project, elements)
  project = project or {}
  if vim.tbl_isempty(project) then
    project = {
      path = utils.path_join(vim.fn.stdpath('cache'), 'dashboard_project.txt'),
      jump_to_project = 'p',
    }
  end
  if vim.fn.filereadable(project.path) == 0 then
    local ok, fd = pcall(uv.fs_open, project.path, 'w', 420)
    if not ok then
      vim.notify('[dashboard.nvim] create project tmp file failed', vim.log.levels.ERROR)
      return
    end
    uv.fs_close(fd)
  end
  local fd = io.open(project.path, 'r')
  local res = {
    '異 Recently Projects: [' .. project.jump_to_project .. ']',
  }
  for line in fd:lines() do
    table.insert(res, line)
  end
  fd:close()

  res = utils.element_align(res)
  res[1] = res[1] .. (' '):rep(6)

  vim.list_extend(elements.lines, utils.center_align(res))
end

local function mru_list(mru, elements)
  mru = mru or {}
  local list = {
    '  Recently Files: [' .. (mru.jump_to_mru or 'm') .. ']',
  }
  local groups = {}
  local first_line = #elements.lines
  for _, file in pairs(vim.list_slice(utils.get_mru_list(), 1, mru.limit or 8)) do
    local ft = vim.filetype.match({ filename = file })
    local icon, group = utils.get_icon(ft)
    file = file:gsub(vim.env.HOME, '~')
    file = icon .. ' ' .. file
    table.insert(groups, { #icon, group })
    table.insert(list, file)
  end
  list = utils.element_align(list)
  list[1] = list[1] .. (' '):rep(6)
  list = utils.center_align(list)
  vim.list_extend(elements.lines, list)

  local mru_highlight = function(bufnr, _)
    api.nvim_buf_add_highlight(bufnr, 0, 'DashboardRecentTitle', first_line, 0, -1)
    for i, data in pairs(groups) do
      local len, group = unpack(data)
      local start_col = list[i + 1]:find('[^%s]') - 1
      api.nvim_buf_add_highlight(bufnr, 0, group, first_line + i, start_col, start_col + len)
      api.nvim_buf_add_highlight(bufnr, 0, 'DashboardFiles', first_line + i, start_col + len, -1)
    end
  end
  table.insert(elements.fns, mru_highlight)

  local mru_keymap = function(bufnr, winid)
    local opts = { buffer = bufnr, nowait = true, silent = true }
    vim.keymap.set('n', mru.jump_to_mru or 'm', function()
      local line = api.nvim_buf_get_lines(bufnr, first_line + 1, first_line + 2, false)[1]
      local start_col = line:find('%p')
      api.nvim_win_set_cursor(winid, { first_line + 2, start_col })
    end, opts)

    vim.keymap.set('n', mru.open or '<CR>', function()
      local curline = api.nvim_win_get_cursor(winid)[1]
      if curline > first_line and curline < first_line + #list then
        local content = api.nvim_get_current_line()
        local start_col = content:find('%p')
        local path = content:sub(start_col)
        path = vim.fs.normalize(path)
        vim.cmd('edit ' .. path)
      end
    end, opts)
  end
  table.insert(elements.fns, mru_keymap)
end

local function gen_footer(footer, elements)
  footer = footer or {}
  if vim.tbl_isempty(footer) then
    footer = {
      '',
      '',
      '',
      'Sharp tools make good work.',
    }
  end
  local first_line = #elements.lines
  vim.list_extend(elements.lines, utils.center_align(footer))

  local footer_highlight = function(bufnr, _)
    for i, _ in pairs(footer) do
      api.nvim_buf_add_highlight(bufnr, 0, 'DashboardFooter', first_line + i, 0, -1)
    end
  end
  table.insert(elements.fns, footer_highlight)
end

local function theme_instance(config)
  local elements = {
    lines = {},
    fns = {},
  }
  utils.generate_header(config.header, elements)
  gen_shortcut(config.shortcut, elements)
  load_packages(config.packages, elements)
  project_list(config.project, elements)
  mru_list(config.mru, elements)
  gen_footer(config.footer, elements)
  return elements
end

return setmetatable({}, {
  __call = function(_, t)
    return theme_instance(t)
  end,
})
