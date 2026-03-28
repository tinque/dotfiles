vim.opt.scrolloff = 8
vim.opt.swapfile = false
vim.opt.undofile = true

-- Luarocks modules (tiktoken_core for CopilotChat)
package.cpath = package.cpath .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/lib/lua/5.1/?.so"

-- Disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
