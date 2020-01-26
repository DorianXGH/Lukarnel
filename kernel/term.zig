const builtin = @import("builtin");
// Hardware text mode color constants
const VgaColor = u8;
const VGA_COLOR_BLACK = 0;
const VGA_COLOR_BLUE = 1;
const VGA_COLOR_GREEN = 2;
const VGA_COLOR_CYAN = 3;
const VGA_COLOR_RED = 4;
const VGA_COLOR_MAGENTA = 5;
const VGA_COLOR_BROWN = 6;
const VGA_COLOR_LIGHT_GREY = 7;
const VGA_COLOR_DARK_GREY = 8;
const VGA_COLOR_LIGHT_BLUE = 9;
const VGA_COLOR_LIGHT_GREEN = 10;
const VGA_COLOR_LIGHT_CYAN = 11;
const VGA_COLOR_LIGHT_RED = 12;
const VGA_COLOR_LIGHT_MAGENTA = 13;
const VGA_COLOR_LIGHT_BROWN = 14;
const VGA_COLOR_WHITE = 15;

fn vga_entry_color(fg: VgaColor, bg: VgaColor) u8 {
    return fg | (bg << 4);
}

fn vga_entry(uc: u8, color: u8) u16 {
    return u16(uc) | (u16(color) << 8);
}

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

pub const terminal = struct {
    var row = usize(0);
    var column = usize(0);
    var color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);

    const buffer = @intToPtr([*]volatile u16, 0xB8000);

    pub fn initialize() void {
        var y = usize(0);
        while (y < VGA_HEIGHT) : (y += 1) {
            var x = usize(0);
            while (x < VGA_WIDTH) : (x += 1) {
                putCharAt(' ', color, x, y);
            }
        }
    }

    pub fn setColor(new_color: u8) void {
        color = new_color;
    }

    pub fn putCharAt(c: u8, new_color: u8, x: usize, y: usize) void {
        const index = y * VGA_WIDTH + x;
        buffer[index] = vga_entry(c, new_color);
    }

    pub fn putChar(c: u8) void {
        putCharAt(c, color, column, row);
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
