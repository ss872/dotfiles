vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })

vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle left<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>fe", "<cmd>Neotree reveal<cr>", { desc = "Reveal current file" })

local function telescope_builtin(name, opts)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
      builtin[name](opts or {})
    end
  end
end

vim.keymap.set("n", "<leader>ff", telescope_builtin("git_files"), { desc = "Find git files" })
vim.keymap.set("n", "<leader>fa", telescope_builtin("find_files", { hidden = true, no_ignore = true }), { desc = "Find all files" })
vim.keymap.set("n", "<leader>fg", telescope_builtin("live_grep"), { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", telescope_builtin("buffers"), { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", telescope_builtin("help_tags"), { desc = "Help tags" })
