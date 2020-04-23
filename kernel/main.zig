const builtin = @import("builtin");
const term = @import("term.zig");
const tboot = @import("tboot/tboot.zig");
const memory_structures = @import("memory_structures.zig");
const palloc = @import("bootstrap_drivers/palloc.zig");
const build_param = @import("builtin_parameters.zig");
const video = @import("bootstrap_drivers/video.zig");

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined; // because, lets face it, we kinda need a stack for our big beautiful kernel.
const stack_bytes_slice = stack_bytes[0..];

export fn _start(magic: u32, info: [*c]tboot.tboot_info) callconv(.Naked) noreturn { // check if we received the EFI information structure, if we did, launch the kernel on the new stack.
    if (magic == tboot.magic)
        @call(.{ .stack = stack_bytes_slice }, kmain, .{info});
    while (true) {}
}

pub fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace) noreturn { // Does what it can : in case of caught runtime errors by zig, it goes there instead of, ya know, creating an interrupt.
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
    var pixels = @intToPtr([*]volatile Color, info.*.frmb_address); // get an array of the pixels from the address given by the EFI information structure

    var pixnum: u64 = (info.*.frmb_height) *% (info.*.frmb_pitch); // get the number of pixels (as the are all 32 bits encoded, we can easily get the bytesize of the framebuffer)

    video.screen.width = info.*.frmb_width;
    video.screen.height = info.*.frmb_height;
    video.screen.pitch = info.*.frmb_pitch;

    var page_allocator: palloc.pallocator = palloc.pallocator.init(info.*.mmap_entries, info.*.mmap_count); // initialize a page allocator with the memory map given by the EFI information structure

    var chatimgraw = @embedFile("../../logo_chat.bmp");
    var chat: video.Sprite = video.Sprite.from_bitmap(chatimgraw[0..], 100, 100);
    var chatdat = chat.pixels;

    var resp: u64 = 0;
    while (resp < (build_param.KERNEL_RESERVED / 0x1000)) : (resp += 1) { // reserve pages for kernel code
        page_allocator.preserve(resp);
    }
    var interpixaddr = page_allocator.palloc((pixnum >> 10) + 1);
    var interpix = @ptrCast([*]volatile Color, interpixaddr); // allocate pages for the second buffer (double buffering) (10 = 12 - 2, 12 for page, 2 because pixnum is in pixels of 4 bytes)

    video.screen.pixels = @ptrCast([*]volatile video.Color, interpixaddr);
    video.screen.pixelsraw = @ptrCast([*]volatile u32, @alignCast(4, interpixaddr));

    var spd: u64 = 0;
    var delayer: u64 = 0;
    while (true) { // main loop
        if (true) {
            var i: u64 = 0;
            while (i < pixnum) : (i += 1) { // funky colors YAY
                interpix[i] = Color{ .R = 0, .G = 0, .B = 0, .A = 0 };
            }

            {
                var ro: u64 = 0;
                while (ro < 10) : (ro += 1) {
                    var co: u64 = 0;
                    while (co < 10) : (co += 1) {
                        if ((@intCast(i64, ro) - 5) * (@intCast(i64, ro) - 5) +
                            (@intCast(i64, co) - 5) * (@intCast(i64, co) - 5) <= 24)
                        {
                            interpix[((spd + co) % info.*.frmb_width) + ro * info.*.frmb_pitch] = Color{ .R = 255, .G = 255, .B = 255, .A = 255 };
                        }
                    }
                }
            }
            {
                video.screen.draw_sprite(chat, (video.screen.width / 2) - 50, (video.screen.height / 2) - 50);
                for (term.terminal.characters.spr) |charspr, n| {
                    video.screen.draw_sprite(charspr, @intCast(u32, n * 11), 20);
                }
            }
        }
        var cop: u64 = 0;
        while (cop < pixnum) : (cop += 1) { // copy the second buffer to the memory mapped buffer
            pixels[cop] = interpix[cop];
        }
        delayer += 1;
        if (delayer > 2) { // slow the band, it moves too fast, sometimes.
            spd += 1;
            delayer = 0;
        }
        spd %= info.*.frmb_width;
    }
    term.terminal.buffer = @ptrCast([*]volatile u8, pixels); // in case something goes wrong and the loop breaks, it tries to display something.
    term.terminal.initialize();
    term.terminal.write("ZZZZ0000    ZZZZ0000");
}
