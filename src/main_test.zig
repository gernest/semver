const semver = @import("main.zig");
const t = @import("./util/index.zig");
const std = @import("std");
const mem = std.mem;
const warn = std.debug.warn;

const testCase = struct {
    v: []const u8,
    valid: bool,
};

const test_cases = []testCase{
    testCase{ .v = "bad", .valid = false },
    testCase{ .v = "v1-alpha.beta.gamma", .valid = false },
    testCase{ .v = "v1-pre", .valid = false },
    testCase{ .v = "v1+meta", .valid = false },
    testCase{ .v = "v1-pre+meta", .valid = false },
    testCase{ .v = "v1.2-pre", .valid = false },
    testCase{ .v = "v1.2+meta", .valid = false },
    testCase{ .v = "v1.2-pre+meta", .valid = false },
    testCase{ .v = "v1.0.0-alpha", .valid = true },
    testCase{ .v = "v1.0.0-alpha.1", .valid = true },
    testCase{ .v = "v1.0.0-alpha.beta", .valid = true },
    testCase{ .v = "v1.0.0-beta", .valid = true },
    testCase{ .v = "v1.0.0-beta.2", .valid = true },
    testCase{ .v = "v1.0.0-beta.11", .valid = true },
    testCase{ .v = "v1.0.0-rc.1", .valid = true },
    testCase{ .v = "v1", .valid = true },
    testCase{ .v = "v1.0", .valid = true },
    testCase{ .v = "v1.0.0", .valid = true },
    testCase{ .v = "v1.2", .valid = true },
    testCase{ .v = "v1.2.0", .valid = true },
    testCase{ .v = "v1.2.3-456", .valid = true },
    testCase{ .v = "v1.2.3-456.789", .valid = true },
    testCase{ .v = "v1.2.3-456-789", .valid = true },
    testCase{ .v = "v1.2.3-456a", .valid = true },
    testCase{ .v = "v1.2.3-pre", .valid = true },
    testCase{ .v = "v1.2.3-pre+meta", .valid = true },
    testCase{ .v = "v1.2.3-pre.1", .valid = true },
    testCase{ .v = "v1.2.3-zzz", .valid = true },
    testCase{ .v = "v1.2.3", .valid = true },
    testCase{ .v = "v1.2.3+meta", .valid = true },
};

test "is valid" {
    for (test_cases) |ts| {
        const ok = semver.isValid(ts.v);
        if (ok != ts.valid) {
            try t.terrorf("version: {} expected {} got {}", ts.v, ts.valid, ok);
        }
    }
}

const compareTest = struct {
    x: []const u8,
    y: []const u8,
    cmp: semver.Comparison,
};

const compare_tests = []compareTest{
    compareTest{ .x = "v1.0.0-alpha", .y = "v1.0.0-alpha", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0.0-alpha.1", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-alpha.1", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0.0-alpha.beta", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-alpha.beta", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-alpha.beta", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0.0-beta", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta", .y = "v1.0.0-beta", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0.0-beta.2", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta.2", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta.2", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta.2", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta.2", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0.0-beta.11", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta.11", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta.11", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta.11", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta.11", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-beta.11", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0.0-rc.1", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-rc.1", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-rc.1", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-rc.1", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-rc.1", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-rc.1", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0-rc.1", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1", .y = "v1", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1", .y = "v1.0", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1", .y = "v1.0.0", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0", .y = "v1", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0", .y = "v1.0", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0", .y = "v1.0.0", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0.0", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.0.0", .y = "v1", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0.0", .y = "v1.0", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.0.0", .y = "v1.0.0", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2", .y = "v1.2", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2", .y = "v1.2.0", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.0", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.0", .y = "v1.2", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.0", .y = "v1.2.0", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-456", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456", .y = "v1.2.3-456", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456.789", .y = "v1.2.3-456.789", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.2.3-456.789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456-789", .y = "v1.2.3-456-789", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.2.3-456.789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.2.3-456-789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-456a", .y = "v1.2.3-456a", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.2.3-456.789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.2.3-456-789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.2.3-456a", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.2.3-pre", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-pre", .y = "v1.2.3-pre+meta", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.2.3-456.789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.2.3-456-789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.2.3-456a", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.2.3-pre", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-pre+meta", .y = "v1.2.3-pre+meta", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.2.3-456.789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.2.3-456-789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.2.3-456a", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.2.3-pre", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.2.3-pre+meta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-pre.1", .y = "v1.2.3-pre.1", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2.3-456.789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2.3-456-789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2.3-456a", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2.3-pre", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2.3-pre+meta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2.3-pre.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3-zzz", .y = "v1.2.3-zzz", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3-456.789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3-456-789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3-456a", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3-pre", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3-pre+meta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3-pre.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3-zzz", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3+meta", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3", .y = "v1.2.3+meta-pre", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3-456.789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3-456-789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3-456a", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3-pre", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3-pre+meta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3-pre.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3-zzz", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3+meta", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3+meta", .y = "v1.2.3+meta-pre", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.0.0-alpha", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.0.0-alpha.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.0.0-alpha.beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.0.0-beta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.0.0-beta.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.0.0-beta.11", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.0.0-rc.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.0.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.0", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3-456", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3-456.789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3-456-789", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3-456a", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3-pre", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3-pre+meta", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3-pre.1", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3-zzz", .cmp = semver.Comparison.GreaterThan },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3+meta", .cmp = semver.Comparison.Equal },
    compareTest{ .x = "v1.2.3+meta-pre", .y = "v1.2.3+meta-pre", .cmp = semver.Comparison.Equal },
};

