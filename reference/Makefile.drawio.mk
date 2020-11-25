
DIAGRAM_DIR := .
BUILD_DIR := build

SOURCES := $(wildcard $(DIAGRAM_DIR)/*.drawio)
DIAGRAMS := $(patsubst $(DIAGRAM_DIR)/%.drawio,$(BUILD_DIR)/%.png,$(SOURCES))

.PHONY: clean
.PHONY: default
.PHONY: all

default: all
all: $(DIAGRAMS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.png: $(DIAGRAM_DIR)/%.drawio | $(BUILD_DIR)
	drawio --export $< --format png --scale 2.0 --embed-dragram -o $@

clean:
	rm -f $(DIAGRAMS)
