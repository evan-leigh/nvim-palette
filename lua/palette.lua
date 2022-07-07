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

local function execute_highlights(highlight, property)
  local hl = highlight

  if property.links == nil then
    if property.bg ~= nil then
      hl = hl .. " guibg=" .. property.bg
    end

    if property.fg ~= nil then
      hl = hl .. " guifg=" .. property.fg
    end

    if property.gui ~= nil then
      hl = hl .. " gui=" .. property.gui
    end

    if property.guisp ~= nil then
      hl = hl .. " guisp=" .. property.guisp
    end

    vim.cmd("hi " .. hl)
  else
    vim.cmd("hi! link " .. hl .. " " .. property.links)
  end
end

local user_configuration
local user_highlights

local function apply_highlights(highlights_tbl)
  for key, value in pairs(highlights_tbl) do
    execute_highlights(key, value)
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

-- This will update the palette and highlights
local function update_colors()
  -- Delete augroups so that they're not duplicated
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

-- Create highight groups based on options
--
-- @param options:table - Apply different highlighting based on options
M.setup = function(options)
  if options == nil then
    options = {}
  end

  local fn = vim.fn

  user_configuration = options

  local config = {
    -- background = validate(options.background, true),
    popup_menu = validate(options.popup_menu, true),
    sign_column = validate(options.sign_column, false),
    transparent = validate(options.transparent, false),
    on_change = validate(options.on_change, function() end),
    variant = validate(options.variant, nil),
  }

  palette = options[vim.g.colors_name]

  if palette == nil then
    if options["*"][variant] then
      palette = options["*"]
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

  if options["*"] ~= nil
      and options["*"] ~= nil
      and options["*"].settings ~= nil
      and options["*"].settings.darken ~= nil
  then
    -- if not_empty(options["*"].settings.darken) then
    amount = options["*"].settings.darken
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

  local background_0 = generated.dark.background_0
  local background_1 = generated.dark.background_1
  local background_2 = generated.dark.background_2
  local background_3 = generated.dark.background_3

  local foreground_0 = generated.dark.foreground_0
  local foreground_1 = generated.dark.foreground_1
  local foreground_2 = generated.dark.foreground_2
  local foreground_3 = generated.dark.foreground_3

  if variant == "light" then
    background_0 = generated.light.
    background_1 = generated.light.background_1
    background_2 = generated.light.background_2
    background_3 = generated.light.background_3

    foreground_0 = generated.light.foreground_0
    foreground_1 = generated.light.foreground_1
    foreground_2 = generated.light.foreground_2
    foreground_3 = generated.light.foreground_3
  end

  local function validate_color(color)
    -- Checks if color exist in palette
    if palette[variant][color] == nil then
      -- I want a better way of doing this
      if options["*"] ~= nil and options["*"][variant] ~= nil and options["*"][variant][color] ~= nil then
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

    -- Built-in: Fold
    Folded = { bg = lighten(background_0, 10) },
    FoldColumn = { fg = foreground_3, bg = background_0 },

    -- Built-in: CursorLine
    CursorLine = { bg = background_3 },
    CursorLineNr = { bg = background_3 },
    LineNr = { bg = none, fg = darken(foreground_3, 10) },
    SignColumn = { bg = none },
    VertSplit = { bg = background_1, fg = background_1 },

    NormalFloat = { bg = background_1, fg = foreground_1 },
    FloatBorder = { bg = background_1, fg = foreground_3 },

    -- Built-in: Error
    DiagnosticError = { fg = red, bg = none },
    DiagnosticSignError = { fg = red, bg = none },
    DiagnosticUnderlineError = { guisp = red, gui = "undercurl" },

    -- Built-in: Warning
    DiagnosticWarn = { fg = yellow, bg = none },
    DiagnosticSignWarn = { fg = yellow, bg = none },
    DiagnosticUnderlineWarn = { guisp = yellow, gui = "undercurl" },

    -- Built-in: Info
    DiagnosticInfo = { fg = purple, bg = none },
    DiagnosticSignInfo = { fg = purple, bg = none },
    DiagnosticUnderlineInfo = { guisp = purple, gui = "undercurl" },

    -- Built-in: Hint
    DiagnosticHint = { fg = blue, bg = none },
    DiagnosticSignHint = { fg = blue, bg = none },
    DiagnosticUnderlineHint = { guisp = blue, gui = "undercurl" },
    -- DiagnosticFloatingHint = { bg = none, fg = foreground_2 },


    -- indent-blankline
    -- https://githubom/lukas-reineke/indent-blankline

    IndentBlankLineChar = { fg = lighten(background_3, 15) },
    IndentBlankLineContextChar = { fg = lighten(background_3, variant == "light" and 0 or 40) },
    IndentBlankLineSpaceChar = { bg = none },
    IndentBlankLineSpaceCharBlankline = { bg = none },

    -- nvim-lspconfig
    -- https://githubom/neovim/nvim-lspconfig

    -- LSP Symbols
    LspReferenceRead = { bg = background_1 },
    LspReferenceText = { bg = background_1 },
    LspReferenceWrite = { bg = background_1 },

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

    -- nvim-tree
    -- https://githubom/kyazdani42/nvim-tree

    -- NvimTree: Background
    NvimTreeNormal = { bg = background_1, fg = foreground_1 },
    NvimTreeNormalNC = { bg = background_1, fg = foreground_1 },
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
    NvimTreeFolderName = { fg = foreground_1 },
    NvimTreeOpenedFolderName = { fg = foreground_1, bg = none },
    NvimTreeEmptyFolderName = { fg = foreground_3 },
    NvimTreeRootFolder = { fg = foreground_2 },

    -- NvimTree: Other
    NvimTreeIndentMarker = { fg = lighten(background_3, 20) },

    -- which-key
    -- https://githubom/folke/which-key

    WhichKeyFloat = { links = "NormalFloat" },
    WhichKeyDesc = { fg = foreground_1, bg = none },
    WhichKeyGroup = { fg = foreground_2, bg = none },
    WhichKeySeparator = { fg = background_3, bg = none },
    WhichKey = { fg = accent, gui = "bold", bg = none },

    -- gitsigns
    -- https://githubom/lewis6991/gitsigns

    -- GitSigns: Added
    GitSignsAdd = { fg = green, bg = none },
    GitSignsAddLn = { fg = green, bg = none },
    GitSignsAddNr = { fg = green, bg = none },
    GitGutterAdd = { fg = green, bg = none },

    -- GitSigns: Changed
    GitSignsChangeLn = { fg = yellow, bg = none },
    GitSignsChangeNr = { fg = yellow, bg = none },
    GitSignsChange = { fg = yellow, bg = none },

    -- GitSigns: Deleted
    GitSignsDelete = { fg = red, bg = none },
    GitSignsDeleteLn = { fg = red, bg = none },
    GitSignsDeleteNr = { fg = red, bg = none },
    GitGutterDelete = { fg = red, bg = none },

    -- telescope
    -- https://githubom/nvim-telescope/telescope

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


    -- nvim-ufo
    -- https://github.com/kevinhwang91/nvim-ufo

    UfoFoldedBg = { bg = "none" },
    UfoFoldedFg = { bg = "none" },
    UfoFoldedEllipsis = { fg = foreground_3 },


    -- bufferline
    -- https://github.com/akinsho/bufferline.nvim

    -- BufferLine: Selected
    BufferLineTabSelected = { fg = foreground_0, bg = background_3 },
    BufferLineBufferSelected = { fg = foreground_0, bg = background_3 },
    BufferLineCloseButtonSelected = { fg = foreground_0, bg = background_3 },
    BufferLineDiagnosticSelected = { fg = darken(foreground_3, 20), bg = background_3 },
    BufferLineNumbersSelected = { fg = foreground_0, bg = background_3 },
    BufferLineHintSelected = { fg = purple, bg = background_3 },
    BufferLineInfoSelected = { fg = yellow, bg = background_3 },
    BufferLineHintDiagnosticSelected = { fg = purple, bg = background_3 },
    BufferLineInfoDiagnosticSelected = { fg = blue, bg = background_3 },
    BufferLineWarningSelected = { fg = blue, bg = background_3 },
    BufferLineWarningDiagnosticSelected = { fg = yellow, bg = background_3 },
    BufferLineErrorSelected = { fg = red, bg = background_3 },
    BufferLineErrorDiagnosticSelected = { fg = red, bg = background_3 },
    BufferLineModifiedSelected = { fg = green, bg = background_3 },
    BufferLineDuplicateSelected = { fg = foreground_3, bg = background_3 },
    BufferLineSeparatorSelected = { fg = darken(background_0, 7), bg = background_3 },
    BufferLineIndicatorSelected = { fg = accent, bg = background_3 },
    BufferLinePickSelected = { fg = red, bg = background_3 },

    -- BufferLine: Fill
    BufferLineFill = { fg = foreground_3, bg = darken(background_0, 7) },

    -- BufferLine: Group
    BufferLineGroupLabel = { fg = darken(background_0, 7), bg = background_3 },
    BufferLineGroupSeparator = { fg = foreground_3, bg = darken(background_0, 7) },

    -- BufferLine: Visible
    BufferLineSeparatorVisible = { fg = darken(background_0, 7), bg = background_2 },
    BufferLineCloseButtonVisible = { fg = foreground_3, bg = background_2 },
    BufferLineBufferVisible = { fg = foreground_3, bg = background_2 },
    BufferLineNumbersVisible = { fg = foreground_3, bg = background_2 },
    BufferLineDiagnosticVisible = { fg = foreground_3, bg = background_2 },
    BufferLineHintVisible = { fg = foreground_3, bg = background_2 },
    BufferLineHintDiagnosticVisible = { fg = foreground_3, bg = background_2 },
    BufferLineInfoVisible = { fg = foreground_3, bg = background_2 },
    BufferLineInfoDiagnosticVisible = { fg = foreground_3, bg = background_2 },
    BufferLineWarningVisible = { fg = foreground_3, bg = background_2 },
    BufferLineWarningDiagnosticVisible = { fg = foreground_3, bg = background_2 },
    BufferLineErrorVisible = { fg = foreground_3, bg = background_2 },
    BufferLineErrorDiagnosticVisible = { fg = foreground_3, bg = background_2 },
    BufferLineModifiedVisible = { fg = foreground_1, bg = background_2 },
    BufferLineDuplicateVisible = { fg = foreground_3, bg = background_2 },
    BufferLineIndicatorVisible = { fg = foreground_3, bg = background_2 },
    BufferLinePickVisible = { fg = red, bg = background_2 },

    -- BufferLine: Not Selected
    BufferLineSeparator = { fg = darken(background_0, 7), bg = background_1 },
    BufferLineInfo = { fg = foreground_1, bg = background_1 },
    BufferLineHint = { fg = foreground_2, bg = background_1 },
    BufferLineWarning = { fg = foreground_2, bg = background_1 },
    BufferLineTab = { fg = foreground_2, bg = background_1 },
    BufferLineDiagnostic = { fg = foreground_2, bg = background_1 },
    BufferLineBuffer = { fg = foreground_2, bg = background_1 },
    BufferLineError = { fg = foreground_2, bg = background_1 },
    BufferLineModified = { fg = foreground_2, bg = background_1 },
    BufferLineBackground = { fg = foreground_2, bg = background_1 },
    BufferLineTabClose = { fg = foreground_2, bg = background_1 },
    BufferLineCloseButton = { fg = foreground_2, bg = background_1 },
    BufferLineInfoDiagnostic = { fg = foreground_2, bg = background_1 },
    BufferLineNumbers = { fg = foreground_2, bg = background_1 },
    BufferLineHintDiagnostic = { fg = foreground_2, bg = background_1 },
    BufferLinePick = { fg = red, bg = background_1 },
    BufferLineWarningDiagnostic = { fg = foreground_2, bg = background_1 },
    BufferLineErrorDiagnostic = { fg = foreground_2, bg = background_1 },
    BufferLineDuplicate = { fg = foreground_3, bg = background_1 },

    -- nvim-cmp
    -- https://githubom/hrsh7th/nvim-cmp

    -- Icons
    CmpItemAbbr = { fg = foreground_2 },
    CmpItemMenu = { fg = foreground_2 },
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
    CmpItemKindText = { fg = foreground_3 },
    CmpItemKindValue = { fg = blue },
    CmpItemKindVariable = { fg = purple },
    CmpItemAbbrDepricated = { bg = foreground_2, gui = "strikethrough" },
  }

  local transparent = {
    Normal = { bg = "none" },
    NormalNC = { bg = "none" },
    EndOfBuffer = { bg = "none" },
    CursorLine = { bg = "none" },
    CursorLineNr = { bg = "none" },
    SignColumn = { bg = "none" },
    FoldColumn = { fg = lighten(background_3, 40), bg = "none" },
    Folded = { bg = "none" },
    LineNr = { bg = "none", fg = foreground_3 },
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
    PmenuSel = { bg = accent, gui = "none", fg = is_light(foreground_3, accent, 60) },
    PmenuThumb = { bg = lighten(background_3, 60) },
    PmenuSbar = { bg = lighten(background_3, 60) },
    PmenuThumbSel = { bg = accent },
  }

  local sign_column = {
    -- Builtin: SignColumn
    LineNr = { bg = background_1, fg = darken(foreground_3, 10) },
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

  update_colors()

  config.on_change()
end

return M
