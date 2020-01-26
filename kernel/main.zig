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
    pixels[200] = Color{ .B = 0, .G = 0, .R = 255, .A = 0 };
    pixels[201] = Color{ .B = 0, .G = 0, .R = 255, .A = 255 };
    pixels[202] = Color{ .B = 0, .G = 0, .R = 255, .A = 255 };
    pixels[203] = Color{ .B = 0, .G = 0, .R = 255, .A = 0 };
    term.terminal.write("KERNEL PANIC: ");
    term.terminal.write(msg);
    while (true) {}
}
const Color = packed struct {
    B: u8,
    G: u8,
    R: u8,
    A: u8,
};
fn kmain(info: [*c]tboot.tboot_info) void {
    var pixels = @intToPtr([*]volatile Color, info.*.framebuffer.address);

    pixels[200] = Color{ .B = 255, .G = 0, .R = 0, .A = 0 };
    pixels[201] = Color{ .B = 255, .G = 0, .R = 0, .A = 0 };

    if (info.*.framebuffer.width > 2147483648) {
        pixels[0] = Color{ .B = 255, .G = 0, .R = 255, .A = 0 };
    } else {
        pixels[0] = Color{ .B = 0, .G = 0, .R = 255, .A = 0 };
    }

    if (info.*.framebuffer.width == info.*.framebuffer.address) {
        pixels[1] = Color{ .B = 255, .G = 0, .R = 255, .A = 0 };
    } else {
        pixels[1] = Color{ .B = 0, .G = 0, .R = 255, .A = 0 };
    }

    if (info.*.features.flags.framebuffer == 1) {
        pixels[2] = Color{ .B = 255, .G = 255, .R = 255, .A = 0 };
    } else {
        pixels[2] = Color{ .B = 0, .G = 0, .R = 255, .A = 0 };
    }

    var pixnum: u64 = (info.*.framebuffer.width) * (info.*.framebuffer.height);

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
    term.terminal.buffer = @intToPtr([*]volatile u16, @ptrToInt(pixels));
    term.terminal.initialize();
    term.terminal.write("Hello, kernel World!");
}
