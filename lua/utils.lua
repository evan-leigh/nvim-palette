local M = {}

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
