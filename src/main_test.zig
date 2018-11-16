const semver = @import("main.zig");
const t = @import("./util/index.zig");
const warn = @import("std").debug.warn;

test "is valid" {
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

    for (test_cases) |ts| {
        const ok = semver.isValid(ts.v);
        if (ok != ts.valid) {
            _ = t.terrorf("version: {} expected {} got {}", ts.v, ts.valid, ok);
        }
    }
    // const p = try semver.parse("v1.2.3-pre+meta");
    // warn("{}", p);
}
