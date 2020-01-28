const builtin = @import("builtin");
const term = @import("term.zig");
const tboot = @import("tboot/tboot.zig");

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export fn _start(magic: u32, info: [*c]tboot.tboot_info) callconv(.Naked) noreturn {
    if (magic == tboot.magic)
        @newStackCall(stack_bytes_slice, kmain, info);
    while (true) {}
}

pub fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace) noreturn {
    @setCold(true);
    var pixels = @intToPtr([*]volatile Color, @ptrToInt(term.terminal.buffer));
    pixels[200 + 640 * 6] = Color{ .B = 255, .G = 0, .R = 255, .A = 0 };
    term.terminal.write("A000A000A0000000000000000000000");
    //term.terminal.write(msg);
    while (true) {}
}
const Color = packed struct {
    B: u8,
    G: u8,
    R: u8,
    A: u8,
};

fn draw2p(pixels: [*]volatile Color, n: u32, col: Color) void {
    pixels[2 * n + (n / 640) * 640] = col;
    pixels[2 * n + 640 + (n / 640) * 640] = col;
    pixels[2 * n + 1 + (n / 640) * 640] = col;
    pixels[2 * n + 641 + (n / 640) * 640] = col;
}

fn kmain(info: [*c]tboot.tboot_info) void {
    var pixels = @intToPtr([*]volatile Color, info.*.framebuffer.address);
    var pixelsraw = @intToPtr([*]volatile u32, info.*.framebuffer.address);

    pixels[200] = Color{ .B = 255, .G = 0, .R = 0, .A = 0 };
    pixels[201] = Color{ .B = 255, .G = 0, .R = 0, .A = 0 };

    if (info.*.framebuffer.width > 2147483648) {
        pixels[0] = Color{ .B = 255, .G = 255, .R = 255, .A = 0 };
    } else {
        pixels[0] = Color{ .B = 0, .G = 0, .R = 255, .A = 0 };
    }

    if (info.*.framebuffer.width == info.*.framebuffer.address) {
        pixels[1] = Color{ .B = 255, .G = 255, .R = 255, .A = 0 };
    } else {
        pixels[1] = Color{ .B = 0, .G = 0, .R = 255, .A = 0 };
    }

    if (info.*.features.flags.framebuffer == 1) {
        pixels[2] = Color{ .B = 255, .G = 255, .R = 255, .A = 0 };
    } else {
        pixels[2] = Color{ .B = 0, .G = 0, .R = 255, .A = 0 };
    }

    if (info.*.framebuffer.height == 480) {
        draw2p(pixels, 6, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
        draw2p(pixels, 7, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
        draw2p(pixels, 6 + 320, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
        draw2p(pixels, 7 + 320, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
    } else {
        draw2p(pixels, 6, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
        draw2p(pixels, 7, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
        draw2p(pixels, 6 + 320, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
        draw2p(pixels, 7 + 320, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
    }
    if (info.*.framebuffer.width == 640) {
        draw2p(pixels, 8, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
        draw2p(pixels, 9, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
        draw2p(pixels, 8 + 320, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
        draw2p(pixels, 9 + 320, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
    } else {
        draw2p(pixels, 8, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
        draw2p(pixels, 9, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
        draw2p(pixels, 8 + 320, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
        draw2p(pixels, 9 + 320, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
    }
    if (info.*.framebuffer.pitch == 640) {
        draw2p(pixels, 10, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
        draw2p(pixels, 11, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
        draw2p(pixels, 10 + 320, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
        draw2p(pixels, 11 + 320, Color{ .B = 255, .G = 255, .R = 255, .A = 0 });
    } else {
        draw2p(pixels, 10, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
        draw2p(pixels, 11, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
        draw2p(pixels, 10 + 320, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
        draw2p(pixels, 11 + 320, Color{ .B = 0, .G = 0, .R = 255, .A = 0 });
    }

    var dmp = @intToPtr([*]volatile u8, @ptrToInt(info));
    var k: u32 = 0;
    while (k < @bitSizeOf(tboot.tboot_info)) : (k += 1) {
        var bit: u32 = dmp[k >> 3] >> @intCast(u3, k % 8);
        bit &= 1;
        if (bit == 1) {
            pixelsraw[k + 3 * 640 + (k / 64) * (640 - 64)] = 0xFFFFFFFF;
        } else {
            pixelsraw[k + 3 * 640 + (k / 64) * (640 - 64)] = 0xFFFF0000;
        }
    }

    if (@ptrToInt(&(info.*.framebuffer.address)) == @ptrToInt(&(info.*.framebuffer.width))) {
        pixelsraw[50 * 640 + 4] = 0xFFFFFF00;
    }
    var dmpframe = @intToPtr([*]volatile u8, @ptrToInt(&(info.*.framebuffer.address)));
    var k2: u32 = 0;
    while (k2 < 32) : (k2 += 1) {
        var bit: u32 = dmpframe[k2 >> 3] >> @intCast(u3, k2 % 8);
        bit &= 1;
        if (bit == 1) {
            pixelsraw[k2 + 60 * 640 + (k2 / 64) * (640 - 64)] = 0xFFFFFFFF;
        } else {
            pixelsraw[k2 + 60 * 640 + (k2 / 64) * (640 - 64)] = 0xFF0000FF;
        }
    }

    while (true) {}
    var pixnum: u64 = (info.*.framebuffer.height) *% (info.*.framebuffer.pitch);

    pixels[200] = Color{ .B = 0, .G = 255, .R = 0, .A = 0 };
    pixels[201] = Color{ .B = 0, .G = 255, .R = 0, .A = 0 };

    var i: u64 = 0;
    while (i < pixnum) : (i += 1) {
        pixels[i] = Color{ .B = 255, .G = 255, .R = 255, .A = 0 };
    }
    pixels[200] = Color{ .B = 255, .G = 255, .R = 0, .A = 0 };
    pixels[201] = Color{ .B = 255, .G = 0, .R = 255, .A = 0 };
    pixels[202] = Color{ .B = 255, .G = 255, .R = 0, .A = 0 };
    pixels[203] = Color{ .B = 255, .G = 0, .R = 255, .A = 0 };
    term.terminal.buffer = @intToPtr([*]volatile u8, @ptrToInt(pixels));
    term.terminal.initialize();
    term.terminal.write("ZZZZ0000    ZZZZ0000");
}
