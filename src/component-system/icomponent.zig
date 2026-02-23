const std = @import("std");

const ArenaAllocator = std.heap.ArenaAllocator;

pub const IComponent = struct {
    const Self = @This();

    ptr: *anyopaque, // Pointer to underlying component
    arena_allocator: *ArenaAllocator,

    // Universal component functions
    fn_create: *const fn (ptr: *anyopaque) void,
    fn_start: *const fn (ptr: *anyopaque) void,

    pub fn init(arena_allocator: *ArenaAllocator, component: anytype) !Self {
        const T = @TypeOf(component);

        // Generate function wrappers
        const gen = struct {
            pub fn create(ptr: *anyopaque) void {
                const self: T = @ptrCast(@alignCast(ptr));
                self.create();
            }

            pub fn start(ptr: *anyopaque) void {
                const self: T = @ptrCast(@alignCast(ptr));
                self.start();
            }
        };

        return Self{
            .ptr = @constCast(component),
            .arena_allocator = arena_allocator,
            .fn_create = gen.create,
            .fn_start = gen.start,
        };
    }

    pub fn create(self: *Self) void {
        self.fn_create(self.ptr);
    }

    pub fn start(self: *Self) void {
        self.fn_start(self.ptr);
    }
};
