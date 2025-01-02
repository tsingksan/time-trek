const std = @import("std");
const Allocator = std.mem.Allocator;
const duration = @import("./duration.zig");

pub const Action = enum {
    duration,
    help,
    unknown,

    pub const Error = error{
        /// Multiple actions were detected. You can specify at most one
        /// action on the CLI otherwise the behavior desired is ambiguous.
        MultipleActions,

        /// An unknown action was specified.
        InvalidAction,
    };

    pub fn detectCLI(alloc: Allocator) !?Action {
        var iter = try std.process.argsWithAllocator(alloc);
        defer iter.deinit();
        return try detectIter(&iter);
    }

    // *std.process.ArgIterator
    // Detect the action from any iterator, used primarily for tests.
    pub fn detectIter(iter: anytype) Error!?Action {
        var currentPosition: u8 = 0;
        var pending: ?Action = null;
        while (iter.next()) |arg| {
            if (pending != null) return Error.MultipleActions;
            pending = std.meta.stringToEnum(Action, arg) orelse if (currentPosition > 0) return Error.InvalidAction else null;
            currentPosition += 1;
        }
        return pending;
    }

    pub fn run(self: Action, alloc: Allocator) !u8 {
        return try self.runMain(alloc);
    }

    fn runMain(self: Action, alloc: Allocator) !u8 {
        return switch (self) {
            .duration => try duration.run(alloc),
            else => 0,
        };
    }
};

test "detectCLI" {
    _ = @import("./duration.zig");

    const testing = std.testing;
    const alloc = testing.allocator;
    const mock_path = try std.fs.cwd().realpathAlloc(alloc, ".");
    defer alloc.free(mock_path);

    {
        var iter = try std.process.ArgIteratorGeneral(.{}).init(alloc, mock_path);
        defer iter.deinit();

        const action = try Action.detectIter(&iter);
        try testing.expect(action == null);
    }

    {
        const mock_args = try std.mem.concat(alloc, u8, &[_][]const u8{ mock_path, " duration" });
        defer alloc.free(mock_args);

        var iter = try std.process.ArgIteratorGeneral(.{}).init(alloc, mock_args);
        defer iter.deinit();

        const action = try Action.detectIter(&iter);
        try testing.expect(action == .duration);
    }

    {
        const mock_args = try std.mem.concat(alloc, u8, &[_][]const u8{ mock_path, " duration1" });
        defer alloc.free(mock_args);

        var iter = try std.process.ArgIteratorGeneral(.{}).init(alloc, mock_args);
        defer iter.deinit();

        try testing.expectError(error.InvalidAction, Action.detectIter(&iter));
    }

    {
        const mock_args = try std.mem.concat(alloc, u8, &[_][]const u8{ mock_path, " duration duration" });
        defer alloc.free(mock_args);

        var iter = try std.process.ArgIteratorGeneral(.{}).init(alloc, mock_args);
        defer iter.deinit();

        try testing.expectError(error.MultipleActions, Action.detectIter(&iter));
    }
}
