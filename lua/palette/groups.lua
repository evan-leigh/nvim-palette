local M = {}

local darken = require("palette.utils").darken
local lighten = require("palette.utils").lighten

local is_light = require("palette.utils").is_light

M.setup = function(optional_highlights)
  local colors = require("palette.colors")

  M.highlights = {

    -- Built-in: Normal
    -- Normal = { bg = "#111111" },
    Normal = { bg = colors.background_0 },
    NormalNC = { bg = colors.background_0 },
    EndOfBuffer = { bg = colors.background_0 },

    -- Built-in: Statusline
    Statusline = { bg = colors.none, fg = colors.foreground_2, gui = colors.none },
    StatuslineNC = { bg = colors.none, fg = colors.foreground_3, gui = colors.none },

    -- Built-in: PopupMenu
    Pmenu = { bg = colors.background_1, fg = colors.foreground_1 },
    PmenuSel = { bg = colors.accent, gui = "none", fg = is_light(colors.foreground_3, colors.accent, 60) },
    PmenuThumb = { bg = lighten(colors.background_3, 60) },
    PmenuSbar = { bg = lighten(colors.background_3, 60) },
    PmenuThumbSel = { bg = colors.accent },

    -- Built-in: Fold
    Folded = { bg = lighten(colors.background_0, 10) },
    FoldColumn = { fg = colors.foreground_3, bg = colors.background_0 },

    -- Built-in: CursorLine
    CursorLine = { bg = colors.background_3 },
    CursorLineNr = { bg = colors.background_3 },
    LineNr = { bg = colors.none, fg = darken(colors.foreground_3, 10) },
    SignColumn = { bg = colors.none },
    VertSplit = { bg = colors.background_1, fg = colors.background_1 },

    NormalFloat = { bg = colors.background_1, fg = colors.foreground_1 },
    FloatBorder = { bg = colors.background_1, fg = colors.foreground_3 },

    -- Built-in: Error
    DiagnosticError = { fg = colors.red, bg = colors.none },
    DiagnosticSignError = { fg = colors.red, bg = colors.none },
    DiagnosticUnderlineError = { guisp = colors.red, gui = "undercurl" },

    -- Built-in: Warning
    DiagnosticWarn = { fg = colors.yellow, bg = colors.none },
    DiagnosticSignWarn = { fg = colors.yellow, bg = colors.none },
    DiagnosticUnderlineWarn = { guisp = colors.yellow, gui = "undercurl" },

    -- Built-in: Info
    DiagnosticInfo = { fg = colors.purple, bg = colors.none },
    DiagnosticSignInfo = { fg = colors.purple, bg = colors.none },
    DiagnosticUnderlineInfo = { guisp = colors.purple, gui = "undercurl" },

    -- Built-in: Hint
    DiagnosticHint = { fg = colors.blue, bg = colors.none },
    DiagnosticSignHint = { fg = colors.blue, bg = colors.none },
    DiagnosticUnderlineHint = { guisp = colors.blue, gui = "undercurl" },
    DiagnosticFloatingHint = { bg = colors.none, fg = colors.foreground_2 },


    -- indent-blankline
    -- https://githubom/lukas-reineke/indent-blankline

    IndentBlankLineChar = { fg = lighten(colors.background_3, 15) },
    IndentBlankLineContextChar = { fg = lighten(colors.background_3, variant == "light" and 0 or 40) },
    IndentBlankLineSpaceChar = { bg = colors.none },
    IndentBlankLineSpaceCharBlankline = { bg = colors.none },

    -- nvim-lspconfig
    -- https://githubom/neovim/nvim-lspconfig

    -- LSP Symbols
    LspReferenceRead = { bg = colors.background_1 },
    LspReferenceText = { bg = colors.background_1 },
    LspReferenceWrite = { bg = colors.background_1 },

    -- LSP Config: Error
    LspDiagnosticsDefaultError = { fg = colors.red },
    LspDiagnosticsSignError = { fg = colors.red },
    LspDiagnosticsError = { fg = colors.red },
    LspDiagnosticsUnderlineError = { guisp = colors.red, gui = "undercurl" },

    -- LSP Config: Warning
    LspDiagnosticsDefaultWarn = { fg = colors.yellow },
    LspDiagnosticsSignWarn = { fg = colors.yellow },
    LspDiagnosticsWarn = { fg = colors.yellow },
    LspDiagnosticsUnderlineWarn = { guisp = colors.yellow, gui = "undercurl" },

    -- LSP Config: Hint
    LspDiagnosticsDefaultHint = { fg = colors.purple },
    LspDiagnosticsSignHint = { fg = colors.purple },
    LspDiagnosticsHint = { fg = colors.purple },
    LspDiagnosticsUnderlineHint = { guisp = colors.purple, gui = "undercurl" },

    -- LSP Config: Info
    LspDiagnosticsDefaultInfo = { fg = colors.blue },
    LspDiagnosticsSignInfo = { fg = colors.blue },
    LspDiagnosticsInfo = { fg = colors.blue },
    LspDiagnosticsUnderlineInfo = { guisp = colors.blue, gui = "undercurl" },

    -- nvim-tree
    -- https://githubom/kyazdani42/nvim-tree

    -- NvimTree: Background
    NvimTreeNormal = { bg = colors.background_1, fg = colors.foreground_1 },
    NvimTreeNormalNC = { bg = colors.background_1, fg = colors.foreground_1 },
    NvimTreeEndOfBuffer = { bg = colors.background_1, fg = colors.background_1 },
    NvimTreeVertSplit = { bg = colors.background_1, fg = colors.background_1 },
    NvimTreeStatusline = { bg = colors.background_1, fg = colors.background_1 },
    NvimTreeStatuslineNC = { bg = colors.background_1, fg = colors.background_1 },

    -- NvimTree: Icons
    NvimTreeGitDelete = { fg = colors.red },
    NvimTreeFileDirty = { fg = colors.yellow },
    NvimTreeGitNew = { fg = colors.green },
    NvimTreeSpecialFile = { fg = colors.purple },
    NvimTreeGitDirty = { fg = colors.yellow },
    NvimTreeGitStaged = { fg = colors.green },
    NvimTreeFolderIcon = { fg = colors.foreground_3 },
    NvimTreeFolderName = { fg = colors.foreground_1 },
    NvimTreeOpenedFolderName = { fg = colors.foreground_1, bg = colors.none },
    NvimTreeEmptyFolderName = { fg = colors.foreground_3 },
    NvimTreeRootFolder = { fg = colors.foreground_2 },

    -- NvimTree: Other
    NvimTreeIndentMarker = { fg = lighten(colors.background_3, 20) },

    -- which-key
    -- https://githubom/folke/which-key

    WhichKeyFloat = { links = "NormalFloat" },
    WhichKeyDesc = { fg = colors.foreground_1, bg = colors.none },
    WhichKeyGroup = { fg = colors.foreground_2, bg = colors.none },
    WhichKeySeparator = { fg = colors.background_3, bg = colors.none },
    WhichKey = { fg = colors.accent, gui = "bold", bg = colors.none },

    -- gitsigns
    -- https://githubom/lewis6991/gitsigns

    -- GitSigns: Added
    GitSignsAdd = { fg = colors.green, bg = colors.none },
    GitSignsAddLn = { fg = colors.green, bg = colors.none },
    GitSignsAddNr = { fg = colors.green, bg = colors.none },
    GitGutterAdd = { fg = colors.green, bg = colors.none },

    -- GitSigns: Changed
    GitSignsChangeLn = { fg = colors.yellow, bg = colors.none },
    GitSignsChangeNr = { fg = colors.yellow, bg = colors.none },
    GitSignsChange = { fg = colors.yellow, bg = colors.none },

    -- GitSigns: Deleted
    GitSignsDelete = { fg = colors.red, bg = colors.none },
    GitSignsDeleteLn = { fg = colors.red, bg = colors.none },
    GitSignsDeleteNr = { fg = colors.red, bg = colors.none },
    GitGutterDelete = { fg = colors.red, bg = colors.none },

    -- telescope
    -- https://githubom/nvim-telescope/telescope

    -- Telescope: Preview
    TelescopePreviewBorder = { links = "FloatBorder" },
    TelescopePreviewTitle = { bg = colors.none, fg = colors.foreground_3 },
    TelescopePreviewNormal = { links = "NormalFloat" },

    -- Telescope: Results
    TelescopeResultsTitle = { fg = colors.foreground_3 },
    TelescopeResultsBorder = { links = "FloatBorder" },
    TelescopeResultsNormal = { links = "NormalFloat" },

    -- Telescope: Prompt
    TelescopePromptBorder = { links = "FloatBorder" },
    TelescopePromptNormal = { links = "NormalFloat" },
    TelescopePromptPrefix = { fg = colors.accent },
    TelescopePromptTitle = { bg = colors.none, fg = colors.foreground_3 },
    TelescopePromptCounter = { fg = colors.accent },

    -- Telescope: Other
    TelescopeSelection = { links = "PmenuSel" },
    TelescopeMatching = { fg = colors.none, gui = "underline" },

    -- nvim-ufo
    -- https://github.com/kevinhwang91/nvim-ufo

    UfoFoldedBg = { bg = "none" },
    UfoFoldedFg = { bg = "none" },
    UfoFoldedEllipsis = { fg = colors.foreground_3 },

    -- bufferline
    -- https://github.com/akinsho/bufferline.nvim

    -- BufferLine: Selected
    BufferLineTabSelected = { fg = colors.foreground_0, bg = colors.background_3 },
    BufferLineBufferSelected = { fg = colors.foreground_0, bg = colors.background_3 },
    BufferLineCloseButtonSelected = { fg = colors.foreground_0, bg = colors.background_3 },
    BufferLineDiagnosticSelected = { fg = darken(colors.foreground_3, 20), bg = colors.background_3 },
    BufferLineNumbersSelected = { fg = colors.foreground_0, bg = colors.background_3 },
    BufferLineHintSelected = { fg = colors.purple, bg = colors.background_3 },
    BufferLineInfoSelected = { fg = colors.yellow, bg = colors.background_3 },
    BufferLineHintDiagnosticSelected = { fg = colors.purple, bg = colors.background_3 },
    BufferLineInfoDiagnosticSelected = { fg = colors.blue, bg = colors.background_3 },
    BufferLineWarningSelected = { fg = colors.blue, bg = colors.background_3 },
    BufferLineWarningDiagnosticSelected = { fg = colors.yellow, bg = colors.background_3 },
    BufferLineErrorSelected = { fg = colors.red, bg = colors.background_3 },
    BufferLineErrorDiagnosticSelected = { fg = colors.red, bg = colors.background_3 },
    BufferLineModifiedSelected = { fg = colors.green, bg = colors.background_3 },
    BufferLineDuplicateSelected = { fg = colors.foreground_3, bg = colors.background_3 },
    BufferLineSeparatorSelected = { fg = darken(colors.background_0, 7), bg = colors.background_3 },
    BufferLineIndicatorSelected = { fg = colors.accent, bg = colors.background_3 },
    BufferLinePickSelected = { fg = colors.red, bg = colors.background_3 },

    -- BufferLine: Fill
    BufferLineFill = { fg = colors.foreground_3, bg = darken(colors.background_0, 7) },

    -- BufferLine: Group
    BufferLineGroupLabel = { fg = darken(colors.background_0, 7), bg = colors.background_3 },
    BufferLineGroupSeparator = { fg = colors.foreground_3, bg = darken(colors.background_0, 7) },

    -- BufferLine: Visible
    BufferLineSeparatorVisible = { fg = darken(colors.background_0, 7), bg = colors.background_2 },
    BufferLineCloseButtonVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineBufferVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineNumbersVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineDiagnosticVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineHintVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineHintDiagnosticVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineInfoVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineInfoDiagnosticVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineWarningVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineWarningDiagnosticVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineErrorVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineErrorDiagnosticVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineModifiedVisible = { fg = colors.foreground_1, bg = colors.background_2 },
    BufferLineDuplicateVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLineIndicatorVisible = { fg = colors.foreground_3, bg = colors.background_2 },
    BufferLinePickVisible = { fg = colors.red, bg = colors.background_2 },

    -- BufferLine: Not Selected
    BufferLineSeparator = { fg = darken(colors.background_0, 7), bg = colors.background_1 },
    BufferLineInfo = { fg = colors.foreground_1, bg = colors.background_1 },
    BufferLineHint = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineWarning = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineTab = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineDiagnostic = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineBuffer = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineError = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineModified = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineBackground = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineTabClose = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineCloseButton = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineInfoDiagnostic = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineNumbers = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineHintDiagnostic = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLinePick = { fg = colors.red, bg = colors.background_1 },
    BufferLineWarningDiagnostic = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineErrorDiagnostic = { fg = colors.foreground_2, bg = colors.background_1 },
    BufferLineDuplicate = { fg = colors.foreground_3, bg = colors.background_1 },

    -- nvim-cmp
    -- https://githubom/hrsh7th/nvim-cmp

    -- Icons
    CmpItemAbbr = { fg = colors.foreground_2 },
    CmpItemMenu = { fg = colors.foreground_2 },
    CmpItemAbbrMatch = { fg = colors.foreground_0, bg = colors.none, gui = colors.none },
    CmpItemAbbrMatchFuzzy = { fg = colors.accent, gui = "underline" },
    CmpItemKindKind = { fg = colors.accent },
    CmpItemKindClass = { fg = colors.green },
    CmpItemKindConstructor = { fg = colors.green },
    CmpItemKindField = { fg = colors.blue },
    CmpItemKindFile = { fg = colors.yellow },
    CmpItemKindFolder = { fg = colors.yellow },
    CmpItemKindFunction = { fg = colors.purple },
    CmpItemKindInterface = { fg = colors.blue },
    CmpItemKindKeyword = { fg = colors.blue },
    CmpItemKindMethod = { fg = colors.purple },
    CmpItemKindSnippet = { fg = colors.yellow },
    CmpItemKindText = { fg = colors.foreground_3 },
    CmpItemKindValue = { fg = colors.blue },
    CmpItemKindVariable = { fg = colors.purple },
    CmpItemAbbrDepricated = { bg = colors.foreground_2, gui = "strikethrough" },
  }

  for group_name, highlight in pairs(optional_highlights) do
    M.highlights[group_name] = highlight

    if type(highlight) == "table" then
      for group_name_1, group_highlight_1 in pairs(highlight) do
        M.highlights[group_name_1] = group_highlight_1
      end
    end
  end
end

return M
