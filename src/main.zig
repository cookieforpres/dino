const std = @import("std");
const VM = @import("vm.zig").VM;

fn load_file(file_path: []const u8) ![]u8 {
    const allocator = std.heap.page_allocator;

    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.realpath(file_path, &path_buffer);

    const file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
    defer file.close();

    const buffer_size = 1024;
    const file_buffer = try file.readToEndAlloc(allocator, buffer_size);

    return file_buffer;
}

pub fn main() !void {
    var program = try load_file("dino.bin");

    var vm = try VM.init();
    vm.load(program);
    try vm.run();
}
