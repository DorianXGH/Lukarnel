const builtin = @import("builtin");

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

pub const terminal = struct {
    var row = @intCast(usize, 0);
    var column = @intCast(usize, 0);

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
