const builtin = @import("builtin");
const term = @import("term.zig");
const tboot = @import("tboot/tboot.zig");
const memory_structures = @import("memory_structures.zig");
const palloc = @import("bootstrap_drivers/palloc.zig");

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
    pixels[200 + 640 * 8] = Color{ .B = 255, .G = 0, .R = 255, .A = 0 };
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

fn kmain(info: [*c]tboot.tboot_info) void {
    var pixels = @intToPtr([*]volatile Color, info.*.frmb_address);

    var pixnum: u64 = (info.*.frmb_height) *% (info.*.frmb_pitch);

    var page_allocator: palloc.pallocator = palloc.pallocator.init(info.*.mmap_entries, info.*.mmap_count);

    var spd: u64 = 0;

    var resp: u64 = 0;
    while (resp < 0x400) : (resp += 1) {
        page_allocator.preserve(resp);
    }

    var interpix = @ptrCast([*]volatile Color, page_allocator.palloc(((info.*.frmb_pitch * info.*.frmb_height) >> 12) + 1));

    var delayer: u64 = 0;
    while (true) {
        if (true) {
            var i: u64 = 0;
            while (i < pixnum) : (i += 1) {
                interpix[i] = Color{ .R = @intCast(u8, (i * i) % 256), .G = @intCast(u8, (i * i * i + 76) % 256), .B = @intCast(u8, (i + 164) % 256), .A = 0 };
            }

            var ro: u64 = 0;
            while (ro < 400) : (ro += 1) {
                var co: u64 = 0;
                while (co < 100) : (co += 1) {
                    interpix[((spd + co) % info.*.frmb_width) + ro * info.*.frmb_pitch] = Color{ .R = 0, .G = 0, .B = 0, .A = 0 };
                }
            }
        }
        var cop: u64 = 0;
        while (cop < pixnum) : (cop += 1) {
            pixels[cop] = interpix[cop];
        }
        delayer += 1;
        if (delayer > 32) {
            spd += 1;
            delayer = 0;
        }
        spd %= info.*.frmb_width;
    }
    term.terminal.buffer = @ptrCast([*]volatile u8, pixels); // in case something goes wrong and the loop breaks, it tries to display something.
    term.terminal.initialize();
    term.terminal.write("ZZZZ0000    ZZZZ0000");
}
