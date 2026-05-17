return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },

    config = function()
      require("render-markdown").setup({
        render_modes = true,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          require("render-markdown").enable()
        end,
      })
    end,
  },
}
