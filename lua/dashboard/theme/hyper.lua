local api, keymap = vim.api, vim.keymap
local utils = require('dashboard.utils')
local ns = api.nvim_create_namespace('dashboard')

local function gen_shortcut(config)
  local shortcut = vim.tbl_extend('force', {
    { desc = '[  Github]', group = 'DashboardShortCut' },
    { desc = '[  glepnir]', group = 'DashboardShortCut' },
    { desc = '[  0.2.3]', group = 'DashboardShortCut' },
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
        if type(item.action) == 'string' then
          local dump = loadstring(item.action)
          if not dump then
            vim.cmd(item.action)
          else
            dump()
          end
        elseif type(item.action) == 'function' then
          item.action()
        end
      end, { buffer = config.bufnr, nowait = true, silent = true })
    end
    api.nvim_buf_add_highlight(
      config.bufnr,
      0,
      item.group or 'DashboardShortCut',
      first_line,
      start,
      _end
    )
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
  }

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align(lines))

  for i, _ in pairs(lines) do
    api.nvim_buf_add_highlight(config.bufnr, 0, 'Comment', first_line + i - 1, 0, -1)
  end
end

local function reverse(tbl)
  for i = 1, math.floor(#tbl / 2) do
    tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
  end
end

local function project_list(config, callback)
  config.project = vim.tbl_extend('force', {
    limit = 8,
    icon = ' ',
    icon_hl = 'DashboardRecentProjectIcon',
    action = 'Telescope find_files cwd=',
    label = ' Recent Projects:',
  }, config.project or {})

  local res = {}

  utils.async_read(
    config.path,
    vim.schedule_wrap(function(data)
      local dump = assert(loadstring(data))
      local list = dump()
      if list then
        list = vim.list_slice(list, #list - config.project.limit)
      end
      for _, dir in ipairs(list or {}) do
        dir = dir:gsub(vim.env.HOME, '~')
        table.insert(res, (' '):rep(3) .. ' ' .. dir)
      end

      if #res == 0 then
        table.insert(res, (' '):rep(3) .. ' empty project')
      else
        reverse(res)
      end
      table.insert(res, 1, config.project.icon .. config.project.label)
      table.insert(res, 1, '')
      table.insert(res, '')
      callback(res)
    end)
  )
end

local function mru_list(config)
  config.mru = vim.tbl_extend('force', {
    icon = ' ',
    limit = 10,
    icon_hl = 'DashboardMruIcon',
    label = ' Most Recent Files:',
  }, config.mru or {})

  local list = {
    config.mru.icon .. config.mru.label,
  }

  local groups = {}
  local mlist = utils.get_mru_list()

  for _, file in pairs(vim.list_slice(mlist, 1, config.mru.limit)) do
    local ft = vim.filetype.match({ filename = file })
    local icon, group = utils.get_icon(ft)
    if not utils.is_win then
      file = file:gsub(vim.env.HOME, '~')
    end
    file = (icon or ' ') .. ' ' .. file
    table.insert(groups, { #icon, group })
    table.insert(list, (' '):rep(3) .. file)
  end

  if #list == 1 then
    table.insert(list, (' '):rep(3) .. ' empty files')
  end
  return list, groups
end

local function gen_hotkey(config)
  local list = { 106, 107 }
  for _, item in pairs(config.shortcut or {}) do
    if item.key then
      table.insert(list, item.key:byte())
    end
  end
  math.randomseed(os.time())
  return function()
    while true do
      local key = math.random(97, 122)
      if not vim.tbl_contains(list, key) then
        table.insert(list, key)
        return key
      end
    end
  end
end

local function map_key(config, key, content)
  keymap.set('n', key, function()
    local text = content or api.nvim_get_current_line()
    local scol = text:find('%p')
    text = text:sub(scol)
    local tbl = vim.split(text, '%s', { trimempty = true })
    local path = tbl[#tbl]
    path = vim.fs.normalize(path)
    path = vim.loop.fs_realpath(path)
    if vim.fn.isdirectory(path) == 1 then
      vim.cmd(config.project.action .. path)
    else
      vim.cmd('edit ' .. path)
    end
  end, { buffer = config.bufnr, silent = true, nowait = true })
end

local function gen_center(plist, config)
  local mlist, mgroups = mru_list(config)
  local plist_len = #plist
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.list_extend(plist, mlist)
  local max_len = utils.get_max_len(plist)
  if max_len <= 40 then
    local fill = (' '):rep(math.floor(vim.o.columns / 4))
    for i, v in pairs(plist) do
      plist[i] = v .. fill
    end
  end

  plist = utils.element_align(plist)
  local first_line = api.nvim_buf_line_count(config.bufnr)
  plist = utils.center_align(plist)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, plist)

  print(first_line)
  api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardProjectTitle', first_line + 1, 0, -1)
  local _, scol = plist[2]:find('%s+')
  api.nvim_buf_add_highlight(
    config.bufnr,
    0,
    'DashboardProjectTitleIcon',
    first_line + 1,
    0,
    scol + #config.project.icon
  )

  local hotkey = gen_hotkey(config)
  local start_col = plist[plist_len + 2]:find('[^%s]') - 1
  for i = 3, plist_len do
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
      local key = string.char(hotkey())
      api.nvim_buf_set_extmark(config.bufnr, ns, first_line + i - 1, 0, {
        virt_text = { { key, 'DashboardShortCut' } },
        virt_text_pos = 'eol',
      })
      map_key(config, key, text)
    end
  end

  -- initialize the cursor pos
  api.nvim_win_set_cursor(config.winid, { first_line + 3, start_col + 4 })

  api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardMruTitle', first_line + plist_len, 0, -1)
  api.nvim_buf_add_highlight(
    config.bufnr,
    0,
    'DashboardMruIcon',
    first_line + plist_len,
    0,
    scol + #config.mru.icon
  )

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
        virt_text = { { key, 'DashboardShortCut' } },
        virt_text_pos = 'eol',
      })
      map_key(config, key, text)
    end
  end
end

local function gen_footer(config)
  local footer = vim.tbl_extend('force', {
    '',
    '',
    ' 🚀 Sharp tools make good work.',
  }, config.footer or {})

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align(footer))

  for i, _ in pairs(footer) do
    api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardFooter', first_line + i, 0, -1)
  end
end

local function project_delete()
  api.nvim_create_user_command('DbProjectDelete', function(args)
    local path = utils.path_join(vim.fn.stdpath('cache'), 'dashboard', 'cache')
    utils.async_read(
      path,
      vim.schedule_wrap(function(data)
        local dump = assert(loadstring(data))
        local list = dump()
        local count = tonumber(args.args)
        if vim.tbl_count(list) < count then
          return
        end
        list = vim.list_slice(list, count + 1)
        local str = string.dump(assert(loadstring('return ' .. vim.inspect(list))))
        local handle = io.open(path, 'w+')
        if not handle then
          return
        end
        handle:write(str)
        handle:close()
      end)
    )
  end, {
    nargs = '+',
  })
end

local function theme_instance(config)
  project_list(config, function(plist)
    if config.disable_move then
      utils.disable_move_key(config.bufnr)
    end
    require('dashboard.theme.header').generate_header(config)
    gen_shortcut(config)
    load_packages(config)
    gen_center(plist, config)
    gen_footer(config)
    map_key(config, '<CR>')
    vim.bo[config.bufnr].modifiable = false
    require('dashboard.events').register_lsp_root(config.path)
  end)
  project_delete()
end

return setmetatable({}, {
  __call = function(_, t)
    theme_instance(t)
  end,
})
