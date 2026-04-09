local M = {}

local function github(repo)
  return "https://github.com/" .. repo
end

local plugins = {
  { src = github("nvim-treesitter/nvim-treesitter") },
  { src = github("folke/which-key.nvim") },
  { src = github("lewis6991/gitsigns.nvim") },
  { src = github("nvim-neo-tree/neo-tree.nvim") },
  { src = github("nvim-telescope/telescope.nvim") },
  { src = github("nvim-lua/plenary.nvim") },
  { src = github("MunifTanjim/nui.nvim") },
  { src = github("nvim-tree/nvim-web-devicons") },
}

local plugin_names = {
  "nvim-treesitter",
  "which-key.nvim",
  "gitsigns.nvim",
  "neo-tree.nvim",
  "telescope.nvim",
  "plenary.nvim",
  "nui.nvim",
  "nvim-web-devicons",
}

function M.setup()
  vim.pack.add(plugins)

  for _, plugin in ipairs(plugin_names) do
    vim.cmd.packadd(plugin)
  end
end

return M
