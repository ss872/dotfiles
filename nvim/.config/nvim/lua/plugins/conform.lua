local M = {}

function M.setup()
  local ok, conform = pcall(require, "conform")
  if not ok then
    return
  end

  conform.setup({
    formatters_by_ft = {
      css = { "prettier" },
      fish = { "fish_indent" },
      javascript = { "prettier" },
      json = { "jq" },
      jsonc = { "prettier" },
      lua = { "stylua" },
      markdown = { "prettier" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      typescript = { "prettier" },
      yaml = { "prettier" },
    },
    format_on_save = function(buffer)
      local disable_filetypes = {
        kdl = true,
      }

      if disable_filetypes[vim.bo[buffer].filetype] then
        return
      end

      return {
        timeout_ms = 500,
        lsp_format = "fallback",
      }
    end,
  })

  vim.keymap.set({ "n", "v" }, "<leader>cf", function()
    conform.format({ async = true, lsp_format = "fallback" })
  end, { desc = "Format" })
end

return M
