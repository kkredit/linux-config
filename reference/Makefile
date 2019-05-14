# ------------------------------------------------
# Generic C Makefile
# ------------------------------------------------

TARGET   := prog
SRCDIR   := src
OBJDIR   := bin
BINDIR   := bin

CC       := gcc
CFLAGS   := -std=c99 -Wall -I.

LINKER   := gcc
LFLAGS   := -Wall -I.

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
