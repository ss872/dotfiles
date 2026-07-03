local M = {}

function M.setup()
  local ok_mason, mason = pcall(require, "mason")
  if not ok_mason then
    return
  end

  mason.setup({
    ui = {
      border = "rounded",
      icons = {
        package_installed = "+",
        package_pending = "~",
        package_uninstalled = "-",
      },
    },
  })

  local ok_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
  if ok_lspconfig then
    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls",
        "bashls",
      },
      automatic_enable = true,
    })
  end

  local ok_tool_installer, tool_installer = pcall(require, "mason-tool-installer")
  if ok_tool_installer then
    tool_installer.setup({
      ensure_installed = {
        "lua-language-server",
        "bash-language-server",
        "stylua",
        "shfmt",
        "prettier",
      },
      run_on_start = true,
      start_delay = 1500,
      debounce_hours = 12,
    })
  end
end

return M
