# ------------------------------------------------
# Generic Rust Makefile
# ------------------------------------------------

SRCDIR   := .
BINDIR   := bin

SOURCES  := $(wildcard $(SRCDIR)/*.rs)
BINARIES := $(patsubst $(SRCDIR)/%.rs,$(BINDIR)/%,$(SOURCES))

.PHONY: all clean

all: $(BINARIES)

clean:
	rm -rf $(BINDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

$(BINARIES): $(BINDIR)/% : $(SRCDIR)/%.rs | $(BINDIR)
	rustc -o $@ $<
