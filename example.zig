const semver = @import("src/main.zig");
const warn = @import("std").debug.warn;

test "parse version string to a struct" {
    const version = try semver.parse("v1.2.3-pre+meta");
    warn("\n{}\n", version);

    // Test 1/1 parse version string to a struct...
    // Version{ .major = 1, .minor = 2, .patch = 3, .pre_release = pre, .build = meta }
    // OK
    // All tests passed.
}
