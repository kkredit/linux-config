# ------------------------------------------------
# Generic Go Makefile
# ------------------------------------------------

SRCDIR   := .
BINDIR   := bin

SOURCES  := $(wildcard $(SRCDIR)/*.go)
BINARIES := $(patsubst $(SRCDIR)/%.go,$(BINDIR)/%,$(SOURCES))

.PHONY: all clean

all: $(BINARIES)

clean:
	rm -rf $(BINDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

$(BINARIES): $(BINDIR)/% : $(SRCDIR)/%.go | $(BINDIR)
	go build -o $@ $<
