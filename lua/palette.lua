local darken = require("palette.utils").darken
local lighten = require("palette.utils").lighten
local is_light = require("palette.utils").is_light
local autocmd = vim.api.nvim_create_autocmd

local M = {}

local function validate(value, default)
	if value == nil then
		return default
	else
		return value
	end
end

M.setup = function(options)
	local config = {
		enable = validate(options.enable, true),
		background = validate(options.background, true),
		popup_menu = validate(options.popup_menu, true),
		sign_column = validate(options.sign_column, false),
		transparent = validate(options.transparent, false),
		color_icons = validate(options.color_icons, true),
		silent = validate(options.silent, false),
		vim_globals = validate(options.vim_globals, true),
		on_change = validate(options.on_change, function() end),
		themes_folder = validate(options.themes_folder, "themes/"),
		custom_highlights = validate(options.custom_highlights, {}),
		lualine = validate(options.lualine, true),
	}

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

	local palette = {}

	local theme_name = vim.g.colors_name

	if vim.g.colors_name == nil then
		theme_name = "default"
		if not config.silent then
			print("[nvim-colorscheme] colorscheme wasn't detected, using default theme")
		end
	else
		theme_name = vim.g.colors_name
	end

	local required = {
		dark = {
			background = "#202122",
			foreground = "#ced2da",

			red = "#E86671",
			green = "#98C379",
			yellow = "#E5C07B",
			blue = "#61AFEF",
			purple = "#c792ea",
		},
		light = {
			background = "#E1E1E1",
			foreground = "#444444",

			red = "#d70000",
			green = "#008700",
			yellow = "#d7af5f",
			blue = "#0087af",
			purple = "#8700af",
		},
	}

	if pcall(require, config.themes_folder .. theme_name) then
		palette = require(config.themes_folder .. theme_name)
	else
		if pcall(require, config.themes_folder .. "default") then
			palette = require(config.themes_folder .. "default")
		else
			palette = required
		end
		if not config.silent then
			vim.cmd(":normal <C-l>")
			print("[nvim-palette] could not find /nvim/lua/" .. config.themes_folder .. "" .. theme_name .. ".lua")
		end
	end

	if palette.dark == nil then
		palette.dark = required.dark
	end

	if palette.light == nil then
		palette.light = required.light
	end

	for color in pairs(required[variant]) do
		if palette[color] == nil then
			palette[color] = required[variant][color]
		else
			palette[color] = palette[variant][color]
		end
	end

	local generated = {
		dark = {
			background_0 = palette.dark.background,
			background_1 = lighten(palette.dark.background, 10),
			background_2 = lighten(palette.dark.background, 15),
			background_3 = lighten(palette.dark.background, 15),
			foreground_0 = darken(palette.dark.foreground, 00),
			foreground_1 = darken(palette.dark.foreground, 60),
			foreground_2 = darken(palette.dark.foreground, 90),
			foreground_3 = darken(palette.dark.foreground, 120),
		},

		light = {
			background_0 = palette.light.background,
			background_1 = darken(palette.light.background, 10),
			background_2 = darken(palette.light.background, 15),
			background_3 = darken(palette.light.background, 40),
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
		background_0 = generated.light.background
		background_1 = generated.light.background_1
		background_2 = generated.light.background_2
		background_3 = generated.light.background_3
		foreground_0 = generated.light.foreground_0
		foreground_1 = generated.light.foreground_1
		foreground_2 = generated.light.foreground_2
		foreground_3 = generated.light.foreground_3
	end

	local red = palette[variant].red
	local green = palette[variant].green
	local yellow = palette[variant].yellow
	local blue = palette[variant].blue
	local purple = palette[variant].purple
	local accent = palette[variant].accent or palette[variant].blue
	local none = "none"

	if config.vim_globals then
		vim.g.background_0 = background_0
		vim.g.background_1 = background_1
		vim.g.background_2 = background_2
		vim.g.background_3 = background_3

		vim.g.foreground_0 = foreground_0
		vim.g.foreground_1 = foreground_1
		vim.g.foreground_2 = foreground_2
		vim.g.foreground_3 = foreground_3

		vim.g.red = red
		vim.g.green = green
		vim.g.yellow = yellow
		vim.g.blue = blue
		vim.g.purple = purple
		vim.g.accent = accent
	end

	local highlights = {
		-- Built-in: Statusline
		Statusline = { bg = none, fg = foreground_2, gui = none },
		StatuslineNC = { bg = none, fg = foreground_3, gui = none },

		-- Built-in: Normal
		CursorLineNr = { bg = background_3 },
		LineNr = { bg = none },
		SignColumn = { bg = none },
		VertSplit = { bg = background_1, fg = background_1 },

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
		TelescopePreviewBorder = { fg = foreground_3 },
		TelescopePreviewTitle = { bg = none, fg = foreground_3, gui = "standout" },
		TelescopePreviewNormal = { bg = none },

		-- Telescope: Results
		TelescopeResultsTitle = { fg = foreground_3 },
		TelescopeResultsBorder = { fg = foreground_3 },
		TelescopeResultsNormal = { fg = foreground_2 },

		-- Telescope: Prompt
		TelescopePromptBorder = { bg = none, fg = foreground_3 },
		TelescopePromptNormal = { bg = none, fg = foreground_1 },
		TelescopePromptPrefix = { fg = accent },
		TelescopePromptTitle = { bg = none, fg = accent, gui = "standout" },
		TelescopePromptCounter = { fg = accent },

		-- Telescope: Other
		TelescopeSelection = { bg = accent, fg = is_light(background_3, accent, 150) },
		TelescopeMatching = { fg = none, gui = "underline" },

		-- which-keyvim
		-- https://githubom/folke/which-key

		WhichKeyFloat = { bg = background_1, gui = none },
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
		-- https://githubom/akinsho/bufferlinevim

		CopilotSuggestion = { fg = foreground_3, bg = none },

		-- indent-blanklinevim
		-- https://githubom/lukas-reineke/indent-blanklinevim

		IndentBlankLineChar = { fg = background_3 },
		IndentBlankLineContextChar = { fg = foreground_3 },
		IndentBlankLineSpaceChar = { bg = none },
		IndentBlankLineSpaceCharBlankline = { bg = none },

		-- Built-in: Error
		DiagnosticError = { fg = red, bg = none },
		DiagnosticSignError = { fg = red, bg = none },
		DiagnosticUnderlineError = { guisp = red, gui = "undercurl" },
		DiagnosticFloatingError = { bg = background_2 },

		-- Built-in: Warning
		DiagnosticWarn = { fg = yellow, bg = none },
		DiagnosticSignWarn = { fg = yellow, bg = none },
		DiagnosticUnderlineWarn = { guisp = yellow, gui = "undercurl" },
		DiagnosticFloatingWarn = { bg = background_2 },

		-- Built-in: Info
		DiagnosticInfo = { fg = purple, bg = none },
		DiagnosticSignInfo = { fg = purple, bg = none },
		DiagnosticUnderlineInfo = { guisp = purple, gui = "undercurl" },
		DiagnosticFloatingInfo = { bg = background_3 },

		-- Built-in: Hint
		DiagnosticHint = { fg = blue, bg = none },
		DiagnosticSignHint = { fg = blue, bg = none },
		DiagnosticUnderlineHint = { guisp = blue, gui = "undercurl" },
		DiagnosticFloatingHint = { bg = background_2 },

		-- Built-in: Floating
		-- NormalFloat  , bg =none normal
		FloatBorder = { fg = background_3, bg = none },
		NormalFloat = { bg = none },

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
		PmenuSel = { bg = accent, fg = is_light(background_3, accent, 150), gui = "none" },
		PmenuThumb = { bg = background_3 },
		PmenuSbar = { bg = background_2 },
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

	local no_color_icons = {
		DevIconBabelrc = { fg = foreground_3 },
		DevIconBashProfile = { fg = foreground_3 },
		DevIconBashrc = { fg = foreground_3 },
		DevIconDsStore = { fg = foreground_3 },
		DevIconGitAttributes = { fg = foreground_3 },
		DevIconGitConfig = { fg = foreground_3 },
		DevIconGitIgnore = { fg = foreground_3 },
		DevIconGitlabCI = { fg = foreground_3 },
		DevIconGitModules = { fg = foreground_3 },
		DevIconNPMIgnore = { fg = foreground_3 },
		DevIconNPMrc = { fg = foreground_3 },
		DevIconSettingsJson = { fg = foreground_3 },
		DevIconZshprofile = { fg = foreground_3 },
		DevIconZshenv = { fg = foreground_3 },
		DevIconZshrc = { fg = foreground_3 },
		DevIconBrewfile = { fg = foreground_3 },
		DevIconCMakeLists = { fg = foreground_3 },
		DevIconGitCommit = { fg = foreground_3 },
		DevIconLicense = { fg = foreground_3 },
		DevIconGemfile = { fg = foreground_3 },
		DevIconVagrantfile = { fg = foreground_3 },
		DevIconGvimrc = { fg = foreground_3 },
		DevIconVimrc = { fg = foreground_3 },
		DevIconAi = { fg = foreground_3 },
		DevIconAwk = { fg = foreground_3 },
		DevIconBash = { fg = foreground_3 },
		DevIconBat = { fg = foreground_3 },
		DevIconBmp = { fg = foreground_3 },
		DevIconC = { fg = foreground_3 },
		DevIconCPlusPlus = { fg = foreground_3 },
		DevIconConfiguration = { fg = foreground_3 },
		DevIconClojure = { fg = foreground_3 },
		DevIconClojureC = { fg = foreground_3 },
		DevIconClojureJS = { fg = foreground_3 },
		DevIconDefault = { fg = foreground_3 },
		DevIconCMake = { fg = foreground_3 },
		DevIconCobol = { fg = foreground_3 },
		DevIconCoffee = { fg = foreground_3 },
		DevIconConf = { fg = foreground_3 },
		DevIconConfigRu = { fg = foreground_3 },
		DevIconCp = { fg = foreground_3 },
		DevIconCpp = { fg = foreground_3 },
		DevIconCrystal = { fg = foreground_3 },
		DevIconCs = { fg = foreground_3 },
		DevIconCsh = { fg = foreground_3 },
		DevIconCson = { fg = foreground_3 },
		DevIconCss = { fg = foreground_3 },
		DevIconCsv = { fg = foreground_3 },
		DevIconCxx = { fg = foreground_3 },
		DevIconD = { fg = foreground_3 },
		DevIconDart = { fg = foreground_3 },
		DevIconDb = { fg = foreground_3 },
		DevIconDesktopEntry = { fg = foreground_3 },
		DevIconDiff = { fg = foreground_3 },
		DevIconDoc = { fg = foreground_3 },
		DevIconDockerfile = { fg = foreground_3 },
		DevIconDropbox = { fg = foreground_3 },
		DevIconDump = { fg = foreground_3 },
		DevIconEdn = { fg = foreground_3 },
		DevIconEex = { fg = foreground_3 },
		DevIconEjs = { fg = foreground_3 },
		DevIconElm = { fg = foreground_3 },
		DevIconEpp = { fg = foreground_3 },
		DevIconErb = { fg = foreground_3 },
		DevIconErl = { fg = foreground_3 },
		DevIconEx = { fg = foreground_3 },
		DevIconExs = { fg = foreground_3 },
		DevIconFsharp = { fg = foreground_3 },
		DevIconFavicon = { fg = foreground_3 },
		DevIconFish = { fg = foreground_3 },
		DevIconFs = { fg = foreground_3 },
		DevIconFsi = { fg = foreground_3 },
		DevIconFsscript = { fg = foreground_3 },
		DevIconFsx = { fg = foreground_3 },
		DevIconGDScript = { fg = foreground_3 },
		DevIconGemspec = { fg = foreground_3 },
		DevIconGif = { fg = foreground_3 },
		DevIconGitLogo = { fg = foreground_3 },
		DevIconBinaryGLTF = { fg = foreground_3 },
		DevIconGo = { fg = foreground_3 },
		DevIconGodotProject = { fg = foreground_3 },
		DevIconGruntfile = { fg = foreground_3 },
		DevIconGulpfile = { fg = foreground_3 },
		DevIconH = { fg = foreground_3 },
		DevIconHaml = { fg = foreground_3 },
		DevIconHbs = { fg = foreground_3 },
		DevIconHeex = { fg = foreground_3 },
		DevIconHh = { fg = foreground_3 },
		DevIconHpp = { fg = foreground_3 },
		DevIconHrl = { fg = foreground_3 },
		DevIconHs = { fg = foreground_3 },
		DevIconHtm = { fg = foreground_3 },
		DevIconHtml = { fg = foreground_3 },
		DevIconHxx = { fg = foreground_3 },
		DevIconIco = { fg = foreground_3 },
		DevIconImportConfiguration = { fg = foreground_3 },
		DevIconIni = { fg = foreground_3 },
		DevIconJava = { fg = foreground_3 },
		DevIconJl = { fg = foreground_3 },
		DevIconJpeg = { fg = foreground_3 },
		DevIconJpg = { fg = foreground_3 },
		DevIconJs = { fg = foreground_3 },
		DevIconJson = { fg = foreground_3 },
		DevIconJsx = { fg = foreground_3 },
		DevIconKsh = { fg = foreground_3 },
		DevIconKotlin = { fg = foreground_3 },
		DevIconLeex = { fg = foreground_3 },
		DevIconLess = { fg = foreground_3 },
		DevIconLhs = { fg = foreground_3 },
		DevIconLua = { fg = foreground_3 },
		DevIconMakefile = { fg = foreground_3 },
		DevIconMarkdown = { fg = foreground_3 },
		DevIconMaterial = { fg = foreground_3 },
		DevIconMd = { fg = foreground_3 },
		DevIconMdx = { fg = foreground_3 },
		DevIconMint = { fg = foreground_3 },
		DevIconMixLock = { fg = foreground_3 },
		DevIconMjs = { fg = foreground_3 },
		DevIconMl = { fg = foreground_3 },
		DevIconMli = { fg = foreground_3 },
		DevIconMustache = { fg = foreground_3 },
		DevIconNim = { fg = foreground_3 },
		DevIconNix = { fg = foreground_3 },
		DevIconNodeModules = { fg = foreground_3 },
		DevIconOPUS = { fg = foreground_3 },
		DevIconOpenTypeFont = { fg = foreground_3 },
		DevIconPackageJson = { fg = foreground_3 },
		DevIconPackageLockJson = { fg = foreground_3 },
		DevIconPackedResource = { fg = foreground_3 },
		DevIconPdf = { fg = foreground_3 },
		DevIconPhp = { fg = foreground_3 },
		DevIconPl = { fg = foreground_3 },
		DevIconPm = { fg = foreground_3 },
		DevIconPng = { fg = foreground_3 },
		DevIconPp = { fg = foreground_3 },
		DevIconPpt = { fg = foreground_3 },
		DevIconProlog = { fg = foreground_3 },
		DevIconProcfile = { fg = foreground_3 },
		DevIconPromptPs1 = { fg = foreground_3 },
		DevIconPsb = { fg = foreground_3 },
		DevIconPsd = { fg = foreground_3 },
		DevIconPy = { fg = foreground_3 },
		DevIconPyc = { fg = foreground_3 },
		DevIconPyd = { fg = foreground_3 },
		DevIconPyo = { fg = foreground_3 },
		DevIconR = { fg = foreground_3 },
		DevIconRake = { fg = foreground_3 },
		DevIconRakefile = { fg = foreground_3 },
		DevIconRb = { fg = foreground_3 },
		DevIconRlib = { fg = foreground_3 },
		DevIconRmd = { fg = foreground_3 },
		DevIconRproj = { fg = foreground_3 },
		DevIconRs = { fg = foreground_3 },
		DevIconRss = { fg = foreground_3 },
		DevIconSass = { fg = foreground_3 },
		DevIconScala = { fg = foreground_3 },
		DevIconScss = { fg = foreground_3 },
		DevIconSh = { fg = foreground_3 },
		DevIconSig = { fg = foreground_3 },
		DevIconSlim = { fg = foreground_3 },
		DevIconSln = { fg = foreground_3 },
		DevIconSml = { fg = foreground_3 },
		DevIconSql = { fg = foreground_3 },
		DevIconStyl = { fg = foreground_3 },
		DevIconSuo = { fg = foreground_3 },
		DevIconSvelte = { fg = foreground_3 },
		DevIconSvg = { fg = foreground_3 },
		DevIconSwift = { fg = foreground_3 },
		DevIconTor = { fg = foreground_3 },
		DevIconTerminal = { fg = foreground_3 },
		DevIconTex = { fg = foreground_3 },
		DevIconToml = { fg = foreground_3 },
		DevIconTextResource = { fg = foreground_3 },
		DevIconTs = { fg = foreground_3 },
		DevIconTextScene = { fg = foreground_3 },
		DevIconTsx = { fg = foreground_3 },
		DevIconTwig = { fg = foreground_3 },
		DevIconTxt = { fg = foreground_3 },
		DevIconVim = { fg = foreground_3 },
		DevIconVue = { fg = foreground_3 },
		DevIconWebmanifest = { fg = foreground_3 },
		DevIconWebp = { fg = foreground_3 },
		DevIconWebpack = { fg = foreground_3 },
		DevIconXcPlayground = { fg = foreground_3 },
		DevIconXls = { fg = foreground_3 },
		DevIconXml = { fg = foreground_3 },
		DevIconXul = { fg = foreground_3 },
		DevIconYaml = { fg = foreground_3 },
		DevIconYml = { fg = foreground_3 },
		DevIconZig = { fg = foreground_3 },
		DevIconZsh = { fg = foreground_3 },
		DevIconSolidity = { fg = foreground_3 },
	}

	local lualine_highlights

	if variant == "light" then
		lualine_highlights = {
			normal = {
				a = { fg = is_light(foreground_3, accent, 140), bg = accent },
				b = { fg = foreground_1, bg = background_3 },
				c = { fg = foreground_3, bg = darken(background_0, 7) },
				y = { fg = foreground_3, bg = darken(background_0, 7) },
				x = { fg = foreground_1, bg = background_3 },
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
				a = { fg = foreground_1, bg = green },
			},

			command = {
				a = { fg = foreground_1, bg = yellow },
			},

			visual = {
				a = { fg = foreground_1, bg = purple },
			},

			replace = {
				a = { fg = foreground_1, bg = red },
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
				y = { fg = foreground_3, bg = darken(background_0, 7) },
				x = { fg = foreground_1, bg = background_1 },
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

	local function add_highlights(table)
		for k, v in pairs(table) do
			highlights[k] = v
		end
	end

	if config.enable then
		add_highlights(highlights)

		if config.background then
			add_highlights(background)
		end

		if config.transparent then
			add_highlights(transparent)
		end

		if config.sign_column then
			add_highlights(sign_column)
		end

		if config.popup_menu then
			add_highlights(popup_menu)
		end

		if not config.color_icons then
			add_highlights(no_color_icons)
		end

		if config.lualine then
			if pcall(require, "lualine") then
				require("lualine").setup({ options = { theme = lualine_highlights } })
			end
		end

		if config.custom_highlights then
			add_highlights(config.custom_highlights)
		end

		for k, v in pairs(highlights) do
			local hl = k

			if v.fg ~= nil then
				hl = hl .. " guifg=" .. v.fg
			end

			if v.bg ~= nil then
				hl = hl .. " guibg=" .. v.bg
			end

			if v.gui ~= nil then
				hl = hl .. " gui=" .. v.gui
			end

			if v.guisp ~= nil then
				hl = hl .. " guisp=" .. v.guisp
			end

			vim.cmd("hi! " .. hl)
		end

		-- trying to get this to work with kitty

		--   local function edit(key, value)
		--     -- Read from file
		--     -- local file = io.open("lua/utils/colorscheme/test.conf", "r")
		--     local file = io.open("lua/utils/colorscheme/test.conf", "r")
		--
		--     local lines = {}
		--
		--     for line in file:lines() do
		--       -- Replace key with new value
		--       local updated_line = line:gsub(key, value)
		--
		--       -- If matched with updated_line, replace it
		--       if updated_line ~= line then
		--         table.insert(lines, updated_line)
		--       else
		--         table.insert(lines, line)
		--       end
		--     end
		--
		--     -- Write to file
		--     -- file = io.open("lua/utils/colorscheme/test.conf", "w")
		--     file = io.open("lua/utils/colorscheme/test.conf", "w")
		--     file:write(tostring(table.concat(lines, "\n")))
		--
		--     -- Close file
		--     file:close()
		--   end
		--
		--   edit("hello world", "what the fuck")

		local group = vim.api.nvim_create_augroup("UpdateColors", { clear = true })

		autocmd("ColorScheme", {
			desc = "Reset highlights on save",
			callback = function()
				M.setup(config)
			end,
			group = group,
		})

		config.on_change()
	end
end
-- -- Builtin: Quickfix

return M
