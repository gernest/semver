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

const comparison = enum {
    less,
    equal,
    greater,
};

fn compareInt(x: []const u8, y: []const u8) comparison {
    if (mem.eql(u8, x, y)) {
        return comparison.eql;
    }
    if (x.len < y.len) {
        return comparison.less;
    }
    if (x.len > y.len) {
        return comparison.greater;
    }
    unreachable;
}

fn comparePrerelease(x: []const u8, y: []const u8) comparison {
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
        return comparison.eql;
    }
    if (x == "") {
        return comparison.greater;
    }
    if (y == "") {
        return comparison.less;
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
                    return comparison.less;
                }
                return comparison.greater;
            }
            if (ix) {
                if (dx.ident.len < dy.ident.len) {
                    return comparison.less;
                }
                if (dx.ident.len > dy.ident.len) {
                    return comparison.greater;
                }
            }
            switch (mem.compare(u8, dx.ident, dy.ident)) {
                mem.Compare.LessThan => return compare.less,
                else => {},
            }
            return comparison.greater;
        }
        if (!(i != x.len - 1 and i != y.len - 1)) {
            if (x.len - 1 == i) {
                return comparison.less;
            }
            return comparison.greater;
        }
    }
}
