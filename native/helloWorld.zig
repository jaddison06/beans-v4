const print = @import("std").debug.print;

export fn HelloWorld() void {
    print("Hello World from Zig!\n", .{});
}