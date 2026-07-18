return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },

  config = function()
    local cmp = require("cmp")

    cmp.setup({
      -- تفعيل ميزة النص الشبح الذكي (Ghost Text) مثل Zed
      experimental = {
        ghost_text = {
          hl_group = "Comment", -- يجعل لون النص المقترح رمادي خافت جداً ومريح للعين
        },
      },

      mapping = cmp.mapping.preset.insert({
        -- 🔥 التغيير الرئيسي: Tab أصبح زر القبول
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true }) -- يقبل أول اقتراح
          else
            fallback() -- يعمل كـ Tab عادي إذا لم تكن هناك تكملة
          end
        end, { "i", "s" }),

        -- 🔥 تغيير Enter: لم يعد يقبل التكملة، بل يدخل سطر جديد فقط
        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.abort() -- يلغي التكملة إذا كانت ظاهرة
          end
          fallback() -- ثم يدخل سطر جديد
        end, { "i" }),

        -- Shift+Tab للتنقل للخلف في قائمة الاقتراحات
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),

        -- الحل السحري: إذا ضغطت سهم لأسفل والقائمة مفتوحة، سيغلقها وينزل سطر لأسفل فوراً دون إزعاج
        ["<Down>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.close()
          end
          fallback()
        end, { "i", "s" }),

        -- نفس الشيء عند الضغط على سهم لأعلى
        ["<Up>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.close()
          end
          fallback()
        end, { "i", "s" }),
      }),

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "codeium" },
      }),
    })
  end,
}
