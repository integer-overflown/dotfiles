NVIM_CONFIG_DIR := $(HOME)/.config/nvim
NVIM_CONFIG_SRC := $(PWD)/nvim

TMUX_CONFIG_SRC := $(PWD)/tmux
TMUX_CONFIG_DIR := $(HOME)/.config/tmux

install:
	ln -sfT $(NVIM_CONFIG_SRC) $(NVIM_CONFIG_DIR)
	ln -sfT $(TMUX_CONFIG_SRC) $(TMUX_CONFIG_DIR)
	ln -sfT $(PWD)/alacritty $(HOME)/.config/alacritty
	ln -sfT $(PWD)/direnv $(HOME)/.config/direnv
	./configure-git

clean:
	rm $(NVIM_CONFIG_DIR)
	rm $(TMUX_CONFIG_DIR)
