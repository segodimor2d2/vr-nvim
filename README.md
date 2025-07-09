# VR NVIM

Plugin for neovim to use VR 


FloatermNew

voldikss/vim-floaterm

---
```lua
lua vim.cmd("FloatermNew --height=0.6 --width=0.6 --wintype=float --position=center")
lua vim.cmd("FloatermSend nvim")
lua vim.opt.relativenumber = false
lua vim.opt.number = false
lua vim.cmd('set numberwidth=20')
lua vim.cmd("term") -- abra terminal
lua vim.cmd("vsplit") -- split da tela
lua vim.cmd("windo diffthis") -- compare os lados
lua vim.cmd("wincmd w") -- foco para a primeira janela
lua vim.cmd("startinsert") -- modo insert
lua vim.cmd("FloatermSend tmux")
```
---

```lua

local M = {}

local log_path = os.getenv("HOME") .. "/vrlog.txt"
local log_buf = nil
local log_timer = nil
local log_process = nil

-- Namespace para o cursor visual
local ns_id = vim.api.nvim_create_namespace("vr_cursor")

-- Define grupos de highlight para cursor falso
vim.cmd("highlight FakeCursor guibg=#FFD700 guifg=black gui=bold")
vim.cmd("highlight FakeCursorFocus guibg=#00FF00 guifg=black gui=bold")

-- Atualiza o "cursor visual" com highlight personalizado em todas janelas com mesmo buffer
local function update_fake_cursor()
  local cur_win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(cur_win)
  local row = cursor[1] - 1
  local col = cursor[2]

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if buf == cur_buf then
      vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

      local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
      local line_len = vim.fn.strdisplaywidth(line)
      local hl_group = (win == cur_win) and "FakeCursorFocus" or "FakeCursor"

      if col < line_len then
        -- Quando há caractere visível
        vim.api.nvim_buf_add_highlight(buf, ns_id, hl_group, row, col, col + 1)
      else
        -- Cursor além do fim da linha: simula com virtual text
        vim.api.nvim_buf_set_extmark(buf, ns_id, row, col, {
          virt_text = { { " ", hl_group } },
          virt_text_pos = "overlay",
          hl_mode = "combine",
        })
      end

      vim.api.nvim_win_call(win, function()
        vim.cmd("redraw")
      end)
    end
  end
end

-- AutoCmd para atualizar o cursor visual
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  callback = update_fake_cursor,
})

-- Atualiza o buffer do log (não usado nesse modo)
local function update_log_buffer()
  if log_buf and vim.api.nvim_buf_is_valid(log_buf) then
    local f = io.open(log_path, "r")
    if not f then return end
    local lines = {}
    for line in f:lines() do table.insert(lines, line) end
    f:close()
    vim.api.nvim_buf_set_lines(log_buf, 0, -1, false, lines)
  end
end

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

local function run_log_writer(script_path)
  log_process = vim.loop.spawn("lua", {
    args = { script_path },
    stdio = {nil, nil, nil},
    detached = true
  }, function(code, signal)
    print("VR log process exited:", code, signal)
  end)
end

function M.run_floating_terminal()
  local buf = vim.api.nvim_create_buf(false, true)

  local width = math.floor(vim.o.columns * 0.6)
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

  vim.cmd("startinsert")

  -- Aguarda e executa nvim
  vim.defer_fn(function()
    vim.fn.chansend(term_job_id, "nvim\n")
  end, 3000)
end

M.floatView = function()
  vim.cmd("enew")
  vim.cmd("term")
  vim.cmd("startinsert")
  local buf = vim.api.nvim_get_current_buf()

  vim.cmd("vsplit")
  local win_right = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win_right, buf)

  -- Sincroniza rolagem e cursor
  vim.cmd("windo set scrollbind")
  vim.cmd("windo set cursorbind")
  vim.cmd("windo normal! G")
  vim.cmd("windo normal! zz")
  vim.cmd("redraw!")

  -- Força foco na janela da esquerda
  local wins = vim.api.nvim_tabpage_list_wins(0)
  vim.api.nvim_set_current_win(wins[1])

  -- Ativa cursorline para ambas as janelas
  vim.cmd("windo set cursorline")

  -- Atualiza cursor falso em ambas janelas
  update_fake_cursor()

  print("🟢 VR duplicado: mesmo terminal nos dois lados!")
end

M.stop = function()
  if log_timer then
    log_timer:stop()
    log_timer:close()
    log_timer = nil
  end

  vim.cmd("windo stopinsert")
  vim.cmd("windo bdelete!")
  log_buf = nil

  print("🔴 VR OFF: terminal e log encerrados")
end

M.setup = function()
  vim.keymap.set("n", "<leader>ee", M.run_floating_terminal, { desc = "VR On" })
  vim.keymap.set("n", "<leader>er", M.floatView, { desc = "VR FloatView (Lua)" })
  vim.keymap.set("n", "<leader>ew", M.stop, { desc = "VR FloatView Off" })

  -- Atualização inicial do cursor falso
  vim.defer_fn(update_fake_cursor, 100)
end

return M

```

