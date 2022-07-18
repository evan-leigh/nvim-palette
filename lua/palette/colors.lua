local M = {}

local lighten = require("palette.utils").lighten
local darken = require("palette.utils").darken
local saturate = require("palette.utils").saturate

-- stylua: ignore
local fallback = {
  background = { "#000000", "#efefef" },
  foreground = { "#aaaaaa", "#000000" },
  red        = { "#E86671", "#000000" },
  green      = { "#6B8E23", "#000000" },
  yellow     = { "#D7AF5F", "#000000" },
  blue       = { "#61AFEF", "#000000" },
  purple     = { "#c792ea", "#000000" },
  accent     = { "#61AFEF", "#000000" },
}

-- Create highight groups based on options
--
-- @param colors:table - Apply different highlighting based on options
M.setup = function(colors, lightness)
  colors = colors or {}
  lightness = lightness or 0

  local variant = require("palette.utils").get_variant()

  if variant == "dark" then
    variant = 1
  else
    variant = 2
  end

  for color, value in pairs(fallback) do
    if colors[color] == nil then
      colors[color] = fallback[color]
      colors[value] = fallback[value]
    end
  end

  local generated = {}

  if variant == 1 then
    generated = {
      background_0 = lighten(colors.background[1], lightness + 00),
      background_1 = lighten(colors.background[1], lightness + 05),
      background_2 = lighten(colors.background[1], lightness + 10),
      background_3 = lighten(colors.background[1], lightness + 20),

      foreground_0 = darken(colors.foreground[1], 00),
      foreground_1 = darken(colors.foreground[1], 20),
      foreground_2 = darken(colors.foreground[1], 30),
      foreground_3 = darken(colors.foreground[1], 50),
      foreground_4 = darken(colors.foreground[1], 90),
    }
  else
    generated = {
      background_0 = darken(colors.background[2], lightness + 00),
      background_1 = darken(colors.background[2], lightness + 10),
      background_2 = darken(colors.background[2], lightness + 20),
      background_3 = darken(colors.background[2], lightness + 30),

      foreground_0 = lighten(colors.foreground[2], 00),
      foreground_1 = lighten(colors.foreground[2], 20),
      foreground_2 = lighten(colors.foreground[2], 40),
      foreground_3 = lighten(colors.foreground[2], 90),
      foreground_4 = lighten(colors.foreground[2], 110),
    }
  end

  M.background_0 = generated.background_0
  M.background_1 = generated.background_1
  M.background_2 = generated.background_2
  M.background_3 = generated.background_3

  M.foreground_0 = generated.foreground_0
  M.foreground_1 = generated.foreground_1
  M.foreground_2 = generated.foreground_2
  M.foreground_3 = generated.foreground_3
  M.foreground_4 = generated.foreground_4

  M.red = colors["red"][variant]
  M.green = colors["green"][variant]
  M.yellow = colors["yellow"][variant]
  M.blue = colors["blue"][variant]
  M.purple = colors["purple"][variant]
  M.accent = colors["accent"][variant]

  M.none = "none"
end

return M
