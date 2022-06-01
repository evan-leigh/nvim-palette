local darken = require("palette.utils").darken
local lighten = require("palette.utils").lighten
local is_light = require("palette.utils").is_light
local autocmd = vim.api.nvim_create_autocmd

local M = {}

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

-- FIX BUGS:
-- ✅ Prevent au command from duplicating itself
-- ✅ default themes have no syntax highlighting
-- Recoginize "vim.g" colors on start up

-- Provide options, or use defaults
M.setup = function(options)
	if options == nil then
		options = {}
	end

	local required = {
		dark = {
			background = "#000000",
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

	local config = {
		background = validate(options.background, true),
		popup_menu = validate(options.popup_menu, true),
		sign_column = validate(options.sign_column, false),
		transparent = validate(options.transparent, false),
		on_change = validate(options.on_change, function() end),
		custom_highlights = validate(options.custom_highlights, {}),
		lualine = validate(options.lualine, true),
		darken = validate(options.darken, 1),
		["*"] = validate(options["*"], nil),
		default = validate(options, nil),
		colors_name = options[vim.g.colors_name],
	}

	local palette = config.colors_name

	if palette == nil then
		if options then
			palette = options
		else
			palette = required
		end
	end

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

	local amount = config.darken
	if config.darken == 1 then
		amount = 0
	end

	local generated = {
		dark = {
			background_0 = lighten(palette.dark.background, 1 + amount * -0.3),
			background_1 = lighten(palette.dark.background, 10 + amount * -0.35),
			background_2 = lighten(palette.dark.background, 15 + amount * -0.40),
			background_3 = lighten(palette.dark.background, 17.5 + amount * -0.45),

			foreground_0 = darken(palette.dark.foreground, 00),
			foreground_1 = darken(palette.dark.foreground, 60),
			foreground_2 = darken(palette.dark.foreground, 90),
			foreground_3 = darken(palette.dark.foreground, 120),
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

	-- Core
	local red = palette[variant].red
	local green = palette[variant].green
	local yellow = palette[variant].yellow
	local blue = palette[variant].blue
	local purple = palette[variant].purple
	local accent = palette[variant].accent or palette[variant].blue
	local none = "none"

	local highlights = {
		-- Built-in: Statusline
		Statusline = { bg = none, fg = foreground_2, gui = none },
		StatuslineNC = { bg = none, fg = foreground_3, gui = none },

		-- Built-in:
		CursorLineNr = { bg = background_3 },
		LineNr = { bg = none },
		SignColumn = { bg = none },
		VertSplit = { bg = background_1, fg = background_1 },

		NormalFloat = { bg = background_1, fg = foreground_1 },
		FloatBorder = { bg = background_1, fg = foreground_1 },

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
		TelescopeSelection = { bg = accent, fg = is_light(background_3, accent, 150) },
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

	local function add_highlights(tbl_1, tbl_2)
		for k, v in pairs(tbl_1) do
			tbl_2[k] = v
		end
	end

	-- add_highlights(highlights)

	if config.background then
		add_highlights(background, highlights)
	end

	if config.transparent then
		add_highlights(transparent, highlights)
	end

	if config.sign_column then
		add_highlights(sign_column, highlights)
	end

	if config.popup_menu then
		add_highlights(popup_menu, highlights)
	end

	local custom_highlights = {}

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

	local function apply_highlights(highlights_tbl)
		for k, v in pairs(highlights_tbl) do
			local hl = k

			if v.links == nil then
				if v.bg ~= nil then
					hl = hl .. " guibg=" .. v.bg
				end

				if v.fg ~= nil then
					hl = hl .. " guifg=" .. v.fg
				end

				if v.gui ~= nil then
					hl = hl .. " gui=" .. v.gui
				end

				if v.guisp ~= nil then
					hl = hl .. " guisp=" .. v.guisp
				end

				vim.cmd("hi " .. hl)
			else
				vim.cmd("hi! link " .. hl .. " " .. v.links)
			end
		end
	end

	-- This needs to get initalized before custom highlights are APPLIED

	-- vim.g.accent = accent

	apply_highlights(highlights)

	if config["*"] then
		add_highlights(config["*"], custom_highlights)
	end

	if palette.custom then
		add_highlights(palette.custom, custom_highlights)
	end

	apply_highlights(custom_highlights)

	if pcall(require, "nvim-web-devicons") then
		require("nvim-web-devicons").set_up_highlights()
	end

	pcall(vim.api.nvim_del_augroup_by_id, 7)
	local group = vim.api.nvim_create_augroup("UpdateColors", { clear = true })

	-- vim.api.nvim_del_augroup_by_id(group)
	autocmd("ColorScheme, VimEnter", {
		desc = "Reset highlights on save",
		group = group,
		callback = function()
			M.setup(options)
		end,
	})

	config.on_change()
end

return M
