# ------------------------------------------------
# Generic C Makefile
# ------------------------------------------------

TARGET   = prog
SRCDIR   = src
OBJDIR   = bin
BINDIR   = bin

CC       = gcc
CFLAGS   = -std=c99 -Wall -I.

LINKER   = gcc
LFLAGS   = -Wall -I. -lm

SOURCES  := $(wildcard $(SRCDIR)/*.c)
INCLUDES := $(wildcard $(SRCDIR)/*.h)
OBJECTS  := $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

.PHONY: all clean compile
default: all

all: $(BINDIR)/$(TARGET)

compile: $(OBJECTS)

clean:
	rm -rf $(OBJDIR)
	rm -rf $(BINDIR)

$(BINDIR)/$(TARGET): $(OBJECTS)
	mkdir -p $(BINDIR)
	$(LINKER) $(OBJECTS) $(LFLAGS) -o $@

$(OBJECTS): $(OBJDIR)/%.o : $(SRCDIR)/%.c
	mkdir -p $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@
