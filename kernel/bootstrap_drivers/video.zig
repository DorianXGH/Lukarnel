const build_param = @import("../builtin_parameters.zig");

pub const Color = packed struct {
    B: u8,
    G: u8,
    R: u8,
    A: u8,
};

pub const screen = struct {
    pub var width: u32 = 0;
    pub var height: u32 = 0;
    pub var pitch: u32 = 0;
    pub var pixelsraw: [*]volatile u32 = @intToPtr([*]volatile u32, 4);
    pub var pixels: [*]volatile Color = @intToPtr([*]volatile Color, 4);
    pub fn draw_sprite(spr: Sprite, x: u32, y: u32) void {
        var ro: u64 = 0;
        while (ro < spr.height) : (ro += 1) {
            var co: u64 = 0;
            while (co < spr.width) : (co += 1) {
                pixels[((co + x) % width) + (ro + y) * pitch] = Color{
                    .R = spr.pixels[(co % spr.width + (spr.height - 1 - ro) * spr.width) * 4 + 2],
                    .G = spr.pixels[(co % spr.width + (spr.height - 1 - ro) * spr.width) * 4 + 1],
                    .B = spr.pixels[(co % spr.width + (spr.height - 1 - ro) * spr.width) * 4 + 0],
                    .A = 0,
                };
            }
        }
    }
};

pub const Sprite = struct {
    pub const bitmap_offset_offset: u32 = 0x000A;
    width: u32 = 0,
    height: u32 = 0,
    pixels: []const u8,
    pub fn from_bitmap(rawbitmap: []const u8, w: u32, h: u32) Sprite {
        var offsetimg: u32 = 0;
        var in: u5 = 0;
        while (in < 4) : (in += 1) {
            var byteoff: u5 = in;
            var bitoff: u5 = byteoff * 8;
            offsetimg += @intCast(u32, rawbitmap[bitmap_offset_offset + in]) << bitoff;
        }
        var dat = rawbitmap[offsetimg..];
        return Sprite{ .width = w, .height = h, .pixels = dat };
    }
};
