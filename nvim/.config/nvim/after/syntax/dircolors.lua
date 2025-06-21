-- Файл: ~/.config/nvim/after/syntax/dircolors.lua
local ns = vim.api.nvim_create_namespace('dircolors_hi')
local buf = vim.api.nvim_get_current_buf()

-- Очистка предыдущей подсветки
vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

-- Регистрация файлового типа
vim.cmd([[
  augroup dircolors_ft
    au!
    au BufRead,BufNewFile .dircolors,*.dircolors,dircolors.*,LS_COLORS set filetype=dircolors
  augroup END
]])

-- Группы подсветки
local groups = {
  ['dircolorsComment'] = 'Comment',
  ['dircolorsKey'] = 'Identifier',
  ['dircolorsPattern'] = 'Type',
  ['dircolorsCodes'] = 'String',
  ['dircolorsCodePart'] = 'Constant',
}

-- Определение стилей групп
for group, link in pairs(groups) do
  vim.api.nvim_set_hl(0, group, { link = link })
end

-- Основная функция подсветки
local function highlight_dircolors()
  local start_time = vim.loop.hrtime()
  local line_count = vim.api.nvim_buf_line_count(buf)
  
  for i = 0, line_count - 1 do
    local line = vim.api.nvim_buf_get_lines(buf, i, i+1, true)[1]
    if not line then break end
    
    -- Комментарии
    local comment_start, comment_end = line:find('#.*')
    if comment_start then
      vim.api.nvim_buf_add_highlight(buf, ns, 'dircolorsComment', i, comment_start - 1, comment_end)
    end
    
    -- Ключи и значения
    local key_start, key_end, key = line:find('^%s*([^%s=]+)')
    if key_start then
      -- Ключ
      vim.api.nvim_buf_add_highlight(buf, ns, 'dircolorsKey', i, key_start - 1, key_end)
      
      -- Шаблоны (*.ext)
      if key:find('^%*%.') then
        local pat_start, pat_end = line:find('%*%.[^%s=]+')
        if pat_start then
          vim.api.nvim_buf_add_highlight(buf, ns, 'dircolorsPattern', i, pat_start - 1, pat_end)
        end
      end
      
      -- Значения (коды)
      local value_start, value_end, codes = line:find('=%s*([^%s#]+)')
      if value_start then
        vim.api.nvim_buf_add_highlight(buf, ns, 'dircolorsCodes', i, value_start - 1, value_end)
        
        -- Отдельные части кодов
        local col = value_start
        for num in codes:gmatch('%d+') do
          local num_start = codes:find(num, col - value_start + 1)
          if num_start then
            num_start = num_start + value_start - 1
            vim.api.nvim_buf_add_highlight(buf, ns, 'dircolorsCodePart', i, num_start - 1, num_start + #num - 1)
            col = num_start + #num
          end
        end
      end
    end
  end
  
  local elapsed = (vim.loop.hrtime() - start_time) / 1e6
  print(string.format('Dircolors highlighting applied in %.2f ms', elapsed))
end

-- Инициализация
if vim.bo.filetype == 'dircolors' then
  highlight_dircolors()
end

-- Автоматическое применение при изменениях
vim.api.nvim_create_autocmd({'BufEnter', 'TextChanged', 'TextChangedI'}, {
  buffer = buf,
  callback = highlight_dircolors,
  desc = 'Update dircolors highlighting'
})
