# semver
[![Build Status](https://travis-ci.org/gernest/semver.svg?branch=master)](https://travis-ci.org/gernest/semver)

semantic versioning for zig. This allows you to parse and compare semantic version strings.


## usage

```
const semver = @import("src/main.zig");
const warn = @import("std").debug.warn;

test "parse version string to a struct" {
    const version = try semver.parse("v1.2.3-pre+meta");
    warn("\n{}\n", version);
}

test "compare two version strings" {
    const versionSample = struct {
        x: []const u8,
        y: []const u8,
    };
    const version_list = []versionSample{
        versionSample{ .x = "1.2.3", .y = "3.2.1" },

        // you can prefix the version string with v, it is supported.
        versionSample{ .x = "v5.2.3", .y = "v3.2.1" },
    };
    warn("\n");
    for (version_list) |v| {
        const cmp = try semver.compare(v.x, v.y);
        switch (cmp) {
            semver.Comparison.LessThan => {
                warn("{} < {}\n", v.x, v.y);
            },
            semver.Comparison.Equal => {
                warn("{} == {}\n", v.x, v.y);
            },
            semver.Comparison.GreaterThan => {
                warn("{} > {}\n", v.x, v.y);
            },
            else => unreachable,
        }
    }
}

// $ zig test example.zig
// Test 1/2 parse version string to a struct...
// Version{ .major = 1, .minor = 2, .patch = 3, .pre_release = pre, .build = meta }
// OK
// Test 2/2 compare two version strings...
// 1.2.3 < 3.2.1
// v5.2.3 > v3.2.1
// OK
// All tests passed.

```
