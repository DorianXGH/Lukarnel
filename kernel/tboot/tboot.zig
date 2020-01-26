const builtin = @import("builtin");
pub const magic = 0xCAFEBABE;
pub const MEMORY_TYPE = enum(u32) {
    RESERVED = 0,
    BAD_MEMORY = 1,
    ACPI_RECLAIMABLE = 2,
    USABLE = 3,
    ACPI_NVS = 4,
    _,
};

pub const mmap_entry = packed struct {
    mtype: MEMORY_TYPE,
    address: u64,
    length: u64,
};

pub const module_entry = packed struct {
    base: u64,
    length: u64,
    name: [*c]u8, // c pointer : bad, but not much choice
};

pub const tboot_info = packed struct {
    features: packed union {
        flags: packed struct {
            mmap: u1,
            framebuffer: u1,
            cmdline: u1,
            modules: u1,
            tsc_freq: u1,
            rsdp: u1,
        },
        raw: u64,
    },

    mmap: packed struct {
        count: u64,
        entried: [*c]mmap_entry,
    },

    framebuffer: packed struct {
        address: u64,
        width: u32,
        height: u32,
        pitch: u32,
    },

    cmdline: packed struct {
        length: u32,
        cmdline: [*c]u8, // c pointer : bad, but not much choice
    },

    modules: packed struct {
        count: u64,
        entries: [*c]module_entry,
    },

    tsc_freq: u64,
    rsdp: u64,
};
