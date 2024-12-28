const std = @import("std");

pub fn run(gpa_alloc: std.mem.Allocator) !u8 {
    _ = gpa_alloc;
    std.debug.print("duration.zig run\n", .{});
    return 0;
}
