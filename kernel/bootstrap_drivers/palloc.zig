const tboot = @import("../tboot/tboot.zig");
const build_param = @import("../builtin_parameters.zig");

pub const page_metadata = packed struct { // page metadata : stores page data on 1 byte.
    owned: u1,
    allocatable: u1,
    other: u6,
};

pub const pallocator = struct {
    bitmap: [*]page_metadata,
    maxpage: u64,
    pub fn init(memsegs: [*c]tboot.mmap_entry, count: u64) pallocator {
        var maxpage = ((memsegs[count - 1].address + memsegs[count - 1].length) >> 12) - 1; // get the number of pages included in the memory : note, we may lose 1 page but 4 KB is nothing.
        var obitmap = @intToPtr([*]page_metadata, 1); // initialize it : there is a check later to see if this was changed.
        var j: u64 = 0;
        while (j < count) : (j += 1) { // go through each memory segment
            if (memsegs[j].mtype == tboot.MEMORY_TYPE.USABLE and memsegs[j].length > build_param.KERNEL_RESERVED and memsegs[j].length - build_param.KERNEL_RESERVED > maxpage + 1) { // can it have both the kernel and the page "bitmap" ?
                obitmap = @intToPtr([*]page_metadata, memsegs[j].address + build_param.KERNEL_RESERVED); // foudn where we are going to put our page bitmap
                var k: u64 = memsegs[j].address >> 12;

                while (k < ((memsegs[j].address + build_param.KERNEL_RESERVED + memsegs[j].length) >> 12 + 1) and k < maxpage) : (k += 1) { // reserve the pages in which the bitmap is going to be
                    obitmap[k] = page_metadata{ .owned = 0, .allocatable = 0, .other = 1 };
                }
            }
        }
        if (@ptrToInt(obitmap) != 1) { // if we found somewhere to put our bitmap
            if (false) { // doesn't work, IDK why
                var pg: u64 = 0; // initialise it
                while (pg < maxpage) : (pg += 1) {
                    if (obitmap[pg].other == 0)
                        obitmap[pg] = page_metadata{ .owned = 0, .allocatable = 0, .other = 2 };
                }
            }
            var i: u64 = 0;
            while (i < count) : (i += 1) { // go through each segment
                if (memsegs[i].mtype == tboot.MEMORY_TYPE.USABLE) { // if it is usable, update the bitpap so the corresponding pages can be allocated
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
        while (i < self.maxpage) : (i += 1) { //go through each page
            if (self.bitmap[i].allocatable == 1 and self.bitmap[i].owned == 0) { //when it finds somewhere free
                if (free_until == false) { // if it is the first free page after a sequence of occupied pages, start counting
                    free_until = true;
                    current = i;
                } else if (i - current >= n) { // if we have enough pages
                    var k: u64 = current;
                    while (k < i) : (k += 1) { // allocate them.
                        self.bitmap[i] = page_metadata{ .allocatable = 1, .other = 0, .owned = 1 };
                    }
                    return @intToPtr([*]u8, current << 12);
                }
            } else {
                free_until = false;
            }
        } // ne free page was found -> panic
        unreachable;
    }
    pub fn preserve(self: pallocator, page: u64) void { // TODO : make it return a boolean (true if it managed to reserve, false otherwise)
        var reqpage: page_metadata = self.bitmap[page];
        if (reqpage.allocatable == 1 and reqpage.owned == 0 and reqpage.other == 0) { // reserves the page if it's free, otherwise do nothing
            self.bitmap[page] = page_metadata{ .allocatable = 1, .other = 0, .owned = 1 };
        }
    }
};
