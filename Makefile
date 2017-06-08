SOURCES ::= $(wildcard *.moon)
TARGETS ::= $(SOURCES:.moon=.lua)
RST_SOURCES ::= $(wildcard *.rst)
RST_TARGETS ::= $(RST_SOURCES:.rst=.html)

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
	$(RM) $(TARGETS) $(RST_TARGETS)

display_sources:
	@echo $(realpath $(SOURCES) $(RST_SOURCES))

check: lint_config.lua
	$(MOONC) -l $(filter-out lint_config.moon, $(SOURCES))
	for f in $(RST_SOURCES); do \
	    $(RST2HTML) --strict $$f >/dev/null || exit $?; \
	done
