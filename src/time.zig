const std = @import("std");
const zeit = @import("zeit");

// TODO:timezome

const Record = struct {
    timestamp: i64,
    content: []u8,
    is_rest: bool,
};

pub fn getLocalDate() ![]u8 {
    const alloc = std.heap.page_allocator;
    var env = std.process.EnvMap.init(alloc);
    defer env.deinit();

    const local = try zeit.local(alloc, &env);
    defer local.deinit();

    const now_local = (try zeit.instant(.{})).in(&local);

    var buffer: [32]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const dt = now_local.time();
    try dt.strftime(stream.writer(), "%Y-%m-%d %H:%M:%S");

    const result = try alloc.dupe(u8, stream.getWritten());
    return result;
}

test "simple test" {
    const result = try getLocalDate();
    std.debug.print("sdas .{s}\n", .{result});
}
