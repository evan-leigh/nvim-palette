local M = {}

local lighten = require("palette.utils").lighten
local darken = require("palette.utils").darken

local autocmd = vim.api.nvim_create_autocmd

local fallback = {
  background = { "#000000", "#ffffff" },
  foreground = { "#ced2da", "#000000" },
  red = { "#E86671", "#000000" },
  green = { "#6B8E23", "#000000" },
  yellow = { "#D7AF5F", "#000000" },
  blue = { "#61AFEF", "#000000" },
  purple = { "#c792ea", "#000000" },
  accent = { "#61AFEF", "#000000" },
}

-- Create highight groups based on options
--
-- @param colors:table - Apply different highlighting based on options
M.setup = function(colors)

  local variant = require("palette.utils").get_variant()

  colors = colors or {}

  if variant == "dark" then
    variant = 1
  else
    variant = 2
  end

  local palette = colors[vim.g.colors_name] or colors["*"] or fallback

  for color in pairs(fallback) do
    if palette[color] == nil then
      palette[color] = fallback[color]
    end
  end

  local amount = 0

  if colors["*"] ~= nil
      and colors["*"] ~= nil
      and colors["*"].settings ~= nil
      and colors["*"].settings.darken ~= nil
  then
    amount = colors["*"].settings.darken
  end

  local generated = {}

  if variant == 1 then
    generated = {
      background_0 = lighten(palette.background[1], 0 + amount * -0.3),
      background_1 = lighten(palette.background[1], 25 + amount * -0.35),
      background_2 = lighten(palette.background[1], 30 + amount * -0.40),
      background_3 = lighten(palette.background[1], 35 + amount * -0.45),

      foreground_0 = darken(palette.foreground[1], 00),
      foreground_1 = darken(palette.foreground[1], 60),
      foreground_2 = darken(palette.foreground[1], 80),
      foreground_3 = darken(palette.foreground[1], 90),
    }
  else
    generated = {
      background_0 = darken(palette.background[2], 0 + amount * 0.35),
      background_1 = darken(palette.background[2], 10 + amount * 0.25),
      background_2 = darken(palette.background[2], 15 + amount * 0.20),
      background_3 = darken(palette.background[2], 40 + amount * 0.15),

      foreground_0 = lighten(palette.foreground[2], 00),
      foreground_1 = lighten(palette.foreground[2], 20),
      foreground_2 = lighten(palette.foreground[2], 40),
      foreground_3 = lighten(palette.foreground[2], 90),
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

  M.red    = palette["red"][variant]
  M.green  = palette["green"][variant]
  M.yellow = palette["yellow"][variant]
  M.blue   = palette["blue"][variant]
  M.purple = palette["purple"][variant]
  M.accent = palette["accent"][variant]

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
