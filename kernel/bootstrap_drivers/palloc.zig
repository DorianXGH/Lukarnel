const tboot = @import("../tboot/tboot.zig");
const build_param = @import("../builtin_parameters.zig");

pub const page_metadata = packed struct {
    owned: u1,
    allocatable: u1,
    other: u6,
};

pub const pallocator = struct {
    bitmap: [*]page_metadata,
    maxpage: u64,
    pub fn init(memsegs: [*c]tboot.mmap_entry, count: u64) pallocator {
        var maxpage = ((memsegs[count - 1].address + memsegs[count - 1].length) >> 12) - 1;
        var obitmap = @intToPtr([*]page_metadata, 1);
        var j: u64 = 0;
        while (j < count) : (j += 1) {
            if (memsegs[j].mtype == tboot.MEMORY_TYPE.USABLE and memsegs[j].length > build_param.KERNEL_RESERVED and memsegs[j].length - build_param.KERNEL_RESERVED > maxpage + 1) {
                obitmap = @intToPtr([*]page_metadata, memsegs[j].address + build_param.KERNEL_RESERVED);
                var k: u64 = memsegs[j].address >> 12;

                while (k < ((memsegs[j].address + build_param.KERNEL_RESERVED + memsegs[j].length) >> 12 + 1) and k < maxpage) : (k += 1) {
                    obitmap[k] = page_metadata{ .owned = 0, .allocatable = 0, .other = 1 };
                }
            }
        }
        if (@ptrToInt(obitmap) != 0) {
            var i: u64 = 0;
            while (i < count) : (i += 1) {
                if (memsegs[i].mtype == tboot.MEMORY_TYPE.USABLE) {
                    var k: u64 = (memsegs[i].address >> 12) + 1;
                    while (k < (((memsegs[i].address + memsegs[i].length) >> 12) - 1) and k < maxpage) : (k += 1) {
                        if (obitmap[k].other == 0)
                            obitmap[k] = page_metadata{ .owned = 0, .allocatable = 1, .other = 0 };
                    }
                }
            }
        } else {
            unreachable;
        }
        return pallocator{ .bitmap = obitmap, .maxpage = maxpage };
    }
    pub fn palloc(self: pallocator, n: u64) [*]u8 {
        var i: u64 = 0;
        var current: u64 = 0;
        var free_until: bool = false;
        while (i < self.maxpage) : (i += 1) {
            if (self.bitmap[i].allocatable == 1 and self.bitmap[i].owned == 0) {
                if (free_until == false) {
                    free_until = true;
                    current = i;
                } else if (i - current >= n) {
                    var k: u64 = current;
                    while (k < i) : (k += 1) {
                        self.bitmap[i] = page_metadata{ .allocatable = 1, .other = 0, .owned = 1 };
                    }
                    return @intToPtr([*]u8, current << 12);
                }
            } else {
                free_until = false;
            }
        }
        unreachable;
    }
    pub fn preserve(self: pallocator, page: u64) void {
        var reqpage: page_metadata = self.bitmap[page];
        if (reqpage.allocatable == 1 and reqpage.owned == 0 and reqpage.other == 0) {
            self.bitmap[page] = page_metadata{ .allocatable = 1, .other = 0, .owned = 1 };
        }
    }
};
