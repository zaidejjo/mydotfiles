return {
  "zaldih/themery.nvim",
  cmd = "Themery",
  config = function()
    require("themery").setup({
      themes = {
        -- الثيمات الحالية
        "catppuccin",
        "tokyonight",
        "tokyonight-night",
        "tokyonight-storm",
        "tokyonight-day",
        "catppuccin-mocha",
        "catppuccin-macchiato",
        "catppuccin-frappe",
        "kanagawa",
        "kanagawa-wave",
        "kanagawa-dragon",
        "gruvbox",

        -- الثيمات الجديدة المضافة
        "rose-pine",
        "rose-pine-moon",
        "rose-pine-dawn",
        "nightfox",
        "duskfox",
        "nordfox",
        "carbonfox",
        "everforest",
        "onedark",
        "onelight",
        "nord",
        "github_dark",
        "github_dark_dimmed",
      },
      livePreview = true,
    })
  end,
}
