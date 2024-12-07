return {
  { "nvim-neotest/neotest-plenary" },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "fredrikaverpil/neotest-golang",
    },
    opts = {
      adapters = {
        "neotest-plenary",
        ["neotest-vitest"] = {},
        "neotest-golang",
      },
    },
  },
}
