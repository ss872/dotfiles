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
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_hidden = false,
        never_show_by_pattern = {
          ".cache",
          "dist",
          "node_modules",
          "target",
        },
        never_show = {
          ".git",
        },
      },
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = true,
    },
    window = {
      position = "left",
      width = 34,
    },
    event_handlers = {
      {
        event = "file_opened",
        handler = function()
          require("neo-tree.command").execute({ action = "close" })
        end,
      },
    },
  })
end

return M
