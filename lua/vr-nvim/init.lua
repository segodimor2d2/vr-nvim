local M = {}

M.run = function()
  print("oioio")
end

M.setup = function()
	vim.keymap.set("n", "<leader>fvr", function()
		M.run()
	end, { desc = "on VR" })
end

return M
