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



