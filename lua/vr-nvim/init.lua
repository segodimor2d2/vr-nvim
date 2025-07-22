local M = {}

local log_path = os.getenv("HOME") .. "/vrlog.txt"
local log_buf = nil
local log_timer = nil
local log_process = nil

-- Função que atualiza o buffer do log
local function update_log_buffer()
  if log_buf and vim.api.nvim_buf_is_valid(log_buf) then
    local f = io.open(log_path, "r")
    if not f then return end

    local lines = {}
    for line in f:lines() do
      table.insert(lines, line)
    end
    f:close()

    vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, lines)
  end
end

-- Gera o script Lua que grava no log
local function write_lua_script()
  local script = [[
    local log = assert(io.open("]] .. log_path .. [[", "a"))
    while true do
      log:write(os.date("%Y-%m-%d %H:%M:%S"), " VR running...\n")
      log:flush()
      os.execute("sleep 1")
    end
  ]]
  local script_path = os.getenv("HOME") .. "/.vr_writer.lua"
  local f = io.open(script_path, "w")
  f:write(script)
  f:close()
  return script_path
end

-- Executa script de log em segundo plano
local function run_log_writer(script_path)
  log_process = vim.loop.spawn("lua", {
    args = { script_path },
    stdio = {nil, nil, nil},
    detached = true
  }, function(code, signal)
    print("VR log process exited:", code, signal)
  end)
end

M.stylecursor = function()
  vim.cmd('set numberwidth=8')
end

M.style = function()
  local is_loaded = package.loaded["lualine"]

  if is_loaded then
    package.loaded["lualine"] = nil       -- descarrega o módulo
    vim.opt.laststatus = 0                -- oculta statusline
    vim.cmd("redrawstatus!")
    -- print("⛔ Lualine desativado (visual)")
  else
    require("lazy").load({ plugins = { "nvim-lualine/lualine.nvim" } })
    vim.opt.laststatus = 3                -- exibe statusline
    vim.cmd("redrawstatus!")
    -- print("✅ Lualine ativado")
  end
end

function M.run_floating_terminal()
  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * 0.5)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  }

  vim.api.nvim_open_win(buf, true, opts)

  -- Abre terminal com shell
  local term_job_id = vim.fn.termopen(os.getenv("SHELL") or "sh")

  -- Modo de inserção
  vim.cmd("startinsert")

  -- Aguarda 500ms e executa 'nvim' no terminal
  vim.defer_fn(function()
    vim.fn.chansend(term_job_id, "nvim\n")
  end, 3000)

  vim.defer_fn(function()
    vim.fn.chansend(term_job_id, ",es")
  end, 4000)

  vim.defer_fn(function()
    vim.fn.chansend(term_job_id, ",er")
  end, 6000)

  vim.defer_fn(function()
    vim.fn.chansend(term_job_id, "ii\n")
  end, 7000)
end

M.floatView = function()
  -- Abre terminal na esquerda
  vim.cmd("enew")           -- novo buffer vazio
  vim.cmd("term")           -- abre terminal
  vim.cmd("startinsert")    -- já começa no modo de inserção

  -- Salva o buffer do terminal
  local buf = vim.api.nvim_get_current_buf()

  -- Cria vsplit e coloca mesmo buffer na direita
  vim.cmd("vsplit")
  local win_right = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win_right, buf)

  -- Sincroniza visualmente
  vim.cmd("windo set scrollbind")
  vim.cmd("windo set cursorbind")
  vim.cmd("windo normal! G")
  vim.cmd("windo normal! zz")
  vim.cmd("redraw!")

  -- Volta pro terminal à esquerda
  vim.cmd("wincmd h")

  -- print("🟢 VR duplicado: mesmo terminal nos dois lados!")
end




M.stop = function()
  -- Para timer
  if log_timer then
    log_timer:stop()
    log_timer:close()
    log_timer = nil
  end

  -- Fecha buffers
  vim.cmd("windo stopinsert")
  vim.cmd("windo bdelete!")

  -- Remove variáveis
  log_buf = nil

  -- (Opcional) Restaurar guicursor padrão
  vim.opt.guicursor = "n-v-c:block"
  vim.cmd("highlight Cursor guibg=NONE guifg=NONE")

  -- vim.cmd("windo ,q")
  -- print("🔴 VR OFF: terminal e log encerrados")
end

M.setup = function()
  vim.keymap.set("n", "<leader>ee", M.run_floating_terminal, { desc = "VR On" })
  vim.keymap.set("n", "<leader>er", M.floatView, { desc = "VR FloatView (Lua)" })
  vim.keymap.set("n", "<leader>ew", M.stop, { desc = "VR FloatView Off" })
  vim.keymap.set("n", "<leader>es", M.style, { desc = "VR Style" })
  vim.keymap.set("n", "<leader>ed", M.stylecursor, { desc = "VR Cursor" })
end

return M
