const build_param = @import("../builtin_parameters.zig");

pub const screen = struct {
    pub var width: u32 = 0;
    pub var height: u32 = 0;
    pub var pitch: u32 = 0;
    pub var pixels: [*]volatile u32;
};

pub const sprite = struct {
    pub const bitmap_offset_offset: u32 = 0x000A;
    width: u32 = 0,
    height: u32 = 0,
    pixels: []const u8,
    pub fn from_bitmap(rawbitmap: []const u8, w: u32, h: u32) sprite {
        var offsetimg: u32 = 0;
        var in: u5 = 0;
        while (in < 4) : (in += 1) {
            var byteoff: u5 = in;
            var bitoff: u5 = byteoff * 8;
            offsetimg += @intCast(u32, rawbitmap[bitmap_offset_offset + in]) << bitoff;
        }
        var dat = rawbitmap[offsetimg..];
        return sprite{ .width = w, .height = h, .pixels = dat };
    }
};