test "compare" {
    for (compare_tests) |ts, i| {
        const cmp = try semver.compare(ts.x, ts.y);
        if (ts.cmp != cmp) {
            try t.terrorf("{} [{} ,{}]expected {} got {}", i, ts.x, ts.y, ts.cmp, cmp);
        }
    }
}

const printTest = struct {
    src: []const u8,
    expect: []const u8,
};

const print_tests = []printTest{
    printTest{ .src = "v1.0.0-alpha", .expect = "v1.0.0-alpha" },
    printTest{ .src = "v1.0.0-alpha.1", .expect = "v1.0.0-alpha.1" },
    printTest{ .src = "v1.0.0-alpha.beta", .expect = "v1.0.0-alpha.beta" },
    printTest{ .src = "v1.0.0-beta", .expect = "v1.0.0-beta" },
    printTest{ .src = "v1.0.0-beta.2", .expect = "v1.0.0-beta.2" },
    printTest{ .src = "v1.0.0-beta.11", .expect = "v1.0.0-beta.11" },
    printTest{ .src = "v1.0.0-rc.1", .expect = "v1.0.0-rc.1" },
    printTest{ .src = "v1", .expect = "v1.0.0" },
    printTest{ .src = "v1.0", .expect = "v1.0.0" },
    printTest{ .src = "v1.0.0", .expect = "v1.0.0" },
    printTest{ .src = "v1.2", .expect = "v1.2.0" },
    printTest{ .src = "v1.2.0", .expect = "v1.2.0" },
    printTest{ .src = "v1.2.3-456", .expect = "v1.2.3-456" },
    printTest{ .src = "v1.2.3-456.789", .expect = "v1.2.3-456.789" },
    printTest{ .src = "v1.2.3-456-789", .expect = "v1.2.3-456-789" },
    printTest{ .src = "v1.2.3-456a", .expect = "v1.2.3-456a" },
    printTest{ .src = "v1.2.3-pre", .expect = "v1.2.3-pre" },
    printTest{ .src = "v1.2.3-pre+meta", .expect = "v1.2.3-pre+meta" },
    printTest{ .src = "v1.2.3-pre.1", .expect = "v1.2.3-pre.1" },
    printTest{ .src = "v1.2.3-zzz", .expect = "v1.2.3-zzz" },
    printTest{ .src = "v1.2.3", .expect = "v1.2.3" },
    printTest{ .src = "v1.2.3+meta", .expect = "v1.2.3+meta" },
};

test "print" {
    var buf = try std.Buffer.init(std.debug.global_allocator, "");
    defer buf.deinit();
    for (print_tests) |ts| {
        const v = try semver.parse(ts.src);
        try v.printBuffer(&buf);
        if (!mem.eql(u8, buf.toSlice(), ts.expect)) {
            _ = t.terrorf("expected {} got {} {}", ts.expect, buf.toSlice(), v);
        }
        buf.shrink(0);
    }
}

test "parse without v prefix" {
    _ = try semver.parse("1.2.3");
    _ = try semver.parse("1.2.3-pre");
    _ = try semver.parse("1.2.3-pre+meta");
    _ = try semver.parse("1.2");
    _ = try semver.parse("1");
}
