const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;

const zeit = @import("zeit");

const PATH = @import("../record.zig").PATH;
const OUTPUT_PATH = "./analytics.txt";
const max_size = 400 * 1024 * 1024; // 400MB

const TaskDuration = struct {
    timestamp: i64,
    content: []const u8,
};

var tasks: []TaskDuration = undefined;

pub fn run(alloc_gpa: Allocator) !u8 {
    const file = try std.fs.cwd().openFile(PATH, .{});
    defer file.close();

    const reder = file.reader();
    const content = try reder.readAllAlloc(alloc_gpa, max_size);
    defer alloc_gpa.free(content);

    var lines = std.mem.splitAny(u8, content, "\n");
    var previous_timestamp: ?i64 = null;

    var arena = ArenaAllocator.init(alloc_gpa);
    defer arena.deinit();
    const alloc = arena.allocator();
    tasks = try alloc.alloc(TaskDuration, 0);
    defer alloc.free(tasks);

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const bracket_end = std.mem.indexOf(u8, line, "]");
        if (bracket_end) |index| {
            const time = line[1..index];
            const task = std.mem.trim(u8, line[index + 1 ..], " ");

            const dt = try zeit.instant(zeit.Instant.Config{
                .source = .{ .iso8601 = time },
            });
            const timestamp = dt.unixTimestamp();

            if (previous_timestamp) |prev| {
                if (std.mem.eql(u8, task, "over resting")) {
                    previous_timestamp = timestamp;
                    continue;
                }
                const time_diff = timestamp - prev;

                tasks = try alloc.realloc(tasks, tasks.len + 1);
                tasks[tasks.len - 1] = .{
                    .timestamp = time_diff,
                    .content = task,
                };
            }
            previous_timestamp = timestamp;
        }
    }

    var output_file: std.fs.File = undefined;
    output_file = std.fs.cwd().openFile(
        OUTPUT_PATH,
        .{ .mode = .read_write },
    ) catch |err| {
        if (err == error.FileNotFound) {
            output_file = try std.fs.cwd().createFile(OUTPUT_PATH, .{});
        }
        return err;
    };

    defer output_file.close();
    var task_timestamp: i64 = 0;
    var day_timestamp: i64 = 0;
    for (tasks) |task| {
        if (std.mem.eql(u8, task.content, "start work")) {
            const res = try formatToHHMMSS(alloc, day_timestamp);
            defer alloc.free(res);
            _ = try output_file.writer().print("total: {s}\n\n", .{res});

            day_timestamp = 0;
            continue;
        }

        if (std.mem.eql(u8, task.content, "begin resting")) {
            task_timestamp += task.timestamp;
            continue;
        }

        task_timestamp += task.timestamp;
        day_timestamp += task_timestamp;

        const res = try formatToHHMMSS(alloc, task_timestamp);
        defer alloc.free(res);
        _ = try output_file.writer().print("{s} - {s}\n", .{ res, task.content });

        task_timestamp = 0;
    }

    const res = try formatToHHMMSS(
        alloc,
        day_timestamp,
    );
    defer alloc.free(res);
    _ = try output_file.writer().print("total: {s}\n", .{res});

    return 0;
}

fn formatToHHMMSS(alloc: Allocator, timestamp: i64) ![]u8 {
    const timestamp_u64: u64 = @intCast(if (timestamp >= 0) timestamp else 0);
    const seconds = timestamp_u64 % 60;
    const minute_next = timestamp_u64 / 60;
    const minutes = minute_next % 60;
    const hours = minute_next / 60;

    const res = try std.mem.concat(
        alloc,
        u8,
        &[_][]const u8{
            try formatInt(alloc, hours),
            "h",
            try formatInt(alloc, minutes),
            "m",
            try formatInt(alloc, seconds),
            "s",
        },
    );
    return res;
}

fn formatInt(alloc: Allocator, n: u64) ![]u8 {
    var buffer = std.ArrayList(u8).init(alloc);
    defer buffer.deinit();
    const writer = buffer.writer();
    try std.fmt.formatInt(
        n,
        10,
        std.fmt.Case.lower,
        .{ .alignment = .right, .width = 2, .fill = '0' },
        writer,
    );
    return buffer.toOwnedSlice();
}

test "duration" {
    const testing = std.testing;
    const alloc = testing.allocator;

    {
        const num = 1;
        const res = try formatInt(alloc, num);
        defer alloc.free(res);
        try testing.expect(std.mem.eql(u8, res, "01"));
    }

    {
        const num = 9;
        const res = try formatInt(alloc, num);
        defer alloc.free(res);
        try testing.expect(std.mem.eql(u8, res, "09"));
    }
}
