return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      -- Disable blame line; use <leader>gb (snacks.git.blame_line) instead
      { "<leader>ghb", false },
      -- AZERTY-friendly hunk navigation (avoids [ ] brackets)
      {
        "<leader>hn",
        function()
          require("gitsigns").nav_hunk("next")
        end,
        desc = "Next Hunk",
      },
      {
        "<leader>hp",
        function()
          require("gitsigns").nav_hunk("prev")
        end,
        desc = "Prev Hunk",
      },
    },
  },
}
