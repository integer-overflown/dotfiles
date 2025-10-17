NVIM_CONFIG_DIR := $(HOME)/.config/nvim
NVIM_CONFIG_SRC := $(PWD)/nvim

TMUX_CONFIG_SRC := $(PWD)/tmux
TMUX_CONFIG_DIR := $(HOME)/.config/tmux

install:
	@if ! command -v wmctrl >/dev/null 2>&1; then \
		echo "Error: wmctrl is not installed. Please run 'sudo apt install wmctrl' and try again."; \
		exit 1; \
	fi

	ln -sfT $(NVIM_CONFIG_SRC) $(NVIM_CONFIG_DIR)
	ln -sfT $(TMUX_CONFIG_SRC) $(TMUX_CONFIG_DIR)
	ln -sfT $(PWD)/alacritty $(HOME)/.config/alacritty
	ln -sfT $(PWD)/direnv $(HOME)/.config/direnv

	./configure-git

	mkdir -p ~/.local/bin

	cp focus-alacritty ~/.local/bin/

uninstall:
	rm $(NVIM_CONFIG_DIR)
	rm $(TMUX_CONFIG_DIR)
