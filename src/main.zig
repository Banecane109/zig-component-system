const std = @import("std");
const zig_component_system = @import("zig_component_system");

const SharedRef = @import("ref.zig").SharedRef;
const IComponent = @import("component-system/icomponent.zig").IComponent;

const Rigidbody2D = struct {
    pub fn create(_: *Rigidbody2D) void {
        std.debug.print("Rigidbody2D created\n", .{});
    }

    pub fn start(_: *Rigidbody2D) void {
        std.debug.print("Rigidbody2D started\n", .{});
    }

    pub fn deinit(_: *Rigidbody2D) anyerror!void {}
};

pub fn main() !void {
    const arena_allocator = @constCast(&std.heap.ArenaAllocator.init(std.heap.page_allocator));
    const allocator = arena_allocator.allocator();
    defer arena_allocator.deinit();

    // Initialize dummy object
    const rigidbody: *Rigidbody2D = try allocator.create(Rigidbody2D);
    rigidbody.* = Rigidbody2D{};

    const something: SharedRef(Rigidbody2D) = try SharedRef(Rigidbody2D).init(rigidbody, allocator);
    errdefer something.release();
}
