SRCDIR := .
BINDIR := build

SOURCES := $(wildcard $(SRCDIR)/*.java)
CLASSES := $(patsubst $(SRCDIR)/%.java,$(BINDIR)/%.class,$(SOURCES))
MAINCLASS := Example

JAR := $(MAINCLASS).jar
TARGET := $(BINDIR)/$(JAR)
MANIFEST := META-INF/MANIFEST.MF
BIN_MANIFEST := $(BINDIR)/META-INF/MANIFEST.MF

JFLAGS := -g

$(TARGET): $(CLASSES) $(BIN_MANIFEST)
	cd $(BINDIR); jar cmvf $(MANIFEST) $(JAR) *.class

$(CLASSES): $(SOURCES)
	javac -d $(BINDIR) $(JFLAGS) $(SOURCES)

$(BIN_MANIFEST):
	mkdir -p $(BINDIR)/META-INF
	echo "Main-Class: $(MAINCLASS)" > $(BIN_MANIFEST)

run:
	java -jar $(TARGET)

clean:
	rm -r $(BINDIR)