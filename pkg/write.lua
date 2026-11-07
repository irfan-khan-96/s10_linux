-- s10-write: distraction-free writing in Neovim on the S10 terminal (amber, offline, no plugins).
-- Loaded with `nvim -u` by s10-write, so the normal Neovim setup is untouched.
-- Space s: spell check on/off    Space c: centred column on/off    Space w: word count
-- Text autosaves when you stop typing, leave insert mode or switch away; :q leaves.

local o, opt = vim.o, vim.opt
local COLUMN = 72                       -- text width when the screen is wide enough to centre

vim.g.mapleader = " "
vim.g.loaded_perl_provider, vim.g.loaded_python3_provider = 0, 0
vim.g.loaded_node_provider, vim.g.loaded_ruby_provider = 0, 0

-- quiet screen: no numbers, signs, ruler or tildes; one status line for everything
o.termguicolors = false                 -- fbterm: the 16 amber palette colours
o.number, o.relativenumber = false, false
o.signcolumn, o.foldcolumn = "no", "0"
o.ruler, o.showcmd = false, false
o.laststatus = 3
o.cmdheight = 1
opt.fillchars = { eob = " ", vert = " ", horiz = " ", horizup = " ", horizdown = " ", vertleft = " ", vertright = " ", verthoriz = " " }
o.shortmess = o.shortmess .. "IcF"
o.mouse = ""

-- prose: soft wrap at word boundaries, cursor kept mid-screen (typewriter scrolling)
o.wrap, o.linebreak, o.breakindent = true, true, true
o.textwidth = 0
o.scrolloff = 999
o.smoothscroll = true
o.spell = true
o.spelllang = "en"
o.spelloptions = "camel"
o.undofile = true
o.updatetime = 1500                     -- idle time before autosave
o.ignorecase, o.smartcase = true, true

-- amber: palette 7 text, 8 dim, 12 highlight, 15 bright (set by s10-term)
local function hl(group, spec) vim.api.nvim_set_hl(0, group, spec) end
local function colours()
  hl("Normal", { ctermfg = 7 })
  hl("NormalNC", { ctermfg = 7 })
  hl("NonText", { ctermfg = 0 })
  hl("EndOfBuffer", { ctermfg = 0 })
  hl("WinSeparator", { ctermfg = 0 })
  hl("StatusLine", { ctermfg = 8 })
  hl("StatusLineNC", { ctermfg = 8 })
  hl("MsgArea", { ctermfg = 8 })
  hl("ModeMsg", { ctermfg = 12 })
  hl("Visual", { ctermfg = 0, ctermbg = 8 })
  hl("Search", { ctermfg = 0, ctermbg = 12 })
  hl("IncSearch", { ctermfg = 0, ctermbg = 15 })
  hl("CurSearch", { ctermfg = 0, ctermbg = 15 })
  hl("MatchParen", { ctermfg = 15, bold = true })
  hl("Pmenu", { ctermfg = 7, ctermbg = 0 })
  hl("PmenuSel", { ctermfg = 0, ctermbg = 7 })
  hl("SpellBad", { ctermfg = 9, underline = true })
  hl("SpellCap", { ctermfg = 7 })
  hl("SpellRare", { ctermfg = 7 })
  hl("SpellLocal", { ctermfg = 7 })
  hl("Comment", { ctermfg = 8 })
  hl("Title", { ctermfg = 15, bold = true })
  for _, g in ipairs({ "@markup.heading", "@markup.heading.1.markdown", "@markup.heading.2.markdown",
                       "@markup.heading.3.markdown", "markdownH1", "markdownH2", "markdownH3" }) do
    hl(g, { ctermfg = 15, bold = true })
  end
  hl("@markup.strong", { ctermfg = 15, bold = true })
  hl("@markup.italic", { ctermfg = 12 })
  hl("@markup.quote", { ctermfg = 8 })
  hl("@markup.list", { ctermfg = 12 })
  hl("@markup.link", { ctermfg = 12 })
  hl("@markup.link.url", { ctermfg = 8 })
  hl("@markup.raw", { ctermfg = 10 })
  hl("@punctuation.special", { ctermfg = 8 })
end
colours()
vim.api.nvim_create_autocmd("ColorScheme", { callback = colours })

-- status line: file · words · saved/unsaved
local words = 0
local function count() words = vim.fn.wordcount().words end
_G.S10Status = function()
  local name = vim.fn.expand("%:t")
  if name == "" then name = "untitled" end
  local state = vim.bo.modified and "unsaved" or "saved"
  return string.format("  %s  ·  %d words  ·  %s", name, words, state)
end
o.statusline = "%{v:lua.S10Status()}"

-- autosave: whenever typing pauses, on leaving insert mode, on switching away
local function save()
  if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" and not vim.bo.readonly then
    vim.cmd("silent! update")
  end
  count()
end
vim.api.nvim_create_autocmd({ "InsertLeave", "CursorHold", "CursorHoldI", "FocusLost", "BufLeave" }, { callback = save })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, { callback = count })

-- centred column: empty side windows when the screen is wider than the text column
local pads, centred = {}, true
local function close_pads()
  for _, w in ipairs(pads) do
    if vim.api.nvim_win_is_valid(w) then pcall(vim.api.nvim_win_close, w, true) end
  end
  pads = {}
end
local function pad(side, width)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  local win = vim.api.nvim_open_win(buf, false, { split = side, width = width, win = 0 })
  vim.wo[win].winfixwidth = true
  vim.wo[win].spell = false
  vim.wo[win].cursorline = false
  table.insert(pads, win)
end
local function centre()
  close_pads()
  local spare = o.columns - COLUMN - 2    -- each side window adds a divider column
  if centred and spare >= 8 then
    local left = math.floor(spare / 2)
    pad("left", left)
    pad("right", spare - left)
  end
end
vim.api.nvim_create_autocmd("VimEnter", { callback = centre })
vim.api.nvim_create_autocmd("VimResized", { callback = centre })     -- keyboard shown/hidden, landscape
vim.api.nvim_create_autocmd("WinEnter", {                              -- never stay in a side window
  callback = function()
    if vim.tbl_contains(pads, vim.api.nvim_get_current_win()) then vim.cmd("wincmd p") end
  end,
})
vim.api.nvim_create_autocmd("QuitPre", { callback = close_pads })      -- so :q leaves at once

-- keys: move by screen line through wrapped paragraphs (also the keyboard's arrows)
local map = vim.keymap.set
map({ "n", "x" }, "j", "gj")
map({ "n", "x" }, "k", "gk")
map({ "n", "x" }, "<Down>", "gj")
map({ "n", "x" }, "<Up>", "gk")
map("i", "<Down>", "<C-o>gj")
map("i", "<Up>", "<C-o>gk")
map("n", "<leader>s", function() o.spell = not o.spell end, { desc = "spell check on/off" })
map("n", "<leader>c", function() centred = not centred; centre() end, { desc = "centred column on/off" })
map("n", "<leader>w", function()
  local wc = vim.fn.wordcount()
  print(string.format("%d words, %d characters", wc.words, wc.chars))
end, { desc = "word count" })
