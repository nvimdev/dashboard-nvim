local uv = vim.loop
local utils = {}

utils.is_win = uv.os_uname().version:match('Windows')

function utils.path_join(...)
  local path_sep = utils.is_win and '\\' or '/'
  return table.concat({ ... }, path_sep)
end

function utils.element_align(tbl)
  local lens = {}
  vim.tbl_map(function(k)
    table.insert(lens, vim.api.nvim_strwidth(k))
  end, tbl)
  table.sort(lens)
  local max = lens[#lens]
  local res = {}
  for _, item in pairs(tbl) do
    local len = vim.api.nvim_strwidth(item)
    local times = math.floor((max - len) / vim.api.nvim_strwidth(' '))
    item = item .. (' '):rep(times)
    table.insert(res, item)
  end
  return res
end

function utils.get_max_len(contents)
  vim.validate({
    contents = { contents, 't' },
  })
  local cells = {}
  for _, v in pairs(contents) do
    table.insert(cells, vim.api.nvim_strwidth(v))
  end
  table.sort(cells)
  return cells[#cells]
end

-- draw the graphics into the screen center
function utils.center_align(tbl)
  vim.validate({
    tbl = { tbl, 'table' },
  })
  local function fill_sizes(lines)
    local fills = {}
    for _, line in pairs(lines) do
      table.insert(fills, math.floor((vim.o.columns - vim.api.nvim_strwidth(line)) / 2))
    end
    return fills
  end

  local centered_lines = {}
  local fills = fill_sizes(tbl)

  for i = 1, #tbl do
    local fill_line = (' '):rep(fills[i]) .. tbl[i]
    table.insert(centered_lines, fill_line)
  end

  return centered_lines
end

function utils.get_icon(filename)
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if not ok then
    vim.notify('[dashboard.nvim] not found nvim-web-devicons')
    return nil
  end
  return devicons.get_icon(filename, nil, { default = true })
end

function utils.read_project_cache(path)
  local fd = assert(uv.fs_open(path, 'r', tonumber('644', 8)))
  local stat = uv.fs_fstat(fd)
  local chunk = uv.fs_read(fd, stat.size, 0)
  local dump = assert(loadstring(chunk))
  return dump()
end

function utils.async_read(path, callback)
  uv.fs_open(path, 'a+', 438, function(err, fd)
    assert(not err, err)
    uv.fs_fstat(fd, function(err, stat)
      assert(not err, err)
      uv.fs_read(fd, stat.size, 0, function(err, data)
        assert(not err, err)
        uv.fs_close(fd, function(err)
          assert(not err, err)
          callback(data)
        end)
      end)
    end)
  end)
end

function utils.disable_move_key(bufnr)
  local keys = { 'w', 'f', 'b', 'h', 'j', 'k', 'l', '<Up>', '<Down>', '<Left>', '<Right>' }
  vim.tbl_map(function(k)
    vim.keymap.set('n', k, '<Nop>', { buffer = bufnr })
  end, keys)
end

--- return the most recently files list
function utils.get_mru_list()
  local mru = {}
  for _, file in pairs(vim.v.oldfiles or {}) do
    if file and vim.fn.filereadable(file) == 1 then
      table.insert(mru, file)
    end
  end
  return mru
end

function utils.get_package_manager_stats()
  local package_manager_stats = { name = '', count = 0, loaded = 0, time = 0 }
  ---@diagnostic disable-next-line: undefined-global
  if packer_plugins then
    package_manager_stats.name = 'packer'
    ---@diagnostic disable-next-line: undefined-global
    package_manager_stats.count = #vim.tbl_keys(packer_plugins)
  end
  local status, lazy = pcall(require, 'lazy')
  if status then
    package_manager_stats.name = 'lazy'
    package_manager_stats.loaded = lazy.stats().loaded
    package_manager_stats.count = lazy.stats().count
    package_manager_stats.time = lazy.stats().startuptime
  end
  return package_manager_stats
end

--- generate an empty table by length
function utils.generate_empty_table(length)
  local empty_tbl = {}
  if length == 0 then
    return empty_tbl
  end

  for _ = 1, length do
    table.insert(empty_tbl, '')
  end
  return empty_tbl
end

function utils.generate_truncateline(cells)
  local char = '┉'
  return char:rep(math.floor(cells / vim.api.nvim_strwidth(char)))
end

function utils.get_vcs_root(buf)
  buf = buf or 0
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':p:h')
  local patterns = { '.git', '.hg', '.bzr', '.svn' }
  for _, pattern in pairs(patterns) do
    local root = vim.fs.find(pattern, { path = path, upward = true, stop = vim.env.HOME })
    if root then
      return root
    end
  end
end

local index = 0
function utils.gen_bufname(prefix)
  index = index + 1
  return prefix .. '-' .. index
end

function utils.buf_is_empty(bufnr)
  bufnr = bufnr or 0
  return vim.api.nvim_buf_line_count(0) == 1
    and vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == ''
end

return utils
