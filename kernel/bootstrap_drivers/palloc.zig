const tboot = @import("../tboot/tboot.zig");

pub const page_metadata = packed struct {
    free: u1,
    allocatable: u1,
    other: u6,
};

pub const pallocator = struct {
    bitmap: [*]page_metadata,
    maxpage: u64,
    pub fn init(self: pallocator, memsegs: [*c]tboot.mmap_entry, count: u64) void {
        maxpage = (memsegs[count - 1].address + memsegs[count - 1].length) >> 12 - 1;

        var j: u64 = 0;
        while (j < count) : (j += 1) {
            if (memsegs[j].mtype == MEMORY_TYPE.USABLE and memsegs[j].length > maxpage + 1) {
                var k: u64 = memsegs[j].address >> 12 + 1;
                while (k < (memsegs[j].address + memsegs[j].address) >> 12 - 1 and k < maxpage) {
                    bitmap[k].other = 1;
                }
            }
        }

        var i: u64 = 0;
        while (i < count) : (i += 1) {
            if (memsegs[i].mtype == MEMORY_TYPE.USABLE) {
                var k: u64 = memsegs[i].address >> 12 + 1;
                while (k < (memsegs[i].address + memsegs[i].address) >> 12 - 1 and k < maxpage) {
                    if (bitmap[k].other == 0)
                        bitmap[k].allocatable = 1;
                }
            }
        }
    }
    pub fn palloc(self: pallocator, n: u64) [*]u8 {
        var i: u64 = 0;
        var current: u64 = 0;
        var free_until: bool = false;
        while (i < maxpage) : (i += 1) {
            if (bitmap[i].allocatable == 1 and bitmap[i].free == 0) {
                if (free_until == false) {
                    free_until = true;
                    current = i;
                } else if (i - current >= n) {
                    return @intToPtr([*]u8, current << 12);
                }
            } else {
                free_until = false;
            }
        }
        unreachable;
    }
};
