const std = @import("std");
const Allocator = std.mem.Allocator;

const zeit = @import("zeit");

// pub const PATH = "./test.txt";
pub const PATH = "./time-trek.txt";
const MAX_INPUT_SIZE = 1024;

pub fn run(alloc_gpa: Allocator) !void {
    const stdin = std.io.getStdIn().reader();

    const buffer = try alloc_gpa.alloc(u8, MAX_INPUT_SIZE);
    defer alloc_gpa.free(buffer);

    while (true) {
        var file: std.fs.File = try openOrCreateFile(PATH);
        defer file.close();

        const end_pos = try file.getEndPos();
        try file.seekTo(end_pos);

        // Write the user input
        const input_length = try readUserInput(stdin, buffer);
        if (input_length) |input| {
            if (input.len == 0) {
                continue;
            }
            const trimmed_input = std.mem.trim(u8, input, " \r\n");
            const local_date = try getLocalDate(alloc_gpa);
            defer alloc_gpa.free(local_date);
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

fn getLocalDate(alloc_gpa: Allocator) ![]u8 {
    var env = std.process.EnvMap.init(alloc_gpa);
    defer env.deinit();

    const local = try zeit.local(alloc_gpa, &env);
    defer local.deinit();

    const now_local = (try zeit.instant(.{})).in(&local);

    var buffer: [32]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const dt = now_local.time();
    try dt.strftime(stream.writer(), "%Y-%m-%d %H:%M:%S");

    const result = try alloc_gpa.dupe(u8, stream.getWritten());
    return result;
}
