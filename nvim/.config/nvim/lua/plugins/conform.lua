return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      html = { "djlint" },
      htmldjango = { "djlint" },

      python = { "ruff_format" },

      javascript = { "prettier" },
      typescript = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },

      lua = { "stylua" },

      markdown = { "prettier" },
    },
  },
}
