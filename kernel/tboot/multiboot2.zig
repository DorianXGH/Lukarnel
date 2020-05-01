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

pub const mb2_ir_tag = struct {
    pub fn make_ir_tag_type(tags: [:0]u32) type { // make information request tag type
        comptime {
            return packed struct {
                tag_type: u16 = 1,
                flags: u16,
                size: u32 = 8 + 4 * len(tags),
                requested_info_tags: [len(tags)]u32 = tags,
            };
        }
    }
};
