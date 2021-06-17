# ------------------------------------------------
# Generic Markdown to PDF Makefile
# ------------------------------------------------

SRCDIR   := .
PDFDIR   := pdfs

SOURCES  := $(shell find $(SRCDIR) -type f -name '*.md')
PDFS     := $(patsubst $(SRCDIR)/%.md,$(PDFDIR)/%.pdf,$(SOURCES))
PDF_DIRS := $(shell dirname $(PDFS) | sort -u)

.PHONY: all clean
default: all

all: $(PDFS)

clean:
	rm -rf $(PDFDIR)

$(PDF_DIRS):
	mkdir -p $(PDF_DIRS)

$(PDFS): $(PDFDIR)/%.pdf : $(SRCDIR)/%.md | $(PDF_DIRS)
	pandoc -f gfm -s -V geometry:margin=1in -o "$@" <<<`sed 's/.md/.pdf/g' $<`
