vim.g.mapleader = ','

map('n', 'e', '[Qleader]')

Map('i', '<C-j>', '<ESC>', {nowait = true})
Map('v', '<C-j>', '<ESC>', {nowait = true})
Map('n', '<C-j>', '<C-w>j', {nowait = true})
Map('n', '<C-k>', '<C-w>k', {nowait = true})
Map('n', '<C-l>', '<C-w>l', {nowait = true})
Map('n', '<C-h>', '<C-w>h', {nowait = true})

map('n', '_', "<Cmd>exe 'e ' . getcwd()<CR>")

Map('n', 'q', '<NOP>')
Map('n', 'Q', '<NOP>')
Map('', '<F1>', '<NOP>')

map('t', '<Esc>', '<C-\\><C-n>', {silent=true}) -- Escape as normal

Map('', '<up>', '<NOP>')
Map('', '<down>', '<NOP>')
Map('', '<left>', '<NOP>')
Map('', '<right>', '<NOP>')
map('n', '<C-S-c>', '<cmd> %y+ <CR>', {silent=true})

map('n', '[Qleader]n', ':normal :<C-u>cnext<CR>', {silent=true})
map('n', '[Qleader]p', ':normal :<C-u>cprevious<CR>', {silent=true})
map('n', '[Qleader]R', ':normal :<C-u>crewind<CR>', {silent=true})
map('n', '[Qleader]N', ':normal :<C-u>cfirst<CR>', {silent=true})
map('n', '[Qleader]P', ':normal :<C-u>clast<CR>', {silent=true})
map('n', '[Qleader]l', ':normal :<C-u>clist<CR>', {silent=true})

map('n', '[Qleader]w', ':w!<cr>', {silent=true})
map('n', '[Qleader]W', ':SudaWrite<cr>', {silent=true})
map('n', '[Qleader]s', ':source %<CR>', {silent=true})
map('n', '[Qleader]u', ':Lazy update<CR>', {silent=true})
Map('n', '<C-c>', '<C-[>')
Map('i', '<C-c>', '<C-[>')
-- These create newlines like o and O but stay in normal mode
Map('n', 'zJ', 'o<Esc>k', {silent=true})
Map('n', 'zK', 'O<Esc>j', {silent=true})
-- Toggle hlsearch for current results, start highlight
map('n', ',,', ':nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<CR><C-l>')
-- Visual shifting (does not exit Visual mode)
Map('v', '<', '<gv')
Map('v', '>', '>gv')
Map('n', '<C-g>', 'g<C-g>')
-- Swap implementations of ` and ' jump to markers
-- By default, ' jumps to the marked line, ` jumps to the marked line and
-- column, so swap them
Map('n', "'", "`")
Map('n', "`", "'")
map('n', '<M-w>', ':bd<CR>', {silent=true})
Map('i', '<C-V>', '<C-R>+')
Map('c', '<C-a>', '<home>', {noremap=true})
Map('i', '<C-a>', "<C-o>^", {noremap=true})
Map('c', '<C-n>', '<down>', {noremap=true})
Map('c', '<C-p>', '<up>', {noremap=true})
Map({'c','i'}, '<C-b>', '<left>', {noremap=true})
Map({'c','i'}, '<C-d>', '<Del>', {noremap=true})
Map({'c','i'}, '<C-f>', '<right>', {noremap=true})
Map('c', '<M-f>', '<S-Right>', {noremap=true})
Map('i', '<M-f>', '<C-o>e<Right>', {noremap=true})
Map({'c','i'}, '<M-b>', '<S-Left>', {noremap=true})
Map('c', '<M-d>', '<S-Right><C-w>', {noremap=true})
Map('i', '<M-d>', '<C-o>dw', {noremap=true})
Map('o', '<M-b>', '<Left>', {noremap=true})
Map('o', '<M-e>', '<End>', {noremap=true})
Map('i', '<C-e>', "<C-o>$", {noremap=true})

map('i', '<C-v>', 'paste#paste_cmd["i"]', {expr=true})
