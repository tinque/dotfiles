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
                  function(self)
                    if vim.fn.executable("pngpaste") ~= 1 then
                      Snacks.notify.error("pngpaste not found. Install with: brew install pngpaste")
                      return
                    end

                    vim.fn.system("pngpaste -b 2>&1")
                    if vim.v.shell_error ~= 0 then
                      Snacks.notify.warn("No image in clipboard")
                      return
                    end

                    local pickers = Snacks.picker.get({ source = "explorer" })
                    local picker = pickers and pickers[1]
                    if not picker then
                      Snacks.notify.error("Explorer picker not found")
                      return
                    end

                    local dir = picker:dir()
                    local item = picker:current()
                    if not dir and item and item.dir then
                      dir = item.file
                    elseif not dir and item then
                      dir = vim.fs.dirname(item.file)
                    end
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
