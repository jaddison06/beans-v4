const print = @import("std").debug.print;

export fn helloWorld() void {
    print("Hello World from Zig!", .{});
}