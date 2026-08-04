vim.loader.enable()
vim.opt.termguicolors = true
vim.opt.termbidi = true

-- ضبط ترميز الملفات بالطريقة الصحيحة المتوافقة مع النوافذ المغلقة
vim.opt.fileencoding = "utf-8"
vim.opt.clipboard = "unnamedplus"
-- إعدادات الـ Autocmd والـ Keymaps العادية
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.html",
  callback = function()
    vim.bo.filetype = "htmldjango"
  end,
})
vim.filetype.add({
  extension = {
    html = "htmldjango",
  },
})

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("i", "jp", [[<C-r>+]], { desc = "لصق من كيبورد النظام" })

vim.keymap.set("n", "<C-a>", "ggVG", { desc = "تحديد الكل" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "حفظ الملف الحالي" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "إغلاق النافذة الحالية" })
vim.keymap.set("n", "<leader>x", ":wq<CR>", { desc = "حفظ وإغلاق" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "حذف بدون نسخ" })

-- ====================================================================
-- اختصارات التنقل بين النوافذ (مع الدخول التلقائي لوضع الإدخال في التيرمنال)
-- ====================================================================
vim.keymap.set("n", "<leader><Left>", function()
  vim.cmd("wincmd h")
  if vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end, { desc = "انتقال لليمين/اليسار" })

vim.keymap.set("n", "<leader><Down>", function()
  vim.cmd("wincmd j")
  if vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end, { desc = "انتقال للأسفل" })

vim.keymap.set("n", "<leader><Up>", function()
  vim.cmd("wincmd k")
  if vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end, { desc = "انتقال للأعلى" })

vim.keymap.set("n", "<leader><Right>", function()
  vim.cmd("wincmd l")
  if vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end, { desc = "انتقال لليمين" })

-- ====================================================================
-- اختصارات التنقل وأنت داخل وضع التيرمنال (opencode) مباشرة
-- ====================================================================
vim.keymap.set("t", "<leader><Left>", [[<C-\><C-n><C-w>h]], { desc = "خروج وانتقال لليسار" })
vim.keymap.set("t", "<leader><Down>", [[<C-\><C-n><C-w>j]], { desc = "خروج وانتقال للأسفل" })
vim.keymap.set("t", "<leader><Up>", [[<C-\><C-n><C-w>k]], { desc = "خروج وانتقال للأعلى" })
vim.keymap.set("t", "<leader><Right>", [[<C-\><C-n><C-w>l]], { desc = "خروج وانتقال لليمين" })

-- ====================================================================
-- اختصارات تغيير حجم وتوزيع النوافذ (Tiling)
-- ====================================================================
vim.keymap.set("n", "<leader><S-Up>", ":resize +3<CR>", { silent = true, desc = "زيادة الارتفاع" })
vim.keymap.set("n", "<leader><S-Down>", ":resize -3<CR>", { silent = true, desc = "تقليل الارتفاع" })
vim.keymap.set("n", "<leader><S-Right>", ":vertical resize +3<CR>", { silent = true, desc = "زيادة العرض" })
vim.keymap.set("n", "<leader><S-Left>", ":vertical resize -3<CR>", { silent = true, desc = "تقليل العرض" })
vim.keymap.set("n", "<leader>wx", "<C-w>x", { desc = "تبديل أماكن النوافذ" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "تساوي أحجام النوافذ" })

-- إنشاء أمر مخصص اسمه :Format لتنسيق الكود
vim.api.nvim_create_user_command("Format", function()
  -- محاولة استخدام Conform أولاً لأنه الأفضل
  local status, conform = pcall(require, "conform")
  if status then
    conform.format({ lsp_fallback = true })
    print("✨ تم تنسيق الكود بواسطة Conform!")
  else
    -- إذا لم تكن الإضافة جاهزة، استخدم الـ LSP الافتراضي
    vim.lsp.buf.format({ async = true })
    print("✨ تم تنسيق الكود بواسطة LSP!")
  end
end, { desc = "تنسيق الملف الحالي" })

require("config.lazy")