---

```lua

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

M.floatView = function()
  -- Limpa log antigo
  os.remove(log_path)

  -- Gera script
  local script_path = write_lua_script()

  -- Inicia processo de log
  run_log_writer(script_path)

  -- Cria janela da direita com buffer de log
  vim.cmd("vsplit")
  log_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, log_buf)

  -- Configura visual sincronizado
  vim.cmd("windo set scrollbind")
  vim.cmd("windo set cursorbind")
  vim.cmd("windo set cursorline")
  vim.cmd("windo set signcolumn=yes")

  -- Volta para a esquerda e inicia terminal interativo
  vim.cmd("wincmd h")
  vim.cmd("term")
  vim.cmd("startinsert")

  -- Inicia timer de atualização
  log_timer = vim.loop.new_timer()
  log_timer:start(1000, 1000, vim.schedule_wrap(update_log_buffer))

  print("🟢 VR ON: terminal interativo + log em tempo real")
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

  print("🔴 VR OFF: terminal e log encerrados")
end

M.setup = function()
  vim.keymap.set("n", "<leader>ee", M.floatView, { desc = "VR FloatView (Lua)" })
  vim.keymap.set("n", "<leader>er", M.stop, { desc = "VR FloatView Off" })
end

return M

```



---

```lua
local M = {}

M.floatView = function()
  -- Configuração visual global
  vim.opt.relativenumber = false
  vim.opt.number = false
  vim.opt.numberwidth = 2

  -- Abre terminal na janela atual
  vim.cmd("term")

  -- Cria split vertical
  vim.cmd("vsplit")

  -- Na janela da direita, cria um novo buffer
  vim.cmd("enew")

  -- Sincroniza rolagem e cursor (entre terminal e buffer normal)
  vim.cmd("windo set cursorline")
  vim.cmd("windo set scrollbind")
  vim.cmd("windo set cursorbind")
  vim.cmd("windo set signcolumn=yes")

  -- Foco de volta à esquerda (janela do terminal)
  vim.cmd("wincmd h")
  vim.cmd("startinsert")

  print("VR floatView ON: terminal + buffer sincronizados!")
end

M.run = function()
  vim.cmd("FloatermNew --height=0.6 --width=0.6 --wintype=float --position=center --name=vrterminal nvim")
  print("VR is On!")
end

M.stop = function()
  vim.cmd("FloatermKill! vrterminal")
  vim.cmd("FloatermHide! vrterminal")
  print("VR is Off!")
end

M.setup = function()
  vim.keymap.set("n", "<leader>ee", M.run, { desc = "VR On" })
  vim.keymap.set("n", "<leader>er", M.floatView, { desc = "VR FloatView" })
  vim.keymap.set("n", "<leader>ew", M.stop, { desc = "VR Off" })
end

return M



```

---



# Tutor Termux

repo: https://bitbucket.org/segodimo/minitutor/src/main/

ref: https://wiki.termux.com/wiki/Terminal_Settings

### video
### https://youtu.be/cpjX6sr1FjI?feature=shared

[Clique para assistir ao vÃ­deo](https://www.youtube.com/watch?v=cpjX6sr1FjI){:target="_blank"}

<iframe width="560" height="315" src="https://www.youtube.com/embed/cpjX6sr1FjI?si=XRsnga-Z0BVlz8cR" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>


## 01 Termux F-Droid Install

> https://f-droid.org/en/

> pkg upgrade

## 02 Termux Python Install

> pkg install python3

https://wiki.termux.com/wiki/Python

## 03 Termux Neovim Install (editor de cÃ³digo)

> pkg install neovim

## 04 Termux Tmux multiplexer

> pkg install tmux

c-b "

c-b %

## 05 Git

> pkg install git

## 06 Termux Custom Keyboard

> git clone https://segodimo@bitbucket.org/segodimo/minitutor.git

veja o arquivo termux.properties

> nvim .termux/termux.properties

copiando termux.properties do minituto para .termux assim:

> cp termux.properties .termux/termux.properties

Para fazer reolad do termux use:

> termux-reload-settings

## 07 Termux zsh ohMyZsh autosuggtions Install (custom  terminal)
### https://ohmyz.sh/

> pkg install zsh

> sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

entre en la carpeta plugins, si no existen hay que crearlas 

> cd .oh-my-zsh/custom/plugins

> git clone https://github.com/zsh-users/zsh-autosuggestions

user source para fazer reload do zshrc

> source .zshrc



