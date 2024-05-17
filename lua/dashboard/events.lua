local api, lsp, uv = vim.api, vim.lsp, vim.loop
local au = {}
local get_lsp_clients = vim.fn.has('nvim-0.10') == 1 and vim.lsp.get_clients
  or lsp.get_active_clients

function au.register_lsp_root(path)
  api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
      local projects = {}
      for _, client in pairs(get_lsp_clients() or {}) do
        local root_dir = client.config.root_dir
        if root_dir and not vim.tbl_contains(projects, root_dir) then
          table.insert(projects, root_dir)
        end

        for _, folder in pairs(client.workspace_folders or {}) do
          if not vim.tbl_contains(projects, folder.name) then
            table.insert(projects, folder.name)
          end
        end
      end

      if #projects == 0 then
        return
      end

      -- callback hell holy shit but simply than write a async await lib
      -- also I don't link to add a thirdpart plugin. this is just a small code
      uv.fs_open(path, 'r+', 384, function(err, fd)
        assert(not err, err)
        uv.fs_fstat(fd, function(err, stat)
          assert(not err, err)
          uv.fs_read(fd, stat.size, 0, function(err, data)
            assert(not err, err)
            local before = assert(loadstring(data))
            local plist = before()
            if plist and #plist > 10 then
              plist = vim.list_slice(plist, 10)
            end
            plist = vim.tbl_filter(function(k)
              return not vim.tbl_contains(projects, k)
            end, plist or {})
            plist = vim.list_extend(plist, projects)
            local dump = 'return ' .. vim.inspect(plist)
            uv.fs_write(fd, dump, 0, function(err, _)
              assert(not err, err)
              uv.fs_ftruncate(fd, #dump, function(err, _)
                assert(not err, err)
                uv.fs_close(fd)
              end)
            end)
          end)
        end)
      end)
    end,
  })
end

return au
