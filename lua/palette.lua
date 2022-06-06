-- FEATURES:
-- ✅ Add ability to add custom highlights

-- FIX BUGS:
-- ✅ Prevent au command from duplicating itself
-- ✅ Recoginize "vim.g" colors on start up

-- vim.g variables are carried over from previous theme

-- when themes writen in lua are used at VimEnter
-- vim themes have no syntax highlighting

-- when themes writen in lua arent used at VimEnter
-- when using vim.g values in custom, vim.g values arent being used from the custom colors

local M = {}

local darken = require("palette.utils").darken
local lighten = require("palette.utils").lighten
local is_light = require("palette.utils").is_light
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

local fallback = {
  dark = {
    background = "#111111",
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

local variant -- @string `vim.opt.background` value
local palette -- @string colorscheme thats set

for i, x in pairs(vim.opt.background) do
  if i == "_value" then
    if x == "light" then
      variant = "light"
    else
      variant = "dark"
    end
  end
end
-- TODO:
-- Ability to add highlights without overriding any

local function execute_highlights(key, value)
  local hl = key

  -- local function vim_highlights(highlights)
  --   for group_name, group_settings in pairs(highlights) do
  --     vim.api.nvim_command(
  --       string.format(
  --         "highlight %s guifg=%s guibg=%s guisp=%s gui=%s",
  --         group_name,
  --         group_settings.fg or "none",
  --         group_settings.bg or "none",
  --         group_settings.sp or "none",
  --         group_settings.fmt or "none"
  --       )
  --     )
  --   end
  -- end

  if value.links == nil then
    if value.bg ~= nil then
      hl = hl .. " guibg=" .. value.bg
    end

    if value.fg ~= nil then
      hl = hl .. " guifg=" .. value.fg
    end

    if value.gui ~= nil then
      hl = hl .. " gui=" .. value.gui
    end

    if value.guisp ~= nil then
      hl = hl .. " guisp=" .. value.guisp
    end

    vim.cmd("hi " .. hl)
  else
    vim.cmd("hi! link " .. hl .. " " .. value.links)
  end
end

local function apply_highlights(highlights_tbl)
  for key, value in pairs(highlights_tbl) do
    execute_highlights(key, value)
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

-- This will update the palette and highlights
local function update_colors()
  -- Delete augroups so that their not duplicated
  pcall(vim.api.nvim_del_augroup_by_id, 7)
  local group = vim.api.nvim_create_augroup("UpdateColors", { clear = true })

  autocmd("ColorScheme", {
    desc = "Reset highlights on save",
    group = group,
    callback = function()
      M.setup(user_configuration)
      M.custom_highlights(user_highlights)
    end,
  })
end

local generated

-- Create highight groups based on options
--
-- @param options:table - Apply different highlighting based on options
M.setup = function(options)
  if options == nil then
    options = {}
  end

  local fn = vim.fn

  local background = fn.synIDattr(fn.synIDtrans(fn.hlID("Normal")), "bg#")

  user_configuration = options

  local config = {
    -- background = validate(options.background, true),
    popup_menu = validate(options.popup_menu, true),
    sign_column = validate(options.sign_column, false),
    transparent = validate(options.transparent, false),
    on_change = validate(options.on_change, function() end),
    lualine = validate(options.lualine, true),
    variant = validate(options.variant, nil),
  }

  palette = options[vim.g.colors_name]
  -- local user_variant = options.variant

  if palette == nil then
    if options then
      palette = options
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
    if palette[color] == nil then
      palette[color] = fallback[variant][color]
    end
  end

  local amount = 1

  if
    options["*"] ~= nil
    and options["*"] ~= nil
    and options["*"].settings ~= nil
    and options["*"].settings.darken ~= nil
  then
    amount = options["*"].settings.darken
  end

  if palette.settings ~= nil then
    amount = palette.settings.darken
  end

  generated = {
    dark = {
      background_0 = lighten(palette.dark.background, -1 + amount * -0.3),
      background_1 = lighten(palette.dark.background, 10 + amount * -0.35),
      background_2 = lighten(palette.dark.background, 15 + amount * -0.40),
      background_3 = lighten(palette.dark.background, 17.5 + amount * -0.45),

      foreground_0 = darken(palette.dark.foreground, 00),
      foreground_1 = darken(palette.dark.foreground, 60),
      foreground_2 = darken(palette.dark.foreground, 80),
      foreground_3 = darken(palette.dark.foreground, 90),
    },

    light = {
      background_0 = darken(palette.light.background, 1 + amount * 0.35),
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

  local background_0 = generated.dark.background_0
  local background_1 = generated.dark.background_1
  local background_2 = generated.dark.background_2
  local background_3 = generated.dark.background_3

  local foreground_0 = generated.dark.foreground_0
  local foreground_1 = generated.dark.foreground_1
  local foreground_2 = generated.dark.foreground_2
  local foreground_3 = generated.dark.foreground_3

  if variant == "light" then
    background_0 = generated.light.background_0
    background_1 = generated.light.background_1
    background_2 = generated.light.background_2
    background_3 = generated.light.background_3

    foreground_0 = generated.light.foreground_0
    foreground_1 = generated.light.foreground_1
    foreground_2 = generated.light.foreground_2
    foreground_3 = generated.light.foreground_3
  end

  -- If the color doens't exist in palette, if the color exists in ["*"][variant] then use it, else the fallback value
  local function validate_color(color)
    -- Checks if color exist in palette
    if palette[variant][color] == nil then
      if options["*"][variant] ~= nil and options["*"][variant][color] ~= nil then
        return options["*"][variant][color]
      else
        return fallback[variant][color]
      end
    end

    return palette[variant][color]
  end

  -- Core
  local red = validate_color("red")
  local green = validate_color("green")
  local yellow = validate_color("yellow")
  local blue = validate_color("blue")
  local purple = validate_color("purple")
  local accent = validate_color("accent")
  local none = "none"

  vim.g.background_0 = background_0
  vim.g.background_1 = background_1
  vim.g.background_2 = background_2
  vim.g.background_3 = background_3

  vim.g.foreground_0 = foreground_0
  vim.g.foreground_1 = foreground_1
  vim.g.foreground_2 = foreground_2
  vim.g.foreground_3 = foreground_3

  vim.g.accent = accent
  vim.g.red = red
  vim.g.green = green
  vim.g.yellow = yellow
  vim.g.blue = blue
  vim.g.purple = purple

  local highlights = {
    -- Built-in: Statusline
    Statusline = { bg = none, fg = foreground_2, gui = none },
    StatuslineNC = { bg = none, fg = foreground_3, gui = none },

    -- Built-in:
    CursorLineNr = { bg = background_3 },
    LineNr = { bg = none, fg = foreground_3 },
    SignColumn = { bg = none },
    VertSplit = { bg = background_1, fg = background_1 },

    NormalFloat = { bg = background_1, fg = foreground_1 },
    FloatBorder = { bg = background_1, fg = foreground_3 },

    -- nvim-tree
    -- https://githubom/kyazdani42/nvim-tree

    -- NvimTree: Background
    NvimTreeNormal = { bg = background_1, fg = foreground_2 },
    NvimTreeNormalNC = { bg = background_1, fg = foreground_2 },
    NvimTreeEndOfBuffer = { bg = background_1, fg = background_1 },
    NvimTreeVertSplit = { bg = background_1, fg = background_1 },
    NvimTreeStatusline = { bg = background_1, fg = background_1 },
    NvimTreeStatuslineNC = { bg = background_1, fg = background_1 },

    -- NvimTree: Icons
    NvimTreeGitDelete = { fg = red },
    NvimTreeFileDirty = { fg = yellow },
    NvimTreeGitNew = { fg = green },
    NvimTreeSpecialFile = { fg = purple },
    NvimTreeGitDirty = { fg = yellow },
    NvimTreeGitStaged = { fg = green },
    NvimTreeFolderIcon = { fg = foreground_3 },
    NvimTreeFolderName = { fg = blue },
    NvimTreeOpenedFolderName = { fg = blue, bg = none },
    NvimTreeEmptyFolderName = { fg = blue },
    NvimTreeRootFolder = { fg = foreground_2 },

    -- NvimTree: Other
    NvimTreeIndentMarker = { fg = foreground_3 },

    -- telescopevim
    -- https://githubom/nvim-telescope/telescopevim

    -- Telescope: Preview
    TelescopePreviewBorder = { links = "FloatBorder" },
    TelescopePreviewTitle = { bg = none, fg = foreground_3 },
    TelescopePreviewNormal = { links = "NormalFloat" },

    -- Telescope: Results
    TelescopeResultsTitle = { fg = foreground_3 },
    TelescopeResultsBorder = { links = "FloatBorder" },
    TelescopeResultsNormal = { links = "NormalFloat" },

    -- Telescope: Prompt
    TelescopePromptBorder = { links = "FloatBorder" },
    TelescopePromptNormal = { links = "NormalFloat" },
    TelescopePromptPrefix = { fg = accent },
    TelescopePromptTitle = { bg = none, fg = foreground_3 },
    TelescopePromptCounter = { fg = accent },

    -- Telescope: Other
    TelescopeSelection = { links = "PmenuSel" },
    TelescopeMatching = { fg = none, gui = "underline" },

    -- which-keyvim
    -- https://githubom/folke/which-key

    WhichKeyFloat = { links = "NormalFloat" },
    WhichKeyDesc = { fg = foreground_1, bg = none },
    WhichKeyGroup = { fg = foreground_2, bg = none },
    WhichKeySeparator = { fg = background_3, bg = none },
    WhichKey = { fg = accent, gui = "bold", bg = none },

    -- gitsignsvim
    -- https://githubom/lewis6991/gitsignsvim

    -- GitSigns: Added
    GitSignsAdd = { fg = green, bg = none },
    GitSignsAddLn = { fg = green, bg = none },
    GitSignsAddNr = { fg = green, bg = none },
    GitGutterAdd = { fg = green, bg = none },

    -- GitSigns: Changed
    GitSignsChangeLn = { fg = blue, bg = none },
    GitSignsChangeNr = { fg = blue, bg = none },
    GitSignsChange = { fg = blue, bg = none },

    -- GitSigns: Deleted
    GitSignsDelete = { fg = red, bg = none },
    GitSignsDeleteLn = { fg = red, bg = none },
    GitSignsDeleteNr = { fg = red, bg = none },
    GitGutterDelete = { fg = red, bg = none },

    -- copilot

    CopilotSuggestion = { fg = foreground_3, bg = none },

    -- indent-blanklinevim
    -- https://githubom/lukas-reineke/indent-blanklinevim

    IndentBlankLineChar = { fg = lighten(background_3, 15) },
    IndentBlankLineContextChar = { fg = lighten(background_3, variant == "light" and 0 or 40) },
    IndentBlankLineSpaceChar = { bg = none },
    IndentBlankLineSpaceCharBlankline = { bg = none },

    -- Built-in: Error
    DiagnosticError = { fg = red, bg = none },
    DiagnosticSignError = { fg = red, bg = none },
    DiagnosticUnderlineError = { guisp = red, gui = "undercurl" },
    -- DiagnosticFloatingError = { bg = none, fg = foreground_2 },

    -- Built-in: Warning
    DiagnosticWarn = { fg = yellow, bg = none },
    DiagnosticSignWarn = { fg = yellow, bg = none },
    DiagnosticUnderlineWarn = { guisp = yellow, gui = "undercurl" },
    -- DiagnosticFloatingWarn = { bg = none, fg = foreground_2 },

    -- Built-in: Info
    DiagnosticInfo = { fg = purple, bg = none },
    DiagnosticSignInfo = { fg = purple, bg = none },
    DiagnosticUnderlineInfo = { guisp = purple, gui = "undercurl" },
    -- DiagnosticFloatingInfo = { bg = none, fg = foreground_2 },

    -- Built-in: Hint
    DiagnosticHint = { fg = blue, bg = none },
    DiagnosticSignHint = { fg = blue, bg = none },
    DiagnosticUnderlineHint = { guisp = blue, gui = "undercurl" },
    -- DiagnosticFloatingHint = { bg = none, fg = foreground_2 },

    -- nvim-lspconfig
    -- https://githubom/neovim/nvim-lspconfig

    -- LSP Config: Error
    LspDiagnosticsDefaultError = { fg = red },
    LspDiagnosticsSignError = { fg = red },
    LspDiagnosticsError = { fg = red },
    LspDiagnosticsUnderlineError = { guisp = red, gui = "undercurl" },

    -- LSP Config: Warning
    LspDiagnosticsDefaultWarn = { fg = yellow },
    LspDiagnosticsSignWarn = { fg = yellow },
    LspDiagnosticsWarn = { fg = yellow },
    LspDiagnosticsUnderlineWarn = { guisp = yellow, gui = "undercurl" },

    -- LSP Config: Hint
    LspDiagnosticsDefaultHint = { fg = purple },
    LspDiagnosticsSignHint = { fg = purple },
    LspDiagnosticsHint = { fg = purple },
    LspDiagnosticsUnderlineHint = { guisp = purple, gui = "undercurl" },

    -- LSP Config: Info
    LspDiagnosticsDefaultInfo = { fg = blue },
    LspDiagnosticsSignInfo = { fg = blue },
    LspDiagnosticsInfo = { fg = blue },
    LspDiagnosticsUnderlineInfo = { guisp = blue, gui = "undercurl" },
  }

  local transparent = {
    Normal = { bg = "none" },
    NormalNC = { bg = "none" },
    EndOfBuffer = { bg = "none" },
    CursorLine = { bg = "none" },
    CursorLineNr = { bg = "none" },
    SignColumn = { bg = "none" },
    FoldColumn = { bg = "none" },
    LineNr = { bg = "none" },
  }

  local background = {
    Normal = { bg = background_0 },
    NormalNC = { bg = background_0 },
    EndOfBuffer = { bg = background_0 },
    CusorLine = { bg = background_0 },
  }

  local popup_menu = {
    -- Builtin: PopupMenu
    Pmenu = { bg = background_1, fg = foreground_1 },
    PmenuSel = { bg = lighten(background_3, 8), gui = "none", fg = none },
    PmenuThumb = { bg = lighten(background_3, 60) },
    PmenuSbar = { bg = lighten(background_3, 60) },
    PmenuThumbSel = { bg = accent },

    -- nvim-cmp
    -- https://githubom/hrsh7th/nvim-cmp

    -- Icons
    CmpItemAbbr = { fg = foreground_2 },
    CmpItemMenu = { fg = foreground_3 },
    CmpItemAbbrMatch = { fg = foreground_0, bg = none, gui = none },
    CmpItemAbbrMatchFuzzy = { fg = accent, gui = "underline" },
    CmpItemKindKind = { fg = accent },
    CmpItemKindClass = { fg = green },
    CmpItemKindConstructor = { fg = green },
    CmpItemKindField = { fg = blue },
    CmpItemKindFile = { fg = yellow },
    CmpItemKindFolder = { fg = yellow },
    CmpItemKindFunction = { fg = purple },
    CmpItemKindInterface = { fg = blue },
    CmpItemKindKeyword = { fg = blue },
    CmpItemKindMethod = { fg = purple },
    CmpItemKindSnippet = { fg = yellow },
    CmpItemKindText = { fg = yellow },
    CmpItemKindValue = { fg = blue },
    CmpItemKindVariable = { fg = purple },
    CmpItemAbbrDepricated = { bg = foreground_2, gui = "strikethrough" },
  }

  local sign_column = {
    -- Builtin: SignColumn
    LineNr = { bg = background_1, fg = foreground_2 },
    VertSplit = { bg = background_1, fg = background_1 },
    SignColumn = { bg = background_1 },
    FoldColumn = { bg = background_1 },

    -- gitsigns.nvim
    GitSignsAdd = { bg = background_1, fg = green },
    GitSignsDelete = { bg = background_1, fg = red },
    GitSignsChange = { bg = background_1, fg = blue },
    GitSignsAddNr = { bg = background_1, fg = green },
    GitSignsDeleteNr = { bg = background_1, fg = red },
    GitSignsChangeNr = { bg = background_1, fg = blue },

    -- nvim-lspconfig
    DiagnosticSignError = { bg = background_1, fg = red },
    DiagnosticSignWarn = { bg = background_1, fg = yellow },
    DiagnosticSignInfo = { bg = background_1, fg = purple },
    DiagnosticSignHint = { bg = background_1, fg = blue },
  }

  local lualine_highlights

  if variant == "light" then
    lualine_highlights = {
      normal = {
        a = { fg = is_light(foreground_3, accent, 140), bg = accent },
        b = { fg = foreground_1, bg = background_3 },
        c = { fg = foreground_3, bg = darken(background_0, 7) },
        x = { fg = foreground_3, bg = darken(background_0, 7) },
        y = { fg = foreground_1, bg = background_3 },
        z = { fg = is_light(foreground_3, accent, 140), bg = accent },
      },

      inactive = {
        a = { fg = foreground_3, bg = background_1 },
        b = { fg = foreground_3, bg = background_1 },
        c = { fg = foreground_1, bg = background_1 },
        y = { fg = foreground_1, bg = background_1 },
        z = { fg = foreground_3, bg = background_1 },
      },

      insert = {
        a = { fg = is_light(foreground_3, green, 140), bg = green },
        x = { fg = foreground_1, bg = background_3 },
      },

      command = {
        a = { fg = is_light(foreground_3, yellow, 140), bg = yellow },
        x = { fg = foreground_1, bg = background_3 },
      },

      visual = {
        a = { fg = is_light(foreground_3, purple, 140), bg = purple },
        x = { fg = foreground_1, bg = background_3 },
      },

      replace = {
        a = { fg = is_light(foreground_3, red, 140), bg = red },
        x = { fg = foreground_1, bg = background_3 },
      },
    }
  elseif variant == "dark" then
    lualine_highlights = {
      normal = {
        a = { fg = is_light(foreground_3, accent, 140), bg = accent },
        b = { fg = foreground_1, bg = background_2 },
        c = { fg = foreground_3, bg = darken(background_0, 7) },
        y = { fg = foreground_3, bg = darken(background_0, 7) },
        x = { fg = foreground_1, bg = background_2 },
        z = { fg = is_light(foreground_3, accent, 140), bg = accent },
      },

      inactive = {
        a = { fg = foreground_1, bg = background_1 },
        b = { fg = foreground_1, bg = background_1 },
        c = { fg = foreground_3, bg = darken(background_0, 7) },
        x = { fg = foreground_3, bg = darken(background_0, 7) },
        y = { fg = foreground_1, bg = background_1 },
        z = { fg = foreground_1, bg = background_1 },
      },

      insert = {
        a = { fg = is_light(foreground_1, green, 140), bg = green },
        x = { fg = foreground_1, bg = background_3 },
      },

      command = {
        a = { fg = is_light(foreground_1, yellow, 140), bg = yellow },
        x = { fg = foreground_1, bg = background_3 },
      },

      visual = {
        a = { fg = is_light(foreground_1, purple, 140), bg = purple },
        x = { fg = foreground_1, bg = background_3 },
      },

      replace = {
        a = { fg = is_light(foreground_1, red, 140), bg = red },
        x = { fg = foreground_1, bg = red },
      },
    }
  end

  require("lualine").setup({ options = { theme = lualine_highlights } })

  -- if config.background then
  -- end
  add_highlights(background, highlights)

  if config.transparent then
    add_highlights(transparent, highlights)
  end

  if config.sign_column then
    add_highlights(sign_column, highlights)
  end

  if config.popup_menu then
    add_highlights(popup_menu, highlights)
  end

  apply_highlights(highlights)

  if pcall(require, "nvim-web-devicons") then
    require("nvim-web-devicons").set_up_highlights()
  end

  update_colors()

  config.on_change()
end

M.custom_highlights = function(highlights)
  if highlights == nil then
    return
  end

  if highlights[variant] == nil then
    return
  end

  -- user_highlights = highlights
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

return M
