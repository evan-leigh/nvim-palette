local M = {}

local lighten = require("palette.utils").lighten
local darken = require("palette.utils").darken

local autocmd = vim.api.nvim_create_autocmd

local fallback = {
  dark = {
    background = "#000000",
    foreground = "#ced2da",
    red = "#E86671",
    green = "#6B8E23",
    yellow = "#D7AF5F",
    blue = "#61AFEF",
    purple = "#c792ea",
    accent = "#61AFEF",
  },

  light = {
    background = "#E1E1E1",
    foreground = "#444444",
    red = "#d70000",
    green = "#008700",
    yellow = "#d7af5f",
    blue = "#0087af",
    purple = "#8700af",
    accent = "#61AFEF",
  },
}

local variant = require("palette.utils").get_variant()

-- Create highight groups based on options
--
-- @param colors:table - Apply different highlighting based on options
M.setup = function(colors)

  if colors == nil then
    colors = {}
  end

  local palette = colors[vim.g.colors_name]

  if palette == nil then
    if colors["*"][variant] then
      palette = colors["*"]
    else
      palette = fallback
    end
  end

  if palette.dark == nil then
    palette.dark = fallback.dark
  end

  if palette.light == nil then
    palette.light = fallback.light
  end

  for color in pairs(fallback[variant]) do
    if palette[variant][color] == nil then
      palette[variant][color] = fallback[variant][color]
    end
  end

  local amount = 1

  if colors["*"] ~= nil
      and colors["*"] ~= nil
      and colors["*"].settings ~= nil
      and colors["*"].settings.darken ~= nil
  then
    amount = colors["*"].settings.darken
  end

  if palette.settings ~= nil then
    amount = palette.settings.darken
  end

  local generated = {
    dark = {
      background_0 = lighten(palette.dark.background, 0 + amount * -0.3),
      background_1 = lighten(palette.dark.background, 5 + amount * -0.35),
      background_2 = lighten(palette.dark.background, 15 + amount * -0.40),
      background_3 = lighten(palette.dark.background, 17.5 + amount * -0.45),

      foreground_0 = darken(palette.dark.foreground, 00),
      foreground_1 = darken(palette.dark.foreground, 60),
      foreground_2 = darken(palette.dark.foreground, 80),
      foreground_3 = darken(palette.dark.foreground, 90),
    },

    light = {
      background_0 = darken(palette.light.background, 0 + amount * 0.35),
      background_1 = darken(palette.light.background, 10 + amount * 0.25),
      background_2 = darken(palette.light.background, 15 + amount * 0.20),
      background_3 = darken(palette.light.background, 40 + amount * 0.15),

      foreground_0 = lighten(palette.light.foreground, 00),
      foreground_1 = lighten(palette.light.foreground, 20),
      foreground_2 = lighten(palette.light.foreground, 40),
      foreground_3 = lighten(palette.light.foreground, 90),

      background = palette.light.background,
    },
  }

  M.background_0 = generated[variant].background_0
  M.background_1 = generated[variant].background_1
  M.background_2 = generated[variant].background_2
  M.background_3 = generated[variant].background_3

  M.foreground_0 = generated[variant].foreground_0
  M.foreground_1 = generated[variant].foreground_1
  M.foreground_2 = generated[variant].foreground_2
  M.foreground_3 = generated[variant].foreground_3

  local function validate_color(color)
    -- Checks if color exist in palette
    if palette[variant][color] == nil then
      -- I want a better way of doing this
      if colors["*"] ~= nil and colors["*"][variant] ~= nil and colors["*"][variant][color] ~= nil then
        return colors["*"][variant][color]
      else
        return fallback[variant][color]
      end
    end

    return palette[variant][color]
  end

  M.red = validate_color("red")
  M.green = validate_color("green")
  M.yellow = validate_color("yellow")
  M.blue = validate_color("blue")
  M.purple = validate_color("purple")
  M.accent = validate_color("accent")
  M.none = "none"

  pcall(vim.api.nvim_del_augroup_by_id, 7)
  local group = vim.api.nvim_create_augroup("UpdateColors", { clear = true })

  autocmd("ColorScheme", {
    desc = "Reset highlights on ColorScheme",
    group = group,
    callback = function()
      M.setup(colors)
    end,
  })
end

return M
