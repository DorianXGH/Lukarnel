TARGET := -target x86_64-freestanding --release-safe
SOURCES := $(shell find $(SOURCEDIR) -name '*.c')

build/lukarnel.elf: kernel/main.zig $(SOURCES)
	zig build-exe $< $(TARGET) --name lukarnel.elf --output-dir build