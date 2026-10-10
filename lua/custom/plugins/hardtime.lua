-- hardtime.nvim
-- https://github.com/m4xshen/hardtime.nvim
--
-- Hints when you use a slow key pattern (e.g. `jjjj` instead of `4j`,
-- `dw` + `i` instead of `cw`) and blocks spamming hjkl/arrow keys.
-- :Hardtime toggle | :Hardtime report (your most common bad habits)

return {
  'm4xshen/hardtime.nvim',
  lazy = false,
  dependencies = { 'MunifTanjim/nui.nvim' },
  opts = {},
}
