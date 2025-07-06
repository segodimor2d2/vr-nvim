local M = {}

M.run = function()
  print("VR run")
end


M.stop = function()
  print("VR stop")
end

M.setup = function()

	vim.keymap.set("n", "<leader>fvv", function()
		M.run()
	end, { desc = "on VR" })

	vim.keymap.set("n", "<leader>fvs", function()
		M.run()
	end, { desc = "off VR" })

end

return M
