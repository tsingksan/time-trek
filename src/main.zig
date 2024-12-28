const std = @import("std");
const Allocator = std.mem.Allocator;

const zeit = @import("zeit");
const getLocalDate = @import("./time.zig").getLocalDate;
const action = @import("./cli.zig");

const max_size = 400 * 1024 * 1024; // 400MB

pub fn main() !void {
    const detectedAction = try action.Action.detectCLI(std.heap.page_allocator);
    if (detectedAction) |a| {
        _ = try a.run(std.heap.page_allocator);
    }

    // try appendTimeRecord();
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    // const stdout_file = std.io.getStdOut().writer();

    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();

    // try stdout.print("Run `zig build test` to run the tests.\n", .{});

    // try bw.flush(); // don't forget to flush!
}

fn appendTimeRecord() !void {
    const PATH = "./time-trek.txt";
    const MAX_INPUT_SIZE = 1024;

    const allocator = std.heap.page_allocator;
    const stdin = std.io.getStdIn().reader();

    const buffer = try allocator.alloc(u8, MAX_INPUT_SIZE);
    defer allocator.free(buffer);

    while (true) {
        var file: std.fs.File = try openOrCreateFile(PATH);
        defer file.close();

        // Read the file
        var buf_reader = std.io.bufferedReader(file.reader());
        const reader = buf_reader.reader();
        var managed = std.ArrayList(u8).init(std.heap.page_allocator);
        errdefer managed.deinit();
        try reader.readAllArrayList(&managed, max_size);

        // Write the user input
        const input_length = try readUserInput(stdin, buffer);
        if (input_length) |input| {
            if (input.len == 0) {
                continue;
            }
            const trimmed_input = std.mem.trim(u8, input, " \r\n");
            const local_date = try getLocalDate();
            _ = try file.writer().print("[{s}] {s}\n", .{ local_date, trimmed_input });
        }
    }
}

fn openOrCreateFile(path: []const u8) !std.fs.File {
    const cwd = std.fs.cwd();
    return cwd.openFile(path, .{ .mode = .read_write }) catch |err| {
        if (err == error.FileNotFound) {
            return try cwd.createFile(path, .{});
        }
        return err;
    };
}

fn readUserInput(stdin: std.fs.File.Reader, buffer: []u8) !?[]const u8 {
    return try stdin.readUntilDelimiterOrEof(
        buffer,
        '\n',
    );
}

test "simple test" {
    const testing = std.testing;

    var iter = try std.process.ArgIteratorGeneral(.{}).init(
        testing.allocator,
        "--a=42 --b --b-f=false",
    );
    defer iter.deinit();
}
