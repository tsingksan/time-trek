const std = @import("std");
const Allocator = std.mem.Allocator;

const zeit = @import("zeit");

const action = @import("./cli.zig");
const record = @import("./record.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const detectedAction = try action.Action.detectCLI(alloc);
    if (detectedAction) |a| {
        _ = try a.run(alloc);
    }

    try record.run(alloc);
}

test {
    _ = @import("./cli.zig");
    _ = @import("./record.zig");
}

// stdout is for the actual output of your application, for example if you
// are implementing gzip, then only the compressed bytes should be sent to
// stdout, not any debugging messages.
// const stdout_file = std.io.getStdOut().writer();

// var bw = std.io.bufferedWriter(stdout_file);
// const stdout = bw.writer();

// try stdout.print("Run `zig build test` to run the tests.\n", .{});

// try bw.flush(); // don't forget to flush!
