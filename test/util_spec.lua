local util = require('dashboard.util')
local eq = assert.equal
local same = assert.same

describe('util functions', function()
  local bufnr
  before_each(function()
    bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_win_set_buf(0, bufnr)
  end)

  it('util.path_sep get path of system', function()
    local iswin = vim.loop.os_uname().version:match('Windows')
    local path = util.path_sep()
    eq('/', path)
    if iswin then
      eq('\\', path)
      vim.opt.shellslash = true
      eq('/', path)
    end
  end)

  it('util.path_join', function()
    local nvim = '/Users/runner/.cache/nvim'
    local dir = 'dashboard'
    local path = util.path_join(nvim, dir)
    eq('/Users/runner/.cache/nvim/dashboard', path)
  end)

  it('util.tail_align', function()
    local lines = { 'balabala  ', 'foo  ', 'bar   ' }
    lines = util.tail_align(lines)
    same({
      'balabala  ',
      'foo       ',
      'bar       ',
    }, lines)
  end)

  it('util.center_align', function()
    local lines = { 'balabala  ', 'foo  ', 'bar   ' }
    lines = util.tail_align(lines)
    lines = util.center_align(lines)
    same({
      '                                   balabala  ',
      '                                   foo       ',
      '                                   bar       ',
    }, lines)
  end)

  it('util.generate_empty_table', function()
    local tbl = util.generate_empty_table(2)
    same({
      '',
      '',
    }, tbl)
  end)

  it('util.get_vcs_root', function()
    vim.api.nvim_buf_set_name(bufnr, 'test.lua')
    local root = util.get_vcs_root(bufnr)
    eq(vim.loop.cwd(), root)
  end)
end)
