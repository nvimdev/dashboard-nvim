local api, uv, fn, keymap = vim.api, vim.loop, vim.fn, vim.keymap
local utils = require('dashboard.utils')
local ns = api.nvim_create_namespace('dashboard')

local function gen_shortcut(config)
  local shortcut = vim.tbl_extend('force', {
    { desc = '[  Github]', group = 'Title' },
    { desc = '[  glepnir]', group = 'Title' },
    { desc = '[  0.2.3]', group = 'Title' },
  }, config.shortcut or {})

  if vim.tbl_isempty(shortcut) then
    shortcut = {}
  end

  local lines = ''
  for _, item in pairs(shortcut) do
    local str = item.desc
    if item.key then
      str = str .. '[' .. item.key .. ']'
    end
    lines = lines .. '  ' .. str
  end

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align({ lines }))

  local line = api.nvim_buf_get_lines(config.bufnr, first_line, -1, false)[1]
  local start = line:find('[^%s]') - 1
  for _, item in pairs(shortcut) do
    local _end = start + api.nvim_strwidth(item.desc) + 2
    if item.key then
      _end = _end + api.nvim_strwidth(item.key) + 2
      keymap.set('n', item.key, function()
        vim.cmd(item.action)
      end, { buffer = config.bufnr, nowait = true, silent = true })
    end
    api.nvim_buf_add_highlight(config.bufnr, 0, item.group, first_line, start, _end)
    start = _end + 2
  end
end

local function load_packages(config)
  local packages = config.packages or {
    enable = true,
  }
  if not packages.enable then
    return
  end

  local lines = {
    '',
    'neovim loaded ' .. utils.get_packages_count() .. ' packages',
    '',
    '',
  }

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align(lines))

  for i, _ in pairs(lines) do
    api.nvim_buf_add_highlight(config.bufnr, 0, 'Comment', first_line + i - 1, 0, -1)
  end
end

local function project_list(config)
  config.project = vim.tbl_extend('force', {
    limit = 10,
    jump_to_project = 'p',
  }, config.project or {})

  if vim.fn.filereadable(config.path) == 0 then
    local ok, fd = pcall(uv.fs_open, config.path, 'w', 420)
    if not ok then
      vim.notify('[dashboard.nvim] create project tmp file failed', vim.log.levels.ERROR)
      return
    end
    uv.fs_close(fd)
  end

  local fd = io.open(config.path, 'r')
  local res = {
    '異 Recently Projects: [' .. config.project.jump_to_project .. ']',
  }
  for line in fd:lines() do
    table.insert(res, ' ' .. line)
  end
  fd:close()

  if #res == 1 then
    table.insert(res, (' '):rep(3) .. ' empty project')
  end
  table.insert(res, '')
  return res
end

