const tboot = @import("./tboot.zig");

pub const MB2_MAGIC: u32 = 0xE85250D6;

pub const mb2_header = packed struct {
    magic: u32,
    arch: u32,
    header_len: u32,
    checksum: u32,
    pub fn mb2_header(arch: u32, header_len: u32) mb2_header {
        comptime {
            return mb2_header{
                .magic = MB2_MAGIC,
                .arch = arch,
                .header_len = header_len,
                .checksum = (0xFFFFFFFF - (MB2_MAGIC +% arch +% header_len)) + 1,
            };
        }
    }
};

pub fn mb2_ir_tag(tags: []u32) type { // make information request tag type
    comptime {
        return packed struct {
            tag_type: u16 = 1,
            flags: u16,
            size: u32 = 8 + 4 * len(tags),
            requested_info_tags: [len(tags)]u32 = tags,
        };
    }
}

pub const mb2_framebuffer_req_tag = packed struct {
    tag_type: u16 = 5,
    flags: u16,
    size: u32 = 20,
    width: u32 = 1080,
    height: u32 = 720,
    depth: u32 = 32,
};

pub const mb2_info_header = packed struct {
    total_size: u32,
    reserved: u32 = 0,
};

pub const mb2_info_tag_header = packed struct {
    tag_type: u32,
    size: u32,
};

pub const mb2_info_memmap_base = packed struct {
    tag_type: u32 = 6,
    size: u32,
    entry_size: u32 = 24,
    entry_version: u32 = 0,
    pub const mb2_info_memmap_entry = packed struct {
        base_addr: u64,
        length: u64,
        mtype: tboot.MEMORY_TYPE,
        reserved: u32 = 0,
    };
    pub fn get_entries(self: mb2_info_memmap_base) [*]mb2_info_memmap_entry {
        if (entry_version == 0) {
            return @intToPtr([*]mb2_info_memmap_entry, @ptrToInt(u64, &self) + 16);
        } else {
            unreachable;
        }
    }
    pub fn get_length(self: mb2_info_memmap_base) u64 {
        if (entry_version == 0) {
            var n: u64 = (self.size - 16) / entry_size;
            return n;
        } else {
            unreachable;
        }
    }
};
