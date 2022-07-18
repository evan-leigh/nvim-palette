local M = {}

-- FIX: Custom highlights aren't updated when changing theme.

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- stylua: ignore
local defaults = {
  colors = {
    ["*"] = {
      background = { "#1C1C1C", "#efefef" },
      foreground = { "#ced2da", "#383A42" },
      red        = { "#E86671", "#E45649" },
      green      = { "#6B8E23", "#50A14F" },
      yellow     = { "#D7AF5F", "#C18401" },
      blue       = { "#61AFEF", "#0184BC" },
      purple     = { "#c792ea", "#A626A4" },
      accent     = { "#61AFEF", "#0184BC" },

      lightness = 0,

      highlights = {},

      enable = true
    },
  },

  on_change = function() end,
}


--[[
  @param {table} 'highlights_tbl' The first table
  @return {function} applies highlight based off properties in highlights table 
]]
-- stylua: ignore
local function apply_highlights(highlights_tbl)
  for group_name, property in pairs(highlights_tbl) do
    if property.links then
      vim.api.nvim_command(string.format(
        "highlight! link %s %s",

        group_name,
        property.links))
    else
      vim.api.nvim_command(string.format(
        "highlight! %s guifg=%s guibg=%s guisp=%s gui=%s", group_name,

        property.fg or "none",
        property.bg or "none",
        property.sp or "none",
        property.gui or "none"))
    end
  end
end

--[[
  Gets the current configuration and applies highlights based off of it

  @param {table} 'options'
      -> {function} 'on_change' callback when colorscheme changes
      -> {table} 'colors' determines the editor's highlights 
  @return {function} 'apply_highlights'
]]
M.setup = function(options)
  options = vim.tbl_deep_extend("force", {}, defaults, options or {})

  -- Check if register function is being called
  M.register = function(register_options)
    local colors = register_options.colors
    local themes = vim.tbl_keys(colors)

    for _, theme in ipairs(themes) do
      if vim.g.colors_name == theme then
        options = vim.tbl_deep_extend("force", {}, options, register_options or {})
      end
    end
  end

  local theme = vim.g.colors_name

  local colors = options.colors
  if colors[vim.g.colors_name] == nil then
    theme = "*"
  end

  if colors[theme].highlights == nil and colors["*"].highlights then
    colors[theme].highlights = colors["*"].highlights
  end

  require("palette.colors").setup(colors[theme], colors[theme].lightness)
  require("palette.groups").setup(colors[theme].highlights)

  local highlights = require("palette.groups").groups

  if colors[theme].enable ~= false then
    apply_highlights(highlights)
  end

  pcall(vim.api.nvim_del_augroup_by_id, 7)
  local group = augroup("UpdateSetup", { clear = true })

  autocmd("ColorScheme", {
    desc = "Get nvim-palette config",
    group = group,
    callback = function()
      M.setup(options)
      vim.cmd("colorscheme " .. vim.g.colors_name)
    end,
  })

  options.on_change()
end

M.colors = require("palette.colors")

return M
