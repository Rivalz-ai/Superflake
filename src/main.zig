//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");

const EPOCH: i64 = 1609459200000; // Custom epoch (January 1, 2021)
const NODE_ID: u10 = 1; // Example node ID

const Superflake = struct {
    timestamp: u42,
    node_id: u10,
    sequence: u12,

    pub fn generate() Superflake {
        const now = @intCast(u42, std.time.milliTimestamp() - EPOCH);
        const sequence = @intCast(u12, 0); // Example sequence number, should be incremented in real use
        return Superflake{
            .timestamp = now,
            .node_id = NODE_ID,
            .sequence = sequence,
        };
    }

    pub fn toString(self: Superflake) ![]const u8 {
        return std.fmt.allocPrint(std.heap.page_allocator, "{x}", .{self.toInt()});
    }

    fn toInt(self: Superflake) u64 {
        return (@intCast(u64, self.timestamp) << 22) | (@intCast(u64, self.node_id) << 12) | @intCast(u64, self.sequence);
    }
};

pub fn main() !void {
    const superflake = Superflake.generate();
    const id_str = try superflake.toString();
    defer std.heap.page_allocator.free(id_str);

    std.debug.print("Generated Superflake ID: {s}\n", .{id_str});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const global = struct {
        fn testOne(input: []const u8) anyerror!void {
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(global.testOne, .{});
}

test "Superflake generation" {
    const superflake = Superflake.generate();
    const id_str = try superflake.toString();
    defer std.heap.page_allocator.free(id_str);

    try std.testing.expect(id_str.len > 0);
}

test "Superflake uniqueness" {
    const superflake1 = Superflake.generate();
    const superflake2 = Superflake.generate();
    try std.testing.expect(superflake1.toInt() != superflake2.toInt());
}
