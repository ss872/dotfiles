local M = {}

function M.setup()
  local ok, treesitter = pcall(require, "nvim-treesitter")
  if not ok then
    return
  end

  treesitter.setup()

  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "bash",
      "css",
      "fish",
      "help",
      "javascript",
      "json",
      "jsonc",
      "kdl",
      "lua",
      "markdown",
      "typescript",
      "vim",
      "yaml",
    },
    callback = function(event)
      pcall(vim.treesitter.start, event.buf)
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

return M
