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

-- Merges two tables together
--
-- @param {table} tbl_1 - The first table
-- @param {table} tbl_2 - The second table
-- @return {table} - The merged table
local function add_highlights(tbl_1, tbl_2)
  for k, v in pairs(tbl_1) do
    tbl_2[k] = v
  end
end

local user_configuration
local user_highlights

local variant = require("palette.utils").get_variant()

local function apply_highlights(highlights_tbl)
  for group_name, property in pairs(highlights_tbl) do
    if property.links == nil then
      local highlight = string.format(
        "highlight %s guifg=%s guibg=%s guisp=%s gui=%s", group_name,

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

M.custom_highlights = function(highlights)
  if highlights == nil then
    return
  end

  if highlights["*"][variant] == nil or highlights["*"] == nil then
    return
  end

  user_highlights = highlights

  local custom_highlights = {}

  add_highlights(highlights["*"][variant], custom_highlights)

  for key in pairs(highlights) do
    if key == vim.g.colors_name then
      add_highlights(highlights[vim.g.colors_name][variant], custom_highlights)
    end
  end

  apply_highlights(custom_highlights)
end

M.setup = function(options)

  if options == nil then
    options = {}
  end

  local config = {
    on_change = validate(options.on_change, function() end),
  }

  user_configuration = options

  M.colors = require("palette.colors")
  require("palette.groups").setup()

  local highlights = require("palette.groups").highlights

  apply_highlights(highlights)

  pcall(vim.api.nvim_del_augroup_by_id, 7)
  local group = vim.api.nvim_create_augroup("UpdateSetup", { clear = true })

  autocmd("ColorScheme", {
    desc = "Reset highlights on ColorScheme",
    group = group,
    callback = function()
      M.setup(user_configuration)
      M.custom_highlights(user_highlights)
    end,
  })
  config.on_change()
end

return M
