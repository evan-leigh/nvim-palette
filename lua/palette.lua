local M = {}

local autocmd = vim.api.nvim_create_autocmd

-- Checks to see if value is exists, if not, returns default value
--
-- @param {any} value - The value to check
-- @param {any} default - The default value to return
-- @return {any} - The value or default value
local function validate(value, default)
  if value == nil then
    return default
  else
    return value
  end
end

local user_configuration

-- @param {table} highlights_tbl - The first table
-- @return {function} - applies highlight based off properties in highlights table
local function apply_highlights(highlights_tbl)
  for group_name, property in pairs(highlights_tbl) do
    if property.links == nil then
      local highlight = string.format(
        "highlight! %s guifg=%s guibg=%s guisp=%s gui=%s", group_name,

        property.fg or "none",
        property.bg or "none",
        property.sp or "none",
        property.gui or "none")

      vim.api.nvim_command(highlight)
    else
      local highlight = string.format(
        "highlight! link %s %s",

        group_name,
        property.links)

      vim.api.nvim_command(highlight)
    end
  end
end

M.setup = function(options)

  if options == nil then
    options = {}
  end

  local config = {
    on_change = validate(options.on_change, function() end),
  }

  user_configuration = options

  require("palette.colors").setup(options.colors)

  local user_highlighlights

  if options.colors[vim.g.colors_name] ~= nil then
    user_highlighlights = options.colors[vim.g.colors_name].highlights
  else
    user_highlighlights = options.colors["*"].highlights
  end

  require("palette.groups").setup(user_highlighlights or {})

  local highlights = require("palette.groups").highlights

  apply_highlights(highlights)

  pcall(vim.api.nvim_del_augroup_by_id, 7)
  local group = vim.api.nvim_create_augroup("UpdateSetup", { clear = true })

  autocmd("ColorScheme", {
    desc = "Reset highlights on ColorScheme",
    group = group,
    callback = function()
      M.setup(user_configuration)
      -- M.custom_highlights(user_highlights)
    end,
  })
  config.on_change()
end

return M
