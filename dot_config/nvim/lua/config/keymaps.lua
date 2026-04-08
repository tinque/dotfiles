-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function run_in_terminal(command)
  Snacks.terminal(command, { win = { position = "bottom", height = 0.3 }, env = { TERM = vim.env.TERM } })
end

vim.keymap.set("n", "<leader>gm", function()
  run_in_terminal([[zsh -lc 'gsync main']])
end, { desc = "Git sync main" })

vim.keymap.set("n", "<leader>gn", function()
  run_in_terminal([[zsh -lc 'gsync next']])
end, { desc = "Git sync next" })

vim.keymap.set("n", "<leader>gD", function()
  run_in_terminal([[zsh -lc 'gbgD']])
end, { desc = "Git delete gone branches" })

-- ── AZERTY-friendly navigation (avoid painful [ ] brackets) ──
vim.keymap.set("n", "<leader>dn", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })

vim.keymap.set("n", "<leader>dN", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev Diagnostic" })
