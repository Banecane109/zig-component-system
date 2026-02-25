const std = @import("std");

pub fn SharedRef(comptime T: type) type {
    if (@hasDecl(T, "deinit")) {
        const deinit = @field(T, "deinit");
        const t_deinit = @TypeOf(deinit);

        if (t_deinit != fn (*T) anyerror!void) {
            @compileError("deinit must be a fn(*T) anyerror!void");
        }
    }

    return struct {
        const Self = @This();

        const SharedRefObject = struct {
            count: std.atomic.Value(usize),
            allocator: std.mem.Allocator,
            ptr: *T,
        };

        ref_object: *SharedRefObject,

        /// Initialized new instance of SharedRef
        ///
        /// #Arguments
        /// * `ptr` - pointer to object that will be shared
        /// * `allocator` - allocator that was used to create the object
        pub fn init(ptr: *T, allocator: std.mem.Allocator) !Self {
            const ref_object = try allocator.create(SharedRefObject);
            ref_object.* = .{
                .count = std.atomic.Value(usize).init(1),
                .allocator = allocator,
                .ptr = ptr,
            };

            return .{ .ref_object = ref_object };
        }

        /// ### Returns
        /// - `*T` : pointer to object
        pub fn getPtr(self: Self) *T {
            self.ref_object.count.fetchAdd(1, .SeqCst);
            return self.ref_object.ptr;
        }

        /// ### Returns
        /// - `usize` : current reference count
        pub fn getCurrentRefCount(self: Self) usize {
            return self.ref_object.count.load(.seq_cst);
        }

        /// Releases reference to object
        pub fn release(self: Self) !void {
            if (self.ref_object.count.fetchSub(1, .seq_cst) == 1) {
                try self.ref_object.ptr.deinit();
                self.ref_object.allocator.destroy(self.ref_object.ptr);
                self.ref_object.allocator.destroy(self.ref_object);
            }
        }
    };
}
