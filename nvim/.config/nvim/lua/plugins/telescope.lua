return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  opts = function(_, opts)
    opts.defaults = opts.defaults or {}
    opts.pickers = opts.pickers or {}

    -- إعدادات المعاينة الخارقة لمنع أي تأخير (Lag)
    opts.defaults.preview = {
      treesitter = false, -- إيقاف تسريتر داخل المعاينة (مهم جداً للسرعة)
      use_less = false, -- إيقاف أداة less الداخلية لتسريع التحميل
      filetype_hook = function(filepath, bufnr, opts)
        -- إذا كان الملف أكبر من 100 كيلوبايت، لا تعمل له معاينة عشان ما يهنق المتصفح
        local max_size = 100 * 1024 -- 100 KB
        local stat = vim.loop.fs_stat(filepath)
        if stat and stat.size > max_size then
          return false
        end
        return true
      end,
    }

    -- تسريع المعالجة الداخلية للتلسكوب
    opts.defaults.vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
    }

    opts.defaults.file_ignore_patterns = {
      "node_modules/",
      "venv/",
      "%.venv/",
      "staticfiles/",
      "%.git/",
      "build/",
      "dist/",
    }

    opts.defaults.layout_strategy = "horizontal"
    opts.defaults.layout_config = {
      horizontal = {
        width = 0.85,
        height = 0.85,
        preview_width = 0.55,
        hide_on_startup = true, -- افتح التلسكوب بدون شاشة معاينة لتكون السرعة مطلقة
      },
      prompt_position = "top",
    }
    opts.defaults.sorting_strategy = "ascending"

    opts.pickers.find_files = {
      hidden = true,
      find_command = {
        "fd",
        "--type",
        "f",
        "--hidden",
        "--exclude",
        ".git",
        "--strip-cwd-prefix",
      },
    }

    opts.extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    }

    local ok, telescope = pcall(require, "telescope")
    if ok then
      telescope.load_extension("fzf")
    end
  end,
}
