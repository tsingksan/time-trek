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

    pub fn detectIter(iter: *std.process.ArgIterator) Error!?Action {
        var currentPosition: u8 = 0;
        var pending: ?Action = null;
        while (iter.next()) |arg| {
            if (pending != null) return Error.MultipleActions;

            pending = std.meta.stringToEnum(Action, arg[1..]);
            if (pending) |action| {
                return action;
            } else if (currentPosition > 1) {
                return Error.InvalidAction;
            }

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
