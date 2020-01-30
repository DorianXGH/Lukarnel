const builtin = @import("builtin");
const term = @import("term.zig");
const tboot = @import("tboot/tboot.zig");
const memory_structures = @import("memory_structures.zig");

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
    var pixels = @intToPtr([*]volatile Color, info.*.frmb_address);

    var pixelsraw = @intToPtr([*]volatile u32, info.*.frmb_address);

    var pixnum: u64 = (info.*.frmb_height) *% (info.*.frmb_pitch);

    var spd: u64 = 0;
    while (true) {
        var i: u64 = 0;
        while (i < pixnum) : (i += 1) {
            pixels[i] = Color{ .R = @intCast(u8, (i * i) % 256), .G = @intCast(u8, (i * i * i + 76) % 256), .B = @intCast(u8, (i + 164) % 256), .A = 0 };
        }

        var ro: u64 = 0;
        while (ro < 400) : (ro += 1) {
            var co: u64 = 0;
            while (co < 100) : (co += 1) {
                pixels[spd + (co % info.*.frmb_width) + ro * info.*.frmb_pitch] = Color{ .R = 0, .G = 0, .B = 0, .A = 0 };
            }
        }
        ro = 0;
        while (ro < 400) : (ro += 1) {
            var co: u64 = 0;
            while (co < 100) : (co += 1) {
                pixels[spd + (co % info.*.frmb_width) + ro * info.*.frmb_pitch] = Color{ .R = 0, .G = 0, .B = 0, .A = 0 };
            }
        }
        spd += 1;
        spd %= info.*.frmb_width;
    }
    pixels[200] = Color{ .B = 255, .G = 255, .R = 0, .A = 0 };
    pixels[201] = Color{ .B = 255, .G = 0, .R = 255, .A = 0 };
    pixels[202] = Color{ .B = 255, .G = 255, .R = 0, .A = 0 };
    pixels[203] = Color{ .B = 255, .G = 0, .R = 255, .A = 0 };
    term.terminal.buffer = @intToPtr([*]volatile u8, @ptrToInt(pixels));
    term.terminal.initialize();
    term.terminal.write("ZZZZ0000    ZZZZ0000");
}
