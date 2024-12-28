const std = @import("std");
const Allocator = std.mem.Allocator;

const zeit = @import("zeit");
const getLocalDate = @import("./time.zig").getLocalDate;

pub fn main() !void {
    const cwd = std.fs.cwd();
    const PATH = "./time-trek.txt";

    const allocator = std.heap.page_allocator;
    var buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(buffer);

    const stdin_file = std.io.getStdIn().reader();

    while (true) {
        var file: std.fs.File = undefined;
        file = cwd.openFile(PATH, .{ .mode = .read_write }) catch |err| {
            if (err == error.FileNotFound) {
                file = try cwd.createFile(PATH, .{});
                continue;
            } else {
                return err;
            }
        };
        defer file.close();
        var used_length = try file.read(buffer);
        const available_space: usize = buffer.len - used_length;

        if (available_space == 0) {
            _ = allocator.resize(buffer, buffer.len * 2);
        }

        const input_length = try stdin_file.readUntilDelimiterOrEof(
            buffer[used_length..],
            '\n',
        );

        if (input_length) |input| {
            if (input.len == 0) {
                continue;
            }
            const trimmed_input = std.mem.trim(u8, buffer[used_length .. used_length + input.len], " \r\n");

            used_length += input.len;
            // const content = buffer[0..used_length];
            // std.debug.print("File content: {s}\n", .{content});
            const local_date = try getLocalDate();
            _ = try file.writer().print("[{s}]: {s}\n", .{ local_date, trimmed_input });
        }
    }

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    // const stdout_file = std.io.getStdOut().writer();

    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();

    // try stdout.print("Run `zig build test` to run the tests.\n", .{});

    // try bw.flush(); // don't forget to flush!
}

test "simple test" {}
