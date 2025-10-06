NVIM_CONFIG_DIR := $(HOME)/.config/nvim
NVIM_CONFIG_SRC := $(PWD)/nvim

install:
	ln -sT $(NVIM_CONFIG_SRC) $(NVIM_CONFIG_DIR)

clean:
	rm $(NVIM_CONFIG_DIR)
