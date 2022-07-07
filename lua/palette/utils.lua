local M = {}

M.get_variant = function()
  local variant
  for i, x in pairs(vim.opt.background) do
    if i == "_value" then
      if x == "light" then
        variant = "light"
      else
        variant = "dark"
      end
    end
  end
  return variant
end

M.darken = function(hex, amount)
  hex = hex:gsub("#", "")

  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)

  r = math.max(0, math.min(255, r - amount))
  g = math.max(0, math.min(255, g - amount))
  b = math.max(0, math.min(255, b - amount))

  return string.format("#%02x%02x%02x", r, g, b)
end

M.lighten = function(hex, amount)
  hex = hex:gsub("#", "")

  local r = tonumber(hex:sub(1, 2), 16)
  local g = tonumber(hex:sub(3, 4), 16)
  local b = tonumber(hex:sub(5, 6), 16)

  -- lighten rgb values
  r = math.max(0, math.min(255, r + amount))
  g = math.max(0, math.min(255, g + amount))
  b = math.max(0, math.min(255, b + amount))
  return string.format("#%02x%02x%02x", r, g, b)
end

-- Convert a hex color value to HSL
-- @param hex: The hex color value
-- @param h: Hue (0-360)
-- @param s: Saturation (0-1)
-- @param l: Lightness (0-1)
M.hex2hsl = function(hex)
  local r, g, b = M.hex2rgb(hex)
  return M.rgb2hsl(r, g, b)
end

-- Convert a HSL color value to hex
-- @param h: Hue (0-360)
-- @param s: Saturation (0-1)
-- @param l: Lightness (0-1)
-- @returns hex color value
M.hsl2hex = function(h, s, l)
  local r, g, b = M.hsl2rgb(h, s, l)
  return M.rgb2hex(r, g, b)
end

-- Desaturate or saturate a color by a given percentage
-- @param hex The hex color value
-- @param percent The percentage to desaturate or saturate the color.
--                Negative values desaturate the color, positive values saturate it
-- @return The hex color value
M.change_hex_saturation = function(hex, percent)
  local h, s, l = M.hex2hsl(hex)
  s = s + (percent / 100)
  if s > 1 then
    s = 1
  end
  if s < 0 then
    s = 0
  end
  return M.hsl2hex(h, s, l)
end

M.is_light = function(foreground, background, difference)
  foreground = foreground:gsub("#", "")
  background = background:gsub("#", "")

  local r = tonumber(foreground:sub(1, 2), 16)
  local g = tonumber(foreground:sub(3, 4), 16)
  local b = tonumber(foreground:sub(5, 6), 16)

  local r_input = tonumber(background:sub(1, 2), 16)
  local g_input = tonumber(background:sub(3, 4), 16)
  local b_input = tonumber(background:sub(5, 6), 16)

  local brightness = (r + g + b) / 3

  if brightness > (r_input + g_input + b_input) / 3 then
    return M.lighten(foreground, difference * 2)
  else
    return M.darken(foreground, difference)
  end
end

return M
