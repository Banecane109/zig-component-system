const std = @import("std");
const zig_component_system = @import("zig_component_system");

const IComponent = @import("component-system/icomponent.zig").IComponent;

const Rigidbody2D = struct {
    pub fn create(_: *Rigidbody2D) void {
        std.debug.print("Rigidbody2D created\n", .{});
    }

    pub fn start(_: *Rigidbody2D) void {
        std.debug.print("Rigidbody2D started\n", .{});
    }
};

pub fn main() !void {
    const arena_allocator: *std.heap.ArenaAllocator = @constCast(&std.heap.ArenaAllocator.init(std.heap.page_allocator));
    defer arena_allocator.deinit();

    const rigidbody: *Rigidbody2D = try arena_allocator.allocator().create(Rigidbody2D);
    rigidbody.* = Rigidbody2D{};

    const component: *IComponent = try arena_allocator.allocator().create(IComponent);
    component.* = try IComponent.init(arena_allocator, rigidbody);
    component.create();
    component.start();
}
