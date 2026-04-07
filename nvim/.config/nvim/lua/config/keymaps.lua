-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- ~/.config/nvim/lua/custom/keymaps.lua

local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- ===============================
-- Esc shortcut
-- ===============================
-- اضغط jk للخروج من insert mode
vim.api.nvim_set_keymap("i", "jk", "<Esc>", opts)
vim.api.nvim_set_keymap("i", "jj", "<Esc>", opts)
vim.api.nvim_set_keymap("i", "kj", "<Esc>", opts)

-- تحريك التبويب لليمين
vim.keymap.set("n", "<C-]>", ":BufferLineMoveNext<CR>", { noremap = true, silent = true })

-- تحريك التبويب لليسار
vim.keymap.set("n", "<C-[>", ":BufferLineMovePrev<CR>", { noremap = true, silent = true })
