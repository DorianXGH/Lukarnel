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
        var pix: [*]u32 = @intToPtr([*]u32, 0x80000000);
        pix[300] = 0x00FF0000;
        while (j < count) : (j += 1) {
            pix[400 + 2 * j] = 0x000000FF;
            pix[375] = 0x00FFFFFF;
            pix[376] = 0x00FFFFFF;
            pix[377] = 0x00FFFFFF;
            pix[378] = 0x00FFFFFF * @intCast(u32, @boolToInt(memsegs[j].length > maxpage + 1));
            pix[379] = 0x00FFFFFF;
            pix[380] = 0x00FFFFFF * @intCast(u32, @boolToInt(memsegs[j].mtype == tboot.MEMORY_TYPE.USABLE));
            pix[381] = 0x00FFFFFF;
            if (memsegs[j].mtype == tboot.MEMORY_TYPE.USABLE and memsegs[j].length > build_param.KERNEL_RESERVED and memsegs[j].length - build_param.KERNEL_RESERVED > maxpage + 1) {
                pix[302] = 0x00FF0000;
                obitmap = @intToPtr([*]page_metadata, memsegs[j].address + build_param.KERNEL_RESERVED);
                var k: u64 = memsegs[j].address >> 12;

                while (k < ((memsegs[j].address + build_param.KERNEL_RESERVED + memsegs[j].length) >> 12 + 1) and k < maxpage) : (k += 1) {
                    if ((k % 600) < 300) {
                        pix[400 + 2 * j] = 0x00FFFFF8F;
                        pix[400 + 800 + 2 * j] = 0x00FFFFF8F;
                    } else {
                        pix[400 + 2 * j] = 0x00FFFF00;
                        pix[400 + 800 + 2 * j] = 0x00FFFF00;
                    }
                    obitmap[k] = page_metadata{ .owned = 0, .allocatable = 0, .other = 1 };
                    pix[401 + 2 * j] = @intCast(u32, k);
                }
            }
            pix[401 + 2 * j] = 0x000000FF;
        }
        pix[301] = 0x0000FF00;
        pix[201] = 0x0000FF00;
        pix[202] = 0x0000FF00;
        pix[203] = 0x0000FF00;
        if (@ptrToInt(obitmap) != 0) {
            pix[701] = 0x0000FF00;
            pix[702] = 0x0000FF00;
            pix[703] = 0x0000FF00;
            pix[704] = 0x0000FF00;
            var i: u64 = 0;
            while (i < count) : (i += 1) {
                pix[710] = 0x00FFFFFFF;
                if (memsegs[i].mtype == tboot.MEMORY_TYPE.USABLE) {
                    pix[714 + 3 * i] = 0x00FFFFFFF;
                    var k: u64 = (memsegs[i].address >> 12) + 1;
                    pix[715 + 3 * i] = 0x00FFFFFFF * @intCast(u32, @boolToInt(k < (((memsegs[i].address + memsegs[i].length) >> 12) - 1)));
                    while (k < (((memsegs[i].address + memsegs[i].length) >> 12) - 1) and k < maxpage) : (k += 1) {
                        pix[716 + 3 * i] = 0x00FF00FFF;
                        if (obitmap[k].other == 0)
                            obitmap[k] = page_metadata{ .owned = 0, .allocatable = 1, .other = 0 };
                    }
                }
            }
            pix[1400] = 0x00FFFF00;
            pix[1401] = 0x00FFFFFF;
        } else {
            pix[701] = 0x00FF0000;
            pix[702] = 0x00FF0000;
            pix[703] = 0x00FF0000;
            pix[704] = 0x00FF0000;
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
};
