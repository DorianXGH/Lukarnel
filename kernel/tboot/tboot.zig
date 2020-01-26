const builtin = @import("builtin");
pub const MAGIC = 0xCAFEBABE;
pub const MEMORY_TYPE = enum {
    RESERVED = 0,
    BAD_MEMORY = 1,
    ACPI_RECLAIMABLE = 2,
    USABLE = 3,
    ACPI_NVS = 4,
    _,
};

pub const mmap_entry = packed struct {
    memtype: u32,
    address: u64,
    length: u64,
};

pub const module_entry = packed struct {
    base: u64,
    length: u64,
    name: [*c]u8, // c pointer : bad, but not much choice
};

pub const features = packed union {
    flags: packed struct {
        memmap: u1,
        framebuffer: u1,
        cmdline: u1,
        modules: u1,
        tsc_freq: u1,
        rsdp: u1,
    },
    raw: u64,
};
