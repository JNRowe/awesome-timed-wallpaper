SOURCES ::= $(wildcard *.moon)
TARGETS ::= $(patsubst %.moon, %.lua, $(SOURCES))
RST_SOURCES ::= $(wildcard *.rst)
RST_TARGETS ::= $(patsubst %.rst, %.html, $(RST_SOURCES))

MOONC ::= moonc
RST2HTML ::= rst2html.py

.PHONY: check clean display_sources doc

all: $(TARGETS)

doc: $(RST_TARGETS)

$(TARGETS): %.lua: %.moon
	$(MOONC) $<

$(RST_TARGETS): %.html: %.rst
	$(RST2HTML) --strict $< $@

clean:
	rm -f $(TARGETS) $(RST_TARGETS)

display_sources:
	@echo $(realpath $(SOURCES))

check: lint_config.lua
	$(MOONC) -l $(SOURCES)
