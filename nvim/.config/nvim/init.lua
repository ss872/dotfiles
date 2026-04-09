vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.updatetime = 250

local github = function(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({
  { src = github("nvim-treesitter/nvim-treesitter") },
  { src = github("folke/which-key.nvim") },
  { src = github("lewis6991/gitsigns.nvim") },
})

vim.cmd.packadd("nvim-treesitter")
vim.cmd.packadd("which-key.nvim")
vim.cmd.packadd("gitsigns.nvim")

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })

local has_treesitter, treesitter = pcall(require, "nvim-treesitter")
if has_treesitter then
  treesitter.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "bash", "lua", "vim", "help" },
    callback = function(event)
      pcall(vim.treesitter.start, event.buf)
      vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

local has_which_key, which_key = pcall(require, "which-key")
if has_which_key then
  which_key.setup()
  which_key.add({
    { "<leader>w", desc = "Save file" },
    { "<leader>q", desc = "Quit window" },
    { "<leader>g", group = "Git" },
    { "<leader>h", group = "Hunks" },
  })
end

local has_gitsigns, gitsigns = pcall(require, "gitsigns")
if has_gitsigns then
  gitsigns.setup()

  vim.keymap.set("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
  vim.keymap.set("n", "<leader>gb", gitsigns.blame_line, { desc = "Blame line" })
  vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
end
