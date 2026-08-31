return {
  "zaidejjo/zz-lang.nvim",
  ft = "zz",
  config = function()
    require("zz-lang").setup({
      -- LSP server configuration
      lsp = {
        enabled = true, -- start zz-lsp automatically
        cmd = { "zz-lsp" }, -- command to start the server
        root_markers = { ".git", "*.zz" }, -- project root detection
        capabilities = nil, -- override LSP capabilities
        on_attach = nil, -- callback: function(client, bufnr)
      },

      -- Formatting
      format = {
        on_save = false, -- format .zz files on write
        uses_lsp = false, -- use LSP formatting; falls back to `zz fmt`
      },

      -- User commands
      commands = {
        ZZRun = true, -- :ZZRun  — run current file
        ZZCheck = true, -- :ZZCheck — type-check current file
        ZZFmt = true, -- :ZZFmt — format current file
      },

      -- Snippets
      snippets = {
        enabled = true, -- register ZZ snippet triggers
      },

      -- Statusline integration
      statusline = {
        enabled = false, -- opt-in lualine component
      },
    })
  end,
}
