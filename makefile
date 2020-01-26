TARGET := -target x86_64-freestanding --release-safe
SOURCES := $(shell find $(SOURCEDIR) -name '*.c')


build/lukarnel.elf: kernel/main.zig $(SOURCES)
	zig build-exe $< $(TARGET) --name lukarnel.elf --output-dir build

pack: build/lukarnel.elf
	../mount_file.sh
	sudo cp build/lukarnel.elf ../efimount/
	../umount_file.sh

test: pack
	qemu-system-x86_64 -bios /usr/share/ovmf/x64/OVMF_CODE.fd -drive format=raw,file=../efipart -cpu host -m 2G --enable-kvm

clean:
	rm -rf build/*