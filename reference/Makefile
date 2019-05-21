# ------------------------------------------------
# Generic C Makefile
# ------------------------------------------------

TARGET   := prog
SRCDIR   := src
OBJDIR   := bin
BINDIR   := bin

WARNINGS := \
	-Wall -Wextra -Wpedantic -Werror \
	-Wlogical-op -Waggregate-return -Wfloat-equal -Wcast-align \
	-Wparentheses -Wmissing-braces -Wconversion -Wsign-conversion \
	-Wwrite-strings -Wunknown-pragmas -Wunused-macros \
	-Wnested-externs -Wpointer-arith -Wswitch -Wredundant-decls \
	-Wreturn-type -Wshadow -Wstrict-prototypes -Wunused -Wuninitialized \
	-Wdeclaration-after-statement -Wmissing-prototypes \
	-Wmissing-declarations -Wundef -fstrict-aliasing -Wstrict-aliasing=3 \
	-Wformat=2 -Wsuggest-attribute=pure -Wsuggest-attribute=const

CC       := gcc
CFLAGS   := -std=c99 $(WARNINGS) -I.

LINKER   := gcc
LFLAGS   := $(WARNINGS) -I.

SOURCES  := $(wildcard $(SRCDIR)/*.c)
INCLUDES := $(wildcard $(SRCDIR)/*.h)
OBJECTS  := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SOURCES))

.PHONY: all clean compile
default: all

all: $(BINDIR)/$(TARGET)

compile: $(OBJECTS)

clean:
	rm -f $(OBJECTS) $(BINDIR)/$(TARGET)

$(BINDIR)/$(TARGET): $(OBJECTS)
	mkdir -p $(BINDIR)
	$(LINKER) $(OBJECTS) $(LFLAGS) -o $@

$(OBJECTS): $(OBJDIR)/%.o : $(SRCDIR)/%.c
	mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@
