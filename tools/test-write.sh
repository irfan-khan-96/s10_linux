#!/bin/sh
# Run on the phone (after copying pkg/write.lua to ~/.cache): headless test of the writing
# start screen, today's journal and search, in a throwaway home folder.
T=/tmp/wtest; rm -rf $T; mkdir -p $T/notes/journal
printf '# Old day\n\nhello\n' > $T/notes/journal/2026-11-01.md
printf '# Ideas for the S10\n\nfoo bar (with brackets)\n' > $T/notes/ideas.md
export HOME=$T NVIM_APPNAME=s10-write-test
W=/home/farmer/.cache/write.lua
timeout 20 nvim --headless -u $W -c 'set columns=48' -c 'doautocmd VimEnter' \
  -c 'lua for _, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do print(l) end' \
  -c 'lua print("STATUS:" .. S10Status())' \
  -c 'lua S10Today(); print("TODAY:" .. vim.fn.expand("%:p") .. " | " .. vim.fn.getline(1))' \
  -c 'lua vim.cmd([[silent! vimgrep /\c\V(with/j ]] .. vim.fn.expand("~/notes") .. "/**/*.md"); print("HITS:" .. #vim.fn.getqflist())' \
  -c 'qa!' 2>&1
echo
ls -R $T/notes
rm -rf $T
