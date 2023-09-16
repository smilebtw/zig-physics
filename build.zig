const std = @import("std");
const raylib = @import("src/raylib/build.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "physics",
        .root_source_file = std.build.FileSource.relative("src/main.zig"),
        .optimize = mode,
        .target = target,
    });

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    raylib.addTo(b, exe, target, mode);
}
