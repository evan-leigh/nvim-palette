local M = {}

M.get_variant = function()
  local variant
  for i, x in pairs(vim.opt.background) do
    if i == "_value" then
      if x == "light" then
        variant = 2
      else
        variant = 1
      end
    end
  end
  return variant
end

M.hex2rgb = function(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

M.darken = function(hex, amount)
  hex = hex:gsub("#", "")
  local r, g, b = M.hex2rgb(hex)
  r = math.max(0, math.min(255, r - amount))
  g = math.max(0, math.min(255, g - amount))
  b = math.max(0, math.min(255, b - amount))
  return string.format("#%02x%02x%02x", r, g, b)
end

M.lighten = function(hex, amount)
  hex = hex:gsub("#", "")
  local r, g, b = M.hex2rgb(hex)
  r = math.max(0, math.min(255, r + amount))
  g = math.max(0, math.min(255, g + amount))
  b = math.max(0, math.min(255, b + amount))
  return string.format("#%02x%02x%02x", r, g, b)
end

M.blend = function(color1, color2, percent)
  local r1, g1, b1 = M.hex2rgb(color1)
  local r2, g2, b2 = M.hex2rgb(color2)
  local r = math.floor(r1 + (r2 - r1) * percent)
  local g = math.floor(g1 + (g2 - g1) * percent)
  local b = math.floor(b1 + (b2 - b1) * percent)

  return string.format("#%02x%02x%02x", r, g, b)
end

M.check_contrast = function(foreground, background, difference)
  foreground = foreground:gsub("#", "")
  background = background:gsub("#", "")
  local r, g, b = M.hex2rgb(foreground)
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
