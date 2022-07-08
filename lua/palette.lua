local M = {}

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local defaults = {

  colors = {
    ["*"] = { --      Dark       Light
      background = { "#1C1C1C", "#ffffff" },
      foreground = { "#ced2da", "#ffffff" },
      red        = { "#E86671", "#000000" },
      green      = { "#6B8E23", "#000000" },
      yellow     = { "#D7AF5F", "#000000" },
      blue       = { "#61AFEF", "#000000" },
      purple     = { "#c792ea", "#000000" },
      accent     = { "#61AFEF", "#000000" },

      lightness = 0,

      highlights = {}
    },
  },

  on_change = function() end,
}

-- local user_configuration

-- @param {table} highlights_tbl - The first table
-- @return {function} - applies highlight based off properties in highlights table
local function apply_highlights(highlights_tbl)
  for group_name, properties in pairs(highlights_tbl) do
    if properties.links ~= nil then
      vim.api.nvim_command(string.format(
        "highlight! link %s %s",

        group_name,
        properties.links))
    else
      vim.api.nvim_command(string.format(
        "highlight! %s guifg=%s guibg=%s guisp=%s gui=%s", group_name,

        properties.fg or "none",
        properties.bg or "none",
        properties.sp or "none",
        properties.gui or "none"))
    end
  end
end

M.setup = function(options)

  options = vim.tbl_deep_extend("force", {}, defaults, options or {})

  local theme = vim.g.colors_name
  local colors = options.colors

  if options.colors[vim.g.colors_name] == nil then
    theme = "*"
  end

  -- If no highlights exist in [vim.g.colors_name] table, then use the ["*"] highlights
  if colors[theme].highlights == nil then
    if colors["*"].highlights ~= nil then
      colors[theme].highlights = colors["*"].highlights
    end
  end

  require("palette.colors").setup(colors, colors[theme].lightness)
  require("palette.groups").setup(colors[theme].highlights)

  local highlights = require("palette.groups").groups

  apply_highlights(highlights)

  pcall(vim.api.nvim_del_augroup_by_id, 7)
  local group = augroup("UpdateSetup", { clear = true })

  autocmd("ColorScheme", {
    desc = "Reset highlights on ColorScheme",
    group = group,
    callback = function()
      M.setup(options)
    end,
  })
  options.on_change()
end

return M
