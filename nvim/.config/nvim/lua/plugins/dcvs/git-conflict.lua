-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ akinsho/git-conflict.nvim                                                    │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'akinsho/git-conflict.nvim', -- visualize and resolve git conflicts
    config=function()
        local status, git_conflict = pcall(require, 'git-conflict')
        if (not status) then return end
        git_conflict.setup()
    end}
