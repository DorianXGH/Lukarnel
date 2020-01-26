const builtin = @import("builtin");
const term = @import("term.zig");

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

export nakedcc fn _start() noreturn {
    @newStackCall(stack_bytes_slice, kmain);
    while (true) {}
}

pub fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace) noreturn {
    @setCold(true);
    term.terminal.write("KERNEL PANIC: ");
    term.terminal.write(msg);
    while (true) {}
}

fn kmain() void {
    term.terminal.initialize();
    term.terminal.write("Hello, kernel World!");
}
