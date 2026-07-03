local M = {}

function M.setup()
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    return
  end

  telescope.setup({
    defaults = {
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      winblend = 0,
    },
    pickers = {
      find_files = {
        hidden = true,
      },
      live_grep = {
        additional_args = function()
          return { "--hidden", "--glob", "!**/.git/*" }
        end,
      },
    },
  })
end

return M
