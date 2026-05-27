-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- ~/.config/nvim/lua/custom/keymaps.lua

local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

vim.api.nvim_set_keymap("i", "jk", "<Esc>", opts)
vim.api.nvim_set_keymap("i", "kj", "<Esc>", opts)

vim.keymap.set("n", "<C-]>", ":BufferLineMoveNext<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-[>", ":BufferLineMovePrev<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-p>", function()
  if LazyVim.pick.picker.name == "fzf" then
    vim.cmd("FzfLua files")
  else
    vim.cmd("Telescope find_files")
  end
end, { desc = "Find Files (Ctrl+p)" })

vim.keymap.set("n", "<C-t>", function()
  if LazyVim.pick.picker.name == "fzf" then
    vim.cmd("FzfLua live_grep")
  else
    vim.cmd("Telescope live_grep")
  end
end, { desc = "Search Text with Ripgrep (Ctrl+t)" })



vim.keymap.set("n", "<C-S-f>", function()
  if LazyVim.pick.picker.name == "fzf" then
    vim.cmd("FzfLua live_grep")
  else
    vim.cmd("Telescope live_grep")
  end
end, { desc = "Search Text in Project (Ctrl+Shift+F)" })

vim.keymap.set("n", "<leader>s", function()
  if LazyVim.pick.picker.name == "fzf" then
    vim.cmd("FzfLua live_grep")
  else
    vim.cmd("Telescope live_grep")
  end
end, { desc = "Search Text in Project (Leader + s)" })
