local M = {}

local modules = {
  "plugins.gitsigns",
  "plugins.mason",
  "plugins.lsp",
  "plugins.conform",
  "plugins.neo-tree",
  "plugins.telescope",
  "plugins.treesitter",
  "plugins.which-key",
}

function M.setup()
  for _, module in ipairs(modules) do
    local ok, plugin = pcall(require, module)
    if ok and type(plugin.setup) == "function" then
      plugin.setup()
    end
  end
end

return M
