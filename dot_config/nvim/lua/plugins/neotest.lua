return {
  { import = "lazyvim.plugins.extras.test.core" },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "npx jest",
          -- Find the nearest jest.config.ts walking up from the test file
          jestConfigFile = function(file)
            local dir = vim.fn.fnamemodify(file, ":h")
            while dir ~= "/" do
              local config = dir .. "/jest.config.ts"
              if vim.fn.filereadable(config) == 1 then
                return config
              end
              dir = vim.fn.fnamemodify(dir, ":h")
            end
            return vim.fn.getcwd() .. "/jest.config.ts"
          end,
          -- cwd = monorepo root (preset paths are relative to it)
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
      },
    },
  },
}
