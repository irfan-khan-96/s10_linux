-- s10-write: distraction-free writing in Neovim on the S10 terminal (amber, offline, no plugins).
-- Loaded with `nvim -u` by s10-write, so the normal Neovim setup is untouched.
-- Start screen: t today's journal, n new note, / search, 1-9 recent pieces, q quit.
-- While writing: Space h back to the start screen, Space s spell check on/off,
-- Space c centred column on/off, Space w word count.
-- Text autosaves when you stop typing, leave insert mode or switch away; :q leaves.
-- All writing lives in ~/notes, the journal in ~/notes/journal (one file per day).

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
  if vim.b.s10_start then return "  write  ·  ~/notes" end
  if vim.bo.buftype == "quickfix" then return "  search results  ·  Enter opens" end
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

-- one place for all writing: start screen, today's journal, new notes, search, recent pieces
local NOTES = vim.fn.expand("~/notes")
local JOURNAL = NOTES .. "/journal"
local spell_on = true

local function open(path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  vim.wo.spell = spell_on
  vim.cmd("normal! G$")
end

_G.S10Today = function()
  vim.fn.mkdir(JOURNAL, "p")
  local path = JOURNAL .. "/" .. os.date("%Y-%m-%d") .. ".md"
  if vim.fn.filereadable(path) == 0 then
    vim.fn.writefile({ "# " .. os.date("%A %d %B %Y"), "" }, path)
  end
  open(path)
end

local function slug(title)
  local s = title:lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
  return s:sub(1, 50)
end

local function new_note()
  vim.ui.input({ prompt = "Title: " }, function(title)
    if not title or title:match("^%s*$") then return end
    local base = slug(title)
    if base == "" then base = os.date("%Y-%m-%d-%H%M") end
    local path, n = NOTES .. "/" .. base .. ".md", 2
    while vim.fn.filereadable(path) == 1 do
      path, n = NOTES .. "/" .. base .. "-" .. n .. ".md", n + 1
    end
    vim.fn.mkdir(NOTES, "p")
    vim.fn.writefile({ "# " .. title, "" }, path)
    open(path)
  end)
end

local function search()
  vim.ui.input({ prompt = "Search: " }, function(q)
    if not q or q == "" then return end
    vim.fn.setqflist({})
    vim.cmd("silent! vimgrep /\\c\\V" .. vim.fn.escape(q, "/\\") .. "/j " .. vim.fn.fnameescape(NOTES) .. "/**/*.md")
    if #vim.fn.getqflist() == 0 then
      vim.notify("nothing found for " .. q)
      return
    end
    vim.cmd("botright copen")
  end)
end
vim.api.nvim_create_autocmd("FileType", {          -- search results: Enter opens and closes the list
  pattern = "qf",
  callback = function(ev)
    vim.wo.spell = false
    vim.keymap.set("n", "<CR>", "<CR><Cmd>cclose<CR><Cmd>lua vim.wo.spell = " .. tostring(spell_on) .. "<CR>",
      { buffer = ev.buf })
    vim.keymap.set("n", "q", "<Cmd>cclose<CR>", { buffer = ev.buf })
  end,
})

local function title_of(path)
  local first = vim.fn.readfile(path, "", 1)[1] or ""
  local t = first:match("^#+%s*(.+)")
  return t or vim.fn.fnamemodify(path, ":t:r")
end

local function recent(n)
  local files = vim.fn.globpath(NOTES, "**/*.md", false, true)
  table.sort(files, function(a, b) return vim.fn.getftime(a) > vim.fn.getftime(b) end)
  return vim.list_slice(files, 1, n)
end

_G.S10Start = function()
  local files = recent(9)
  local width = math.min(o.columns, COLUMN) - 18
  local lines = { "", "  WRITE", "",
    "  t  today's journal   " .. os.date("%A %d %B"),
    "  n  new note",
    "  /  search all writing", "", "  recent" }
  for i, f in ipairs(files) do
    local where = f:sub(#JOURNAL + 1, #JOURNAL + 1) == "/" and f:sub(1, #JOURNAL) == JOURNAL and "journal" or "notes"
    local title = title_of(f)
    if #title > width then title = title:sub(1, width - 1) .. "…" end
    lines[#lines + 1] = string.format("  %d  %-" .. width .. "s %s", i, title, where)
  end
  if #files == 0 then lines[#lines + 1] = "     nothing yet" end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "  q  quit"

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.b[buf].s10_start = true
  vim.api.nvim_win_set_buf(0, buf)
  vim.wo.spell = false
  vim.api.nvim_win_set_cursor(0, { 4, 2 })
  local function key(lhs, fn) vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true }) end
  key("t", S10Today)
  key("n", new_note)
  key("/", search)
  key("q", function() vim.cmd("qa") end)
  for i, f in ipairs(files) do key(tostring(i), function() open(f) end) end
  key("<CR>", function()                             -- Enter on a line does what its key does
    local l = vim.api.nvim_get_current_line():match("^%s+(%S+)")
    if l == "t" then S10Today() elseif l == "n" then new_note() elseif l == "/" then search()
    elseif l == "q" then vim.cmd("qa") elseif tonumber(l) and files[tonumber(l)] then open(files[tonumber(l)]) end
  end)
  local ns = vim.api.nvim_create_namespace("s10-start")
  local function paint(row, col, group)
    vim.api.nvim_buf_set_extmark(buf, ns, row, col, { end_row = row, end_col = #lines[row + 1], hl_group = group })
  end
  paint(1, 0, "Title")                               -- WRITE
  paint(7, 0, "Comment")                             -- recent
  for i = 1, #files do                               -- where each piece lives, dimmed
    paint(7 + i, #lines[8 + i] - #(lines[8 + i]:match("%S+$")), "Comment")
  end
end

map("n", "<leader>h", function() vim.cmd("silent! update"); S10Start() end, { desc = "start screen" })
map("n", "<leader>s", function() spell_on = not spell_on; vim.wo.spell = spell_on end, { desc = "spell check on/off" })

-- no file given: the start screen
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 and not vim.g.s10_today then S10Start() end
  end,
})
