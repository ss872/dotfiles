local M = {}

function M.setup()
  local ok, which_key = pcall(require, "which-key")
  if not ok then
    return
  end

  which_key.setup()
  which_key.add({
    { "<leader>w", desc = "Save file" },
    { "<leader>q", desc = "Quit window" },
    { "<leader>e", desc = "Toggle file tree" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>h", group = "Hunks" },
  })
end

return M
