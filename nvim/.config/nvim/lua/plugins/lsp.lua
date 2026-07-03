local M = {}

local function map(buffer, lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc })
end

function M.setup()
  pcall(require, "lspconfig")

  vim.lsp.config("lua_ls", {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
        },
        telemetry = {
          enable = false,
        },
      },
    },
  })

  vim.diagnostic.config({
    severity_sort = true,
    virtual_text = {
      spacing = 2,
      source = "if_many",
    },
    float = {
      border = "rounded",
      source = true,
    },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      local buffer = event.buf

      if client and client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, buffer, { autotrigger = true })
      end

      map(buffer, "gd", vim.lsp.buf.definition, "Go to definition")
      map(buffer, "gD", vim.lsp.buf.declaration, "Go to declaration")
      map(buffer, "gr", vim.lsp.buf.references, "References")
      map(buffer, "gi", vim.lsp.buf.implementation, "Go to implementation")
      map(buffer, "K", vim.lsp.buf.hover, "Hover")
      map(buffer, "<leader>rn", vim.lsp.buf.rename, "Rename")
      map(buffer, "<leader>ca", vim.lsp.buf.code_action, "Code action")
      map(buffer, "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
      map(buffer, "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
      map(buffer, "]d", vim.diagnostic.goto_next, "Next diagnostic")
    end,
  })

  vim.keymap.set("i", "<C-Space>", function()
    vim.lsp.completion.get()
  end, { desc = "Trigger completion" })
end

return M
