local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Navigation (Line / View)
map("n", "H", "^", { desc = "First character of line" })
map("n", "L", "$", { desc = "End of line" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down & center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up & center" })
map("n", "J", "mzJ`z", { desc = "Join lines keeping cursor position" })

-- Navigation (Line / View) in Normal & Visual Mode
map({ "n", "v" }, "H", "^", { desc = "First character of line" })
map({ "n", "v" }, "L", "$", { desc = "End of line" })

-- Insert Mode Helpers
map("i", "jk", "<Esc>", opts)
map("i", "kj", "<Esc>", opts)
map("i", "jp", [[<C-r>+]], { desc = "Paste from clipboard" })

-- File & Buffer Operations
map("n", "<C-a>", "ggVG", { desc = "Select all" })
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Close window" })
map("n", "<leader>cx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make executable" })
map("n", "<C-]>", ":BufferLineMoveNext<CR>", opts)
map("n", "<C-[>", ":BufferLineMovePrev<CR>", opts)

-- Editing & Selection
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without copying" })
map("n", "<A-Down>", ":m .+1<CR>==", opts)
map("n", "<A-Up>", ":m .-2<CR>==", opts)
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", opts)

-- Window Navigation
map("n", "<leader><Left>", function()
  vim.cmd("wincmd h")
  if vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end, { desc = "Focus left window" })

map("n", "<leader><Down>", function()
  vim.cmd("wincmd j")
  if vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end, { desc = "Focus window below" })

map("n", "<leader><Up>", function()
  vim.cmd("wincmd k")
  if vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end, { desc = "Focus window above" })

map("n", "<leader><Right>", function()
  vim.cmd("wincmd l")
  if vim.bo.buftype == "terminal" then
    vim.cmd("startinsert")
  end
end, { desc = "Focus right window" })

-- Window Resizing & Layout
map("n", "<leader><S-Up>", ":resize +3<CR>", { silent = true, desc = "Increase height" })
map("n", "<leader><S-Down>", ":resize -3<CR>", { silent = true, desc = "Decrease height" })
map("n", "<leader><S-Right>", ":vertical resize +3<CR>", { silent = true, desc = "Increase width" })
map("n", "<leader><S-Left>", ":vertical resize -3<CR>", { silent = true, desc = "Decrease width" })
map("n", "<leader>wx", "<C-w>x", { desc = "Swap windows" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize window sizes" })

-- Fuzzy Search (FzfLua)
map("n", "<C-p>", "<cmd>FzfLua files<cr>", { desc = "Find files" })
map("n", "<C-t>", "<cmd>FzfLua live_grep<cr>", { desc = "Search text (Ripgrep)" })
map("n", "<C-S-f>", "<cmd>FzfLua live_grep<cr>", { desc = "Search text in project" })
map("n", "<leader>s", "<cmd>FzfLua live_grep<cr>", { desc = "Search text in project" })

-- Tools & Languages
map("n", "<leader>th", "<cmd>Themery<cr>", { desc = "Theme switcher" })
map("n", "<leader>ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", { desc = "Go error block" })
