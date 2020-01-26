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
    var pixels = @intToPtr([*]Color, info.*.framebuffer.address);
    pixels[0] = Color{ .B = 255, .G = 255, .R = 255, .A = 0 };
    pixels[1] = Color{ .B = 255, .G = 255, .R = 255, .A = 255 };
    pixels[2] = Color{ .B = 255, .G = 0, .R = 0, .A = 0 };
    pixels[3] = Color{ .B = 255, .G = 0, .R = 0, .A = 255 };
    pixels[4] = Color{ .B = 0, .G = 255, .R = 0, .A = 0 };
    pixels[5] = Color{ .B = 0, .G = 255, .R = 0, .A = 255 };
    pixels[6] = Color{ .B = 0, .G = 0, .R = 255, .A = 0 };
    pixels[7] = Color{ .B = 0, .G = 0, .R = 255, .A = 255 };
    term.terminal.initialize();
    term.terminal.write("Hello, kernel World!");
}
