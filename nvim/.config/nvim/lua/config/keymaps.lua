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

-- تعيين Ctrl + p للبحث عن ملفات (يدعم Telescope أو fzf-lua تلقائياً في LazyVim)
vim.keymap.set("n", "<C-p>", function()
  if LazyVim.pick.picker.name == "fzf" then
    vim.cmd("FzfLua files")
  else
    vim.cmd("Telescope find_files")
  end
end, { desc = "Find Files (Ctrl+p)" })

-- تعيين Leader + f لنفس المهمة
vim.keymap.set("n", "<leader>f", function()
  if LazyVim.pick.picker.name == "fzf" then
    vim.cmd("FzfLua files")
  else
    vim.cmd("Telescope find_files")
  end
end, { desc = "Find Files (Leader+f)" })

-- البحث عن كلمة أو نص داخل المشروع بالكامل (مثل Ctrl+Shift+F في Zed)
vim.keymap.set("n", "<C-S-f>", function()
  if LazyVim.pick.picker.name == "fzf" then
    vim.cmd("FzfLua live_grep")
  else
    vim.cmd("Telescope live_grep")
  end
end, { desc = "Search Text in Project (Ctrl+Shift+F)" })

-- اختصار بديل مريح لليد (Leader + s) للبحث الشامل
vim.keymap.set("n", "<leader>s", function()
  if LazyVim.pick.picker.name == "fzf" then
    vim.cmd("FzfLua live_grep")
  else
    vim.cmd("Telescope live_grep")
  end
end, { desc = "Search Text in Project (Leader + s)" })
