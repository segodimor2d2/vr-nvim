# VR NVIM

Plugin for neovim to use VR 


# Tutor Termux

repo: https://bitbucket.org/segodimo/minitutor/src/main/

ref: https://wiki.termux.com/wiki/Terminal_Settings

### video
### https://youtu.be/cpjX6sr1FjI?feature=shared

[Clique para assistir ao vÃ­deo](https://www.youtube.com/watch?v=cpjX6sr1FjI){:target="_blank"}

<iframe width="560" height="315" src="https://www.youtube.com/embed/cpjX6sr1FjI?si=XRsnga-Z0BVlz8cR" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## 01 Termux F-Droid Install

> https://f-,fdroid.org/en/

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

## 06 Termux Cusaom Keyboard

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



