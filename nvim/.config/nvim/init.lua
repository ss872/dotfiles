vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("plugins").setup()
require("config.keymaps")
require("plugins.config").setup()
