-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function run_in_terminal(command)
  Snacks.terminal(command, { win = { position = "bottom", height = 0.3 }, env = { TERM = vim.env.TERM } })
end

vim.keymap.set("n", "<leader>gm", function()
  run_in_terminal([[zsh -lc 'source ~/.zshrc && gsync main']])
end, { desc = "Git sync main" })

vim.keymap.set("n", "<leader>gn", function()
  run_in_terminal([[zsh -lc 'source ~/.zshrc && gsync next']])
end, { desc = "Git sync next" })

vim.keymap.set("n", "<leader>gD", function()
  run_in_terminal([[zsh -lc 'source ~/.zshrc && gbgD']])
end, { desc = "Git delete gone branches" })
