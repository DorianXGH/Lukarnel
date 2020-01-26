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
pub const tboot_info = packed struct {
    pub const mmap_entry = packed struct {
        mtype: packed union {
            t: MEMORY_TYPE,
            raw: u32,
        },
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
            mmap: u1,
            framebuffer: u1,
            cmdline: u1,
            modules: u1,
            tsc_freq: u1,
            rsdp: u1,
        },
        raw: u64,
    };

    pub const mmap = packed struct {
        count: u64,
        entried: [*c]mmap_entry,
    };

    pub const framebuffer = packed struct {
        address: u64,
        width: u32,
        height: u32,
        pitch: u32,
    };

    pub const cmdline = packed struct {
        length: u32,
        cmdline: [*c]u8, // c pointer : bad, but not much choice
    };

    pub const modules = packed struct {
        count: u64,
        entries: [*c]module_entry,
    };

    pub const tsc_freq: u64;
    pub const rsdp: u64;
};
