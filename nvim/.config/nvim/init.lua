vim.loader.enable()
vim.opt.termguicolors = true
vim.opt.termbidi = true
local autocmd = vim.api.nvim_create_autocmd
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

vim.api.nvim_create_user_command("Format", function()
  local status, conform = pcall(require, "conform")
  if status then
    conform.format({ lsp_fallback = true })
  else
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "Format current file" })

require("config.lazy")
