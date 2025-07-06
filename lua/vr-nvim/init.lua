local M = {}

M.run = function()
  print("VR run")
  vim.opt.relativenumber = false
  vim.opt.number = false
  vim.cmd('set numberwidth=20')
end


M.stop = function()
  print("VR stop")
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.cmd('set numberwidth=4')
end

M.setup = function()

	vim.keymap.set("n", "<leader>fvv", function()
		M.run()
	end, { desc = "on VR" })

	vim.keymap.set("n", "<leader>fvs", function()
		M.stop()
	end, { desc = "off VR" })

end

return M
