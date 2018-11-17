const semver = @import("main.zig");
const t = @import("./util/index.zig");
const std = @import("std");
const mem = std.mem;
const warn = stddebug.warn;

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

test "compare" {
    for (test_cases) |ts, i| {
        if (ts.valid) {
            for (test_cases) |tj, j| {
                if (tj.valid) {
                    var want: semver.Comparison = undefined;
                    if (mem.eql(u8, ts.v, tj.v)) {
                        want = semver.Comparison.Equal;
                    } else if (i < j) {
                        want = semver.Comparison.LessThan;
                    } else {
                        want = semver.Comparison.GreaterThan;
                    }
                    const cmp = try semver.compare(ts.v, tj.v);
                    if (want != cmp) {
                        _ = t.terrorf("{}:{} [{} ,{}]expected {} got {}", i, j, ts.v, tj.v, want, cmp);
                    }
                }
            }
        }
    }
}
