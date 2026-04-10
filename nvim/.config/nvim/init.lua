require("config.lazy")

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.html",
  callback = function()
    vim.bo.filetype = "htmldjango"
  end,
})

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")

vim.opt.termguicolors = true
vim.opt.fileencoding = "utf-8"
vim.opt.termbidi = true