local function mru_list(config)
  config.mru = vim.tbl_extend('force', {
    limit = 10,
    jump_to_mru = 'm',
  }, config.mru or {})

  local list = {
    '  Most Recent Files: [' .. (config.mru.jump_to_mru or 'm') .. ']',
  }

  local groups = {}
  for _, file in pairs(vim.list_slice(utils.get_mru_list(), 1, config.mru.limit)) do
    local ft = vim.filetype.match({ filename = file })
    local icon, group = utils.get_icon(ft)
    file = file:gsub(vim.env.HOME, '~')
    file = icon .. ' ' .. file
    table.insert(groups, { #icon, group })
    table.insert(list, (' '):rep(3) .. file)
  end

  return list, groups
end

local function gen_hotkey(config)
  local list = {}
  for _, item in pairs(config.shortcut) do
    if item.key then
      table.insert(list, item.key:byte())
    end
  end
  table.insert(list, config.project.jump_to_project:byte())
  table.insert(list, config.mru.jump_to_mru:byte())
  return function()
    while true do
      local key = math.random(97, 122)
      if not vim.tbl_contains(list, key) then
        return key
      end
    end
  end
end

local function gen_center(config)
  local plist = project_list(config)
  local mlist, mgroups = mru_list(config)
  local plist_len = #plist
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.list_extend(plist, mlist)
  plist = utils.element_align(plist)
  local first_line = api.nvim_buf_line_count(config.bufnr)
  plist = utils.center_align(plist)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, plist)

  api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardRecentProject', first_line, 0, -1)

  local hotkey = gen_hotkey(config)
  local start_col = plist[plist_len + 2]:find('[^%s]') - 1
  for i = 2, plist_len do
    api.nvim_buf_add_highlight(
      config.bufnr,
      0,
      'DashboardProjectIcon',
      first_line + i - 1,
      0,
      start_col + 3
    )
    api.nvim_buf_add_highlight(
      config.bufnr,
      0,
      'DashboardFiles',
      first_line + i - 1,
      start_col + 3,
      -1
    )
    local text = api.nvim_buf_get_lines(config.bufnr, first_line + i - 1, first_line + i, false)[1]
    if text and text:find('%w') then
      api.nvim_buf_set_extmark(config.bufnr, ns, first_line + i - 1, 0, {
        virt_text = { { string.char(hotkey()), 'title' } },
        virt_text_pos = 'eol',
      })
    end
  end

  -- initialize the cursor pos
  api.nvim_win_set_cursor(config.winid, { first_line + 2, start_col + 4 })
  local opts = { buffer = config.bufnr, nowait = true, silent = true }
  keymap.set('n', config.project.jump_to_project, function()
    api.nvim_win_set_cursor(config.winid, { first_line + 2, start_col + 4 })
  end, opts)

  api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardRecentTitle', first_line + plist_len, 0, -1)
  for i, data in pairs(mgroups) do
    local len, group = unpack(data)
    api.nvim_buf_add_highlight(
      config.bufnr,
      0,
      group,
      first_line + i + plist_len,
      start_col,
      start_col + len
    )
    api.nvim_buf_add_highlight(
      config.bufnr,
      0,
      'DashboardFiles',
      first_line + i + plist_len,
      start_col + len,
      -1
    )

    local text = api.nvim_buf_get_lines(
      config.bufnr,
      first_line + i + plist_len,
      first_line + i + plist_len + 1,
      false
    )[1]
    if text and text:find('%w') then
      local key = string.char(hotkey())
      api.nvim_buf_set_extmark(config.bufnr, ns, first_line + i + plist_len, 0, {
        virt_text = { { key, 'title' } },
        virt_text_pos = 'eol',
      })
      keymap.set('n', key, function()
        if text:find('~') then
          local path = vim.split(text, '%s', { trimempty = true })
          local fname = path[#path]
          fname = vim.fs.normalize(fname)
          local ext = fn.fnamemodify(path, ':e')
          if #ext > 0 then
            vim.cmd('edit ' .. fname)
          end
        end
      end, { buffer = config.bufnr, nowait = true, silent = true })
    end
  end

  keymap.set('n', config.mru.jump_to_mru, function()
    api.nvim_win_set_cursor(config.winid, { plist_len + first_line + 2, start_col + 4 })
  end, opts)
end

local function gen_footer(config)
  local footer = vim.tbl_extend('force', {
    enable = true,
    content = {
      '',
      '',
      '',
      'Sharp tools make good work.',
    },
  }, config.footer or {})
  if not footer.enable then
    return
  end

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align(footer.content))

  for i, _ in pairs(footer.content) do
    api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardFooter', first_line + i, 0, -1)
  end
end

local function map_enter(bufnr)
  keymap.set('n', '<CR>', function()
    local line = api.nvim_get_current_line()
    if line:find('~') then
      local scol = line:find('%p')
      local path = line:sub(scol)
      path = vim.fs.normalize(path)
      local ext = fn.fnamemodify(path, ':e')
      if #ext > 0 then
        vim.cmd('edit ' .. path)
      end
    end
  end, { buffer = bufnr, silent = true, nowait = true })
end

local function theme_instance(config)
  utils.generate_header(config)
  gen_shortcut(config)
  load_packages(config)
  gen_center(config)
  gen_footer(config)
  map_enter(config.bufnr)
end

return setmetatable({}, {
  __call = function(_, t)
    theme_instance(t)
  end,
})
