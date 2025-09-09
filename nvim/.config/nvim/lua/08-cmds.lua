vim.api.nvim_exec2([[
function! Redir(cmd, rng, start, end)
	for win in range(1, winnr('$'))
		if getwinvar(win, 'scratch')
			execute win . 'windo close'
		endif
	endfor
	if a:cmd =~ '^!'
		let cmd = a:cmd =~' %'
			\ ? matchstr(substitute(a:cmd, ' %', ' ' . expand('%:p'), ''), '^!\zs.*')
			\ : matchstr(a:cmd, '^!\zs.*')
		if a:rng == 0
			let output = systemlist(cmd)
		else
			let joined_lines = join(getline(a:start, a:end), '\n')
			let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
			let output = systemlist(cmd . " <<< $" . cleaned_lines)
		endif
	else
		redir => output
		execute a:cmd
		redir END
		let output = split(output, "\n")
	endif
	vnew
	let w:scratch = 1
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, output)
endfunction
]],{})

vim.api.nvim_cmd({cmd="command", args={'-bang', '-nargs=*', '-complete=file', 'E', 'e<bang>', '<args>'}}, {})
vim.api.nvim_cmd({cmd="command", args={'-bang', '-nargs=*', '-complete=file', 'Wq', 'wq<bang>', '<args>'}}, {})
vim.api.nvim_cmd({cmd="command", args={'-bang', '-nargs=*', '-complete=file', 'WQ', 'wq<bang>', '<args>'}}, {})
vim.api.nvim_cmd({cmd="command", args={'-bang', 'Q', 'q<bang>'}}, {})
vim.api.nvim_cmd({cmd="command", args={'-bang', 'QA', 'qa<bang>'}}, {})
vim.api.nvim_cmd({cmd="command", args={'-bang', 'Qa', 'qa<bang>'}}, {})
vim.api.nvim_cmd({cmd="command", args={'-nargs=1', '-complete=command', '-bar', '-range', 'Redir', 'silent', 'call', "Redir(<q-args>, <range>, <line1>, <line2>)"}}, {})
vim.api.nvim_cmd({cmd="command", args={'-range=%', 'SP', '<line1>,<line2>w', "!curl -F 'sprunge=<-' http://sprunge.us | tr -d ' ' | wl-copy"}}, {})
vim.api.nvim_cmd({cmd="command", args={'-range=%', 'IX', '<line1>,<line2>w', "!curl -F 'f:1=<-' ix.io | tr -d ' ' | wl-copy"}}, {})
vim.api.nvim_cmd({cmd="command", args={'-range=%', 'TB', '<line1>,<line2>w', "!nc termbin.com 9999 | tr -d ' ' | wl-copy"}}, {})
