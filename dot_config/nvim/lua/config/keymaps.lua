-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function run_in_terminal(command)
  Snacks.terminal(command, { win = { position = "bottom", height = 0.3 }, env = { TERM = vim.env.TERM } })
end

vim.keymap.set("n", "<leader>gm", function()
  run_in_terminal([[zsh -lic 'gsync main']])
end, { desc = "Git sync main" })

vim.keymap.set("n", "<leader>gn", function()
  run_in_terminal([[zsh -lic 'gsync next']])
end, { desc = "Git sync next" })

vim.keymap.set("n", "<leader>gD", function()
  run_in_terminal([[zsh -lic 'gbgD']])
end, { desc = "Git delete gone branches" })

-- ── AZERTY-friendly navigation (avoid painful [ ] brackets) ──
vim.keymap.set("n", "<leader>dn", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })

vim.keymap.set("n", "<leader>dN", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev Diagnostic" })

-- ── Git stage/unstage current file ──
vim.keymap.set("n", "<leader>ga", function()
  vim.cmd("silent !git add " .. vim.fn.shellescape(vim.fn.expand("%")))
  vim.notify("Staged: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
end, { desc = "Git Add (stage file)" })

vim.keymap.set("n", "<leader>gu", function()
  vim.cmd("silent !git restore --staged " .. vim.fn.shellescape(vim.fn.expand("%")))
  vim.notify("Unstaged: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
end, { desc = "Git Unstage file" })
