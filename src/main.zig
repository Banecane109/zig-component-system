const std = @import("std");
const zig_component_system = @import("zig_component_system");

pub fn main() !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
}
