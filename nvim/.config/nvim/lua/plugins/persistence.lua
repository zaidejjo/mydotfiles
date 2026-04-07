return {
  "folke/persistence.nvim",
  event = "BufReadPre", -- يتم تفعيله بمجرد فتح أي ملف
  opts = {
    -- خيارات إضافية إذا أردت تخصيص المسار
    -- dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
    options = { "buffers", "curdir", "tabpages", "winsize" }, -- الأشياء التي سيحفظها
  },
  keys = {
    -- استعادة جلسة المجلد الحالي (المشروع اللي أنت فيه)
    {
      "<leader>qs",
      function()
        require("persistence").load()
      end,
      desc = "Restore Session",
    },

    -- اختيار جلسة من الجلسات السابقة (قائمة)
    {
      "<leader>qS",
      function()
        require("persistence").select()
      end,
      desc = "Select Session",
    },

    -- استعادة آخر جلسة كنت فاتحها قبل إغلاق Neovim
    {
      "<leader>ql",
      function()
        require("persistence").load({ last = true })
      end,
      desc = "Restore Last Session",
    },

    -- إيقاف الحفظ التلقائي (لو كنت تفتح ملفات مؤقتة ولا تريد حفظها)
    {
      "<leader>qd",
      function()
        require("persistence").stop()
      end,
      desc = "Don't Save Current Session",
    },
  },
}
