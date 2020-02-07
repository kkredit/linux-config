# ------------------------------------------------
# Generic Haskell Makefile
# ------------------------------------------------

SRCDIR   := .
BINDIR   := bin

SOURCES  := $(wildcard $(SRCDIR)/*.hs)
BINARIES := $(patsubst $(SRCDIR)/%.hs,$(BINDIR)/%,$(SOURCES))

.PHONY: all clean

all: $(BINARIES)

clean:
	rm -rf $(BINDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

$(BINARIES): $(BINDIR)/% : $(SRCDIR)/%.hs | $(BINDIR)
	ghc -outputdir $(BINDIR) -o $@ $<
