ADDON_NAME := PaintItBlack
ADDON_DIR  := $(WOW_DIR)/_retail_/Interface/AddOns/$(ADDON_NAME)
SRC_DIR    := $(CURDIR)/$(ADDON_NAME)

.DEFAULT_GOAL := help
.PHONY: help install uninstall clean

help:
	@echo "Paint It Black -- WoW Addon"
	@echo ""
	@echo "Usage:"
	@echo "  make install   WOW_DIR='/path/to/World of Warcraft'"
	@echo "  make uninstall WOW_DIR='/path/to/World of Warcraft'"
	@echo ""

install:
ifndef WOW_DIR
	$(error WOW_DIR is not set. Usage: make install WOW_DIR=/path/to/world of warcraft)
endif
	@test -d "$(WOW_DIR)/_retail_/Interface/AddOns" || \
		(echo "Error: AddOns directory not found at $(WOW_DIR)/_retail_/Interface/AddOns" && exit 1)
	@test ! -e "$(ADDON_DIR)" || \
		(echo "Already installed $(ADDON_DIR)" && exit 0)
	ln -s "$(SRC_DIR)" "$(ADDON_DIR)"
	@echo "Installed $(ADDON_NAME) -> $(ADDON_DIR)"

uninstall:
ifndef WOW_DIR
	$(error WOW_DIR is not set. Usage: make uninstall WOW_DIR=/path/to/world of warcraft)
endif
	@test -L "$(ADDON_DIR)" || \
		(echo "No symlink found at $(ADDON_DIR)" && exit 1)
	rm "$(ADDON_DIR)"
	@echo "Uninstalled $(ADDON_NAME)"

clean: uninstall

