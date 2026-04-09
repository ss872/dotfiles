local M = {}

function M.setup()
  local ok, neo_tree = pcall(require, "neo-tree")
  if not ok then
    return
  end

  neo_tree.setup({
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    sources = { "filesystem", "buffers", "git_status" },
    filesystem = {
      follow_current_file = {
        enabled = true,
      },
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = true,
    },
    window = {
      position = "left",
      width = 34,
    },
  })
end

return M
