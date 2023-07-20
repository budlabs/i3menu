NAME         := i3menu
VERSION      := 0.3.3
UPDATED      := 2023-07-20
CREATED      := 2018-07-21
AUTHOR       := budRich
CONTACT      := https://github.com/budlabs/i3menu
USAGE        := i3menu [OPTIONS] [-- DMENU_OPTIONS]
DESCRIPTION  := Wrapper script for dmenu(-bud) optimized for i3fyra
ORGANISATION := budlabs

MONOLITH     := _$(NAME)

.PHONY: install-dev uninstall-dev install uninstall

install-dev: $(BASE) $(NAME)
	ln -s $(realpath $(NAME)) $(PREFIX)/bin/$(NAME)
	
uninstall-dev:
	rm $(PREFIX)/bin/$(NAME) 

install: $(MONOLITH)
	install -Dm755 $(MONOLITH)  $(DESTDIR)$(PREFIX)/bin/$(NAME)

uninstall:
	[[ -f $(DESTDIR)$(PREFIX)/bin/$(NAME) ]]   && rm $(DESTDIR)$(PREFIX)/bin/$(NAME)

README.md: $(CACHE_DIR)/long_help.md $(CACHE_DIR)/help_table.txt $(wildcard $(DOCS_DIR)/readme_*) $(DOCS_DIR)/description.md
	@{
		echo '# $(NAME)'
		echo
		cat $(DOCS_DIR)/description.md
		echo
		cat $(DOCS_DIR)/readme_installation.md
		echo
		echo "## options"
		echo
		echo '```'
		cat $(CACHE_DIR)/help_table.txt
		echo '```  '
		echo
		cat $(CACHE_DIR)/long_help.md
		echo
		cat $(DOCS_DIR)/readme_links.md
	} > $@
