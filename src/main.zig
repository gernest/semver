// This was ported from golang tools repo, it makes ense to include the license
//
// Copyright 2018 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// Copyright 2018 Geofrey Ernest

const std = @import("std");
const mem = std.mem;

const identStep = struct {
    ident: []const u8,
    rest: []const u8,
};

pub fn nextIdent(x: []const u8) identStep {
    var i: usize = 0;
    while (i < x.len and x[i] != '.') : (i += 1) {}
    return identStep{ .ident = x[0..i], .rest = x[1..] };
}

fn isIdentChar(c: u8) bool {
    return 'A' <= c and c <= 'Z' or 'a' <= c and c <= 'z' or '0' <= c and c <= '9' or c == '-';
}

fn isNum(v: []const u8) bool {
    var i: usize = 0;
    while (i < v.len and '0' <= v[i] and v[i] <= '9') : (i += 1) {}
    return i == v.len;
}

fn isBadNum(v: []const u8) bool {
    var i: usize = 0;
    while (i < v.len and '0' <= v[i] and v[i] <= '9') : (i += 1) {}
    return i == v.len and i > 1 and v[0] == '0';
}

const Comparison = enum {
    LessThan,
    Equal,
    GreaterThan,
};

fn compareInt(x: []const u8, y: []const u8) Comparison {
    if (mem.eql(u8, x, y)) {
        return Comparison.Equal;
    }
    if (x.len < y.len) {
        return Comparison.LessThan;
    }
    if (x.len > y.len) {
        return Comparison.GreaterThan;
    }
    unreachable;
}

fn comparePrerelease(x: []const u8, y: []const u8) Comparison {
    // "When major, minor, and patch are equal, a pre-release version has
    // lower precedence than a normal version.
    // Example: 1.0.0-alpha < 1.0.0.
    // Precedence for two pre-release versions with the same major, minor,
    // and patch version MUST be determined by comparing each dot separated
    // identifier from left to right until a difference is found as follows:
    // identifiers consisting of only digits are compared numerically and
    // identifiers with letters or hyphens are compared lexically in ASCII
    // sort order. Numeric identifiers always have lower precedence than
    // non-numeric identifiers. A larger set of pre-release fields has a
    // higher precedence than a smaller set, if all of the preceding
    // identifiers are equal.
    // Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta <
    // 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.
    if (mem.eql(u8, x, y)) {
        return Comparison.Equal;
    }
    if (x == "") {
        return Comparison.GreaterThan;
    }
    if (y == "") {
        return Comparison.LessThan;
    }
    var i: usize = 0;
    while (true) : (i += 1) {
        var xx = x[i..];
        var yy = y[i..];
        var dx = nextIdent(xx);
        var dy = nextIdent(yy);
        if (!mem.eql(u8, dx.ident, dy.ident)) {
            const ix = isNum(dx.ident);
            const iy = isNum(dy.ident);
            if (ix != iy) {
                if (ix) {
                    return Comparison.LessThan;
                }
                return Comparison.GreaterThan;
            }
            if (ix) {
                if (dx.ident.len < dy.ident.len) {
                    return Comparison.LessThan;
                }
                if (dx.ident.len > dy.ident.len) {
                    return Comparison.GreaterThan;
                }
            }
            switch (mem.compare(u8, dx.ident, dy.ident)) {
                mem.Compare.LessThan => return compare.less,
                else => {},
            }
            return Comparison.GreaterThan;
        }
        if (!(i != x.len - 1 and i != y.len - 1)) {
            if (x.len - 1 == i) {
                return Comparison.LessThan;
            }
            return Comparison.GreaterThan;
        }
    }
}

pub const Version = struct {
    major: []const u8,
    minor: []const u8,
    patch: []const u8,
    short: ?[]const u8,
    pre_release: ?[]const u8,
    build: ?[]const u8,

    pub fn compare(self: Version, v: Version) Comparison {
        const major = compareInt(self.major, v.major);
        if (major != Comparison.Equal) {
            return major;
        }
        const minor = compareInt(self.minor, v.minor);
        if (minor != Comparison.Equal) {
            return minor;
        }
        const patch = compareInt(self.patch, v.patch);
        if (patch != Comparison.Equal) {
            return patch;
        }
        return comparePrerelease(self.pre_release, v.pre_release);
    }
};

pub fn parse(v: []const u8) !Version {
    if (v.len == 0) {
        return error.EmptyString;
    }
    if (v[0] != 'v') {
        return error.MissingVersionPrefix;
    }
    var version: Version = undefined;
    if (parseInt(v[1..])) |value| {
        version.major = value;
    } else |err| {
        return error.BadMajorVersion;
    }
    var n: usize = 1 + version.major.len;
    if (n == v.len) {
        version.minor = "0";
        version.patch = "0";
        version.short = ".0";
        return version;
    }
    if (v[n] != '.') {
        return error.BadMinorPrefix;
    }
    if (parseInt(v[n..])) |value| {
        version.minor = value;
    } else |err| {
        return error.BadMinorVersion;
    }
    n += version.minor.len;
    if (n == v.len) {
        version.patch = "0";
        version.short = ".0";
        return version;
    }
    if (v[n] != '.') {
        return error.BadPatchPrefix;
    }
    if (parseInt(v[n..])) |value| {
        version.patch = value;
    } else |err| {
        return error.BadPatchVersion;
    }
    return version;
}

fn parseInt(v: []const u8) ![]const u8 {
    if (v.len == 0) {
        return error.NaN;
    }
    if (v[0] < '0' or '9' < v[0]) {
        return error.Nan;
    }
    var i: usize = 0;
    while (i < v.len and '0' <= v[i] and v[i] <= '9') : (i += 1) {}
    return v[0..i];
}

// returns true if v is a valid semvar string and false otherwise.
pub fn isValid(v: []const u8) bool {
    if (parse(v)) |_| {
        return true;
    } else |err| {
        return false;
    }
}
