local M = {}

M.sleep = function(ms, callback)
  vim.defer_fn(function()
    callback()
  end, ms)
end

M.run = function()
  vim.cmd("FloatermNew --height=0.6 --width=0.6 --wintype=float --position=center")
  vim.cmd("wincmd w") -- foco para a primeira janela
  vim.cmd("FloatermSend nvim")
  vim.cmd("stopinsert")
  vim.cmd("wincmd w") -- foco para a primeira janela
  -- vim.opt.relativenumber = false
  -- vim.opt.number = false
  -- vim.cmd("wincmd w") -- foco para a primeira janela
  -- vim.cmd("wincmd w") -- foco para a primeira janela
  M.sleep(3000, function()
    -- vim.cmd("stopinsert")
    vim.cmd("vsplit") -- split da tela
    print("oioioioi")
  end)
  -- vim.cmd('set numberwidth=20')
  -- vim.cmd("term") -- abra terminal
  -- vim.cmd("windo diffthis") -- compare os lados
  -- vim.cmd("wincmd w") -- foco para a primeira janela
  -- vim.cmd("startinsert") -- modo insert
  -- vim.cmd("FloatermSend tmux")
  -- vim.cmd("nvim")
  print("VR is On!")
end

M.stop = function()
  -- vim.opt.number = true
  -- vim.opt.relativenumber = true
  -- vim.cmd('set numberwidth=4')
  vim.cmd("windo diffoff") -- off compare
  vim.cmd("stopinsert")
  vim.cmd("bd!")  -- 'bd' = 'bdelete', e o '!' força o fechamento
  print("VR is Off!")
end

M.setup = function()
	vim.keymap.set("n", "<leader>fvv", function()
		M.run()
	end, { desc = "VrOn" })
	vim.keymap.set("n", "<leader>fvs", function()
		M.stop()
	end, { desc = "VrOff" })
end

return M
