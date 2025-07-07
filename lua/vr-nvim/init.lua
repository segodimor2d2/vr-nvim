local M = {}

M.sleep = function(ms, callback)
  vim.defer_fn(function()
    callback()
  end, ms)
end

M.run = function()
  -- vim.opt.relativenumber = false
  -- vim.opt.number = false
  -- vim.cmd('set numberwidth=20')
  vim.cmd("term") -- abra terminal
  vim.cmd("vsplit") -- split da tela
  vim.cmd("windo diffthis") -- compare os lados
  vim.cmd("wincmd w") -- foco para a primeira janela
  vim.cmd("startinsert") -- modo insert
  print("VR is On!")
  -- vim.cmd("FloatermNew --height=0.6 --width=0.6 --wintype=float --position=center")
  -- vim.cmd("FloatermSend nvim")
  -- vim.cmd("FloatermSend :NVRon")
  -- vim.cmd("FloatermSend tmux")
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
