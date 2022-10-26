# ------------------------------------------------
# Generic Mermaid to SVG/PNG/PDF Makefile
# ------------------------------------------------

MERMAID_ARGS := -t dark

SRCDIR   := diagrams
DGRDIR   := diagrams/build

SOURCES  := $(shell find $(SRCDIR) -type f -name '*.mmd')

SVGS     := $(patsubst $(SRCDIR)/%.mmd,$(DGRDIR)/%.mmd.svg,$(SOURCES))

.PHONY: all clean
default: all

all: $(SVGS)

live:
	$(MAKE)
	open $(SVGS) || xdg-open $(SVGS)
	echo $(SOURCES) | entr $(MAKE)

clean:
	rm -rf $(DGRDIR)

$(DGRDIR):
	mkdir -p $(DGRDIR)

$(SVGS): $(DGRDIR)/%.mmd.svg : $(SRCDIR)/%.mmd | $(DGRDIR)
	docker run -it --rm -v `pwd`:/data -u `id -u ${USER}`:`id -g ${USER}` minlag/mermaid-cli -i /data/$< -o /data/$@ $(MERMAID_ARGS)
