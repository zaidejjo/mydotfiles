return {
  "nvim-neo-tree/neo-tree.nvim",
  config = function()
    -- جلب الإعدادات الافتراضية أولاً لضمان عدم حدوث أي تعارض
    local neotree = require("neo-tree")

    neotree.setup({
      filesystem = {
        filtered_items = {
          visible = true, -- إظهار الملفات المخفية بلون خفيف
          hide_dotfiles = false, -- إلغاء إخفاء ملفات الـ dotfiles
          hide_gitignored = false, -- إظهار ملفات الـ gitignore
          never_show = {
            ".DS_Store",
            "thumbs.db",
          },
          always_show = {
            ".env",
            ".env.local",
            ".env.development",
            ".env.production",
          },
        },
      },
    })
  end,
}
