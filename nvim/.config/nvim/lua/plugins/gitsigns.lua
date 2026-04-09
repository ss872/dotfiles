local M = {}

function M.setup()
  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok then
    return
  end

  gitsigns.setup()

  vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
  vim.keymap.set("n", "<leader>gb", gitsigns.blame_line, { desc = "Blame line" })
  vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
end

return M
