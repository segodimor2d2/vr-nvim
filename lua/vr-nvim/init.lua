local M = {}

M.run = function()
  vim.opt.relativenumber = false
  vim.opt.number = false
  vim.cmd('set numberwidth=20')
  vim.cmd("term") -- abra terminal
  vim.cmd("vsplit") -- split da tela
  vim.cmd("wincmd w") -- foco para a primeira janela
  vim.cmd("windo diffthis") -- compare os lados
  vim.cmd("startinsert") -- modo insert
  print("VR is On!")
end

M.stop = function()
  vim.cmd("windo diffoff") -- off compare
  vim.cmd("q")  -- ou vim.cmd("quit")
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.cmd('set numberwidth=4')
  vim.cmd("stopinsert")
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
