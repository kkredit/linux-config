# ------------------------------------------------
# Generic C Makefile
# ------------------------------------------------

TARGET   := prog
SRCDIR   := src
OBJDIR   := bin
BINDIR   := bin
INSTDIR  := ~/.local/bin

# NOTE: use of `shell` is not cross-platform friendly
SOURCES  := $(shell find $(SRCDIR) -type f -name '*.c')
INC_DIRS := $(shell find $(SRCDIR) -type f -name '*.h' | xargs dirname | uniq)
INCLUDES := $(foreach DIR,$(INC_DIRS),-I$(DIR) )
OBJECTS  := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SOURCES))
OBJ_DIRS := $(shell echo $(OBJECTS) | xargs dirname | uniq)

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

# NOTE: not currently used
OTHER_OPTS := -msign-return-address

CC       := gcc
DEFINES  := # -D_GNU_SOURCE
CFLAGS   := -std=c99 $(DEFINES) $(INCLUDES) $(WARNINGS)

LINKER   := gcc
LIBS     := # -lm
LFLAGS   := $(LIBS) $(WARNINGS)


.PHONY: all clean compile install
default: all

all: $(BINDIR)/$(TARGET)

compile: $(OBJECTS)

clean:
	rm -rf $(BINDIR) $(OBJDIR)

install: $(BINDIR)/$(TARGET)
	mkdir -p $(INSTDIR)
	cp $(BINDIR)/$(TARGET) $(INSTDIR)/$(TARGET)

$(BINDIR):
	mkdir -p $(BINDIR)

$(OBJ_DIRS):
	mkdir -p $(OBJ_DIRS)

$(BINDIR)/$(TARGET): $(OBJECTS) | $(BINDIR)
	$(LINKER) $(OBJECTS) $(LFLAGS) -o $@

$(OBJECTS): $(OBJDIR)/%.o : $(SRCDIR)/%.c | $(OBJ_DIRS)
	$(CC) $(CFLAGS) -c $< -o $@
