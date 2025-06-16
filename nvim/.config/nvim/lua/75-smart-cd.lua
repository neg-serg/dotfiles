local M = {}

-- Extended list of project root indicators
local PROJECT_INDICATORS = {
  -- Version control
  '.git',
  '.hg',
  '.svn',
  '.fossil',
  
  -- Language/framework specific
  'package.json',    -- Node.js
  'pyproject.toml',  -- Python
  'setup.py',        -- Python
  'requirements.txt',-- Python
  'go.mod',          -- Go
  'Cargo.toml',      -- Rust
  'mix.exs',         -- Elixir
  'project.clj',     -- Clojure
  'build.gradle',    -- Java
  'pom.xml',         -- Java
  'composer.json',   -- PHP
  'Gemfile',         -- Ruby
  
  -- Build systems
  'Makefile',
  'CMakeLists.txt',
  'Rakefile',
  
  -- Config files
  '.projectroot',
  '.gitignore',
  'README.md',
  'LICENSE',
  
  -- IDE/Editor specific
  '.idea',
  '.vscode',
  '.nvim.project'
}

-- Find project root based on indicators
local function find_project_root(start_path)
  local path = start_path
  local last_path = nil
  
  -- Walk up the directory tree
  while path ~= last_path do
    -- Check all project indicators
    for _, indicator in ipairs(PROJECT_INDICATORS) do
      local found = vim.fn.glob(path .. '/' .. indicator)
      if found ~= '' then
        return path
      end
    end
    
    last_path = path
    path = vim.fn.fnamemodify(path, ':h')
  end
  
  return nil
end

-- Smart directory changing function
function M.smart_cd()
  local file_path = vim.fn.expand('%:p')
  local current_dir = vim.fn.getcwd()
  
  -- For empty buffers
  if file_path == "" then
    print("No file in buffer - using current dir: " .. current_dir)
    return
  end
  
  local file_dir = vim.fn.expand('%:p:h')
  local project_root = find_project_root(file_dir)
  
  -- Decision logic for target directory
  local target_dir = current_dir
  local reason = ""
  
  if project_root then
    -- Case 1: If we're not in project root, go there
    if not string.find(current_dir, project_root, 1, true) then
      target_dir = project_root
      reason = "project root"
    -- Case 2: If we're in project root, go to file's directory
    else
      target_dir = file_dir
      reason = "file directory (inside project)"
    end
  else
    -- Case 3: No project found, go to file's directory
    target_dir = file_dir
    reason = "file directory (no project found)"
  end
  
  -- Don't change if already in target directory
  if target_dir == current_dir then
    print("Already in correct directory: " .. target_dir)
    return
  end
  
  -- Perform directory change
  vim.cmd('cd ' .. vim.fn.fnameescape(target_dir))
  print("Changed directory to " .. reason .. ": " .. target_dir)
  
  -- Refresh UI elements
  if package.loaded['heirline'] or package.loaded['lualine'] then
    vim.cmd('redrawstatus')
  end
end

-- Setup key mapping
function M.setup()
  vim.api.nvim_set_keymap('n', 'et',
    '<cmd>lua require"75-smart-cd".smart_cd()<CR>',
    { noremap = true, silent = true, desc = "Smart directory change" }
  )
end

return M
