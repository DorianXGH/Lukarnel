const builtin = @import("builtin");
const video = @import("bootstrap_drivers/video.zig");

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

pub const terminal = struct {
    var row = @intCast(usize, 0);
    var column = @intCast(usize, 0);

    pub const characters = struct {
        pub var A = @embedFile("../font/A.bmp");
        pub var B = @embedFile("../font/B.bmp");
        pub var C = @embedFile("../font/C.bmp");
        pub var D = @embedFile("../font/D.bmp");
        pub var E = @embedFile("../font/E.bmp");
        pub var F = @embedFile("../font/F.bmp");
        pub var G = @embedFile("../font/G.bmp");
        pub var H = @embedFile("../font/H.bmp");
        pub var spr = [_]video.Sprite{
            video.Sprite.from_bitmap(A[0..], 11, 20),
            video.Sprite.from_bitmap(B[0..], 11, 20),
            video.Sprite.from_bitmap(C[0..], 11, 20),
            video.Sprite.from_bitmap(D[0..], 11, 20),
            video.Sprite.from_bitmap(E[0..], 11, 20),
            video.Sprite.from_bitmap(F[0..], 11, 20),
            video.Sprite.from_bitmap(G[0..], 11, 20),
            video.Sprite.from_bitmap(H[0..], 11, 20),
        };
    };

    pub var buffer = @intToPtr([*]volatile u8, 0xB8000);

    pub fn initialize() void {
        var y = @intCast(usize, 0);
        while (y < VGA_HEIGHT) : (y += 1) {
            var x = @intCast(usize, 0);
            while (x < VGA_WIDTH) : (x += 1) {
                putCharAt(' ', x, y);
            }
        }
    }

    pub fn putCharAt(c: u8, x: usize, y: usize) void {
        const index = y * VGA_WIDTH + x;
        buffer[index] = c;
    }

    pub fn putChar(c: u8) void {
        putCharAt(c, column, row);
        column += 1;
        if (column == VGA_WIDTH) {
            column = 0;
            row += 1;
            if (row == VGA_HEIGHT)
                row = 0;
        }
    }

    pub fn write(data: []const u8) void {
        for (data) |c|
            putChar(c);
    }
};
