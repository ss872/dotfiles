local M = {}

function M.setup()
  local ok, treesitter = pcall(require, "nvim-treesitter")
  if not ok then
    return
  end

  treesitter.setup()

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "bash", "lua", "vim", "help" },
    callback = function(event)
      pcall(vim.treesitter.start, event.buf)
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

return M
