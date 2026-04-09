-- Requires: pngpaste (brew install pngpaste)
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["gp"] = {
                  function(picker)
                    if vim.fn.executable("pngpaste") ~= 1 then
                      Snacks.notify.error("pngpaste not found. Install with: brew install pngpaste")
                      return
                    end

                    vim.fn.system("pngpaste -b 2>&1")
                    if vim.v.shell_error ~= 0 then
                      Snacks.notify.warn("No image in clipboard")
                      return
                    end

                    local dir = picker:dir()
                    if not dir then
                      Snacks.notify.error("Cannot determine current directory")
                      return
                    end

                    local filename = "screenshot-" .. os.date("%Y%m%d-%H%M%S") .. ".png"
                    local filepath = dir .. "/" .. filename

                    local result = vim.fn.system({ "pngpaste", filepath })
                    if vim.v.shell_error ~= 0 then
                      Snacks.notify.error("Failed to paste image: " .. result)
                      return
                    end

                    local Tree = require("snacks.explorer.tree")
                    Tree:refresh(dir)
                    require("snacks.explorer.actions").update(picker, { target = filepath })
                    Snacks.notify.info("Saved: " .. filename)
                  end,
                  desc = "Paste clipboard image",
                },
              },
            },
          },
        },
      },
    },
  },
}
