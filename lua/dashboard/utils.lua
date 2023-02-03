local uv = vim.loop
local utils = {}

utils.is_win = uv.os_uname().sysname == 'Windows_NT'

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

function utils.get_icon(ft)
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if not ok then
    vim.notify('[dashboard.nvim] not found nvim-web-devicons')
    return nil
  end
  return devicons.get_icon_by_filetype(ft, { default = true })
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

function utils.get_packages_count()
  local count = 0
  ---@diagnostic disable-next-line: undefined-global
  if packer_plugins then
    ---@diagnostic disable-next-line: undefined-global
    count = #vim.tbl_keys(packer_plugins)
  end
  local status, lazy = pcall(require, 'lazy')
  if status then
    count = lazy.stats().count
  end
  return count
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

return utils
