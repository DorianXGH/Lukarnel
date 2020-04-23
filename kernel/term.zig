const builtin = @import("builtin");
const video = @import("bootstrap_drivers/video.zig");

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

pub const terminal = struct {
    var row = @intCast(usize, 0);
    var column = @intCast(usize, 0);

    pub const characters = struct {
        pub var A = @embedFile("../font/A.bmp");
        pub var B = @embedFile("../font/B.bmp");
        pub var C = @embedFile("../font/C.bmp");
        pub var D = @embedFile("../font/D.bmp");
        pub var E = @embedFile("../font/E.bmp");
        pub var F = @embedFile("../font/F.bmp");
        pub var G = @embedFile("../font/G.bmp");
        pub var H = @embedFile("../font/H.bmp");
        pub var I = @embedFile("../font/I.bmp");
        pub var J = @embedFile("../font/J.bmp");
        pub var K = @embedFile("../font/K.bmp");
        pub var L = @embedFile("../font/L.bmp");
        pub var M = @embedFile("../font/M.bmp");
        pub var N = @embedFile("../font/N.bmp");
        pub var O = @embedFile("../font/O.bmp");
        pub var P = @embedFile("../font/P.bmp");
        pub var Q = @embedFile("../font/Q.bmp");
        pub var R = @embedFile("../font/R.bmp");
        pub var S = @embedFile("../font/S.bmp");
        pub var T = @embedFile("../font/T.bmp");
        pub var U = @embedFile("../font/U.bmp");
        pub var V = @embedFile("../font/V.bmp");
        pub var W = @embedFile("../font/W.bmp");
        pub var X = @embedFile("../font/X.bmp");
        pub var Y = @embedFile("../font/Y.bmp");
        pub var Z = @embedFile("../font/Z.bmp");

        pub var a = @embedFile("../font/a.bmp");
        pub var b = @embedFile("../font/b.bmp");
        pub var c = @embedFile("../font/c.bmp");
        pub var d = @embedFile("../font/d.bmp");
        pub var e = @embedFile("../font/e.bmp");
        pub var f = @embedFile("../font/f.bmp");
        pub var g = @embedFile("../font/g.bmp");
        pub var h = @embedFile("../font/h.bmp");
        pub var i = @embedFile("../font/i.bmp");
        pub var j = @embedFile("../font/j.bmp");
        pub var k = @embedFile("../font/k.bmp");
        pub var l = @embedFile("../font/l.bmp");
        pub var m = @embedFile("../font/m.bmp");
        pub var n = @embedFile("../font/n.bmp");
        pub var o = @embedFile("../font/o.bmp");
        pub var p = @embedFile("../font/p.bmp");
        pub var q = @embedFile("../font/q.bmp");
        pub var r = @embedFile("../font/r.bmp");
        pub var s = @embedFile("../font/r.bmp");
        pub var t = @embedFile("../font/t.bmp");
        pub var u = @embedFile("../font/u.bmp");
        pub var v = @embedFile("../font/v.bmp");
        pub var w = @embedFile("../font/w.bmp");
        pub var x = @embedFile("../font/x.bmp");
        pub var y = @embedFile("../font/y.bmp");
        pub var z = @embedFile("../font/z.bmp");
        pub var d0 = @embedFile("../font/0.bmp");
        pub var d1 = @embedFile("../font/1.bmp");
        pub var d2 = @embedFile("../font/2.bmp");
        pub var d3 = @embedFile("../font/3.bmp");
        pub var d4 = @embedFile("../font/4.bmp");
        pub var d5 = @embedFile("../font/5.bmp");
        pub var d6 = @embedFile("../font/6.bmp");
        pub var d7 = @embedFile("../font/7.bmp");
        pub var d8 = @embedFile("../font/8.bmp");
        pub var d9 = @embedFile("../font/9.bmp");

        pub var spr = [_]video.Sprite{
            video.Sprite.from_bitmap(A[0..], 11, 20),
            video.Sprite.from_bitmap(B[0..], 11, 20),
            video.Sprite.from_bitmap(C[0..], 11, 20),
            video.Sprite.from_bitmap(D[0..], 11, 20),
            video.Sprite.from_bitmap(E[0..], 11, 20),
            video.Sprite.from_bitmap(F[0..], 11, 20),
            video.Sprite.from_bitmap(G[0..], 11, 20),
            video.Sprite.from_bitmap(H[0..], 11, 20),
            video.Sprite.from_bitmap(I[0..], 11, 20),
            video.Sprite.from_bitmap(J[0..], 11, 20),
            video.Sprite.from_bitmap(K[0..], 11, 20),
            video.Sprite.from_bitmap(L[0..], 11, 20),
            video.Sprite.from_bitmap(M[0..], 11, 20),
            video.Sprite.from_bitmap(N[0..], 11, 20),
            video.Sprite.from_bitmap(O[0..], 11, 20),
            video.Sprite.from_bitmap(P[0..], 11, 20),
            video.Sprite.from_bitmap(Q[0..], 11, 20),
            video.Sprite.from_bitmap(R[0..], 11, 20),
            video.Sprite.from_bitmap(S[0..], 11, 20),
            video.Sprite.from_bitmap(T[0..], 11, 20),
            video.Sprite.from_bitmap(U[0..], 11, 20),
            video.Sprite.from_bitmap(V[0..], 11, 20),
            video.Sprite.from_bitmap(W[0..], 11, 20),
            video.Sprite.from_bitmap(X[0..], 11, 20),
            video.Sprite.from_bitmap(Y[0..], 11, 20),
            video.Sprite.from_bitmap(Z[0..], 11, 20),

            video.Sprite.from_bitmap(a[0..], 11, 20),
            video.Sprite.from_bitmap(b[0..], 11, 20),
            video.Sprite.from_bitmap(c[0..], 11, 20),
            video.Sprite.from_bitmap(d[0..], 11, 20),
            video.Sprite.from_bitmap(e[0..], 11, 20),
            video.Sprite.from_bitmap(f[0..], 11, 20),
            video.Sprite.from_bitmap(g[0..], 11, 20),
            video.Sprite.from_bitmap(h[0..], 11, 20),
            video.Sprite.from_bitmap(i[0..], 11, 20),
            video.Sprite.from_bitmap(j[0..], 11, 20),
            video.Sprite.from_bitmap(k[0..], 11, 20),
            video.Sprite.from_bitmap(l[0..], 11, 20),
            video.Sprite.from_bitmap(m[0..], 11, 20),
            video.Sprite.from_bitmap(n[0..], 11, 20),
            video.Sprite.from_bitmap(o[0..], 11, 20),
            video.Sprite.from_bitmap(p[0..], 11, 20),
            video.Sprite.from_bitmap(q[0..], 11, 20),
            video.Sprite.from_bitmap(r[0..], 11, 20),
            video.Sprite.from_bitmap(s[0..], 11, 20),
            video.Sprite.from_bitmap(t[0..], 11, 20),
            video.Sprite.from_bitmap(u[0..], 11, 20),
            video.Sprite.from_bitmap(v[0..], 11, 20),
            video.Sprite.from_bitmap(w[0..], 11, 20),
            video.Sprite.from_bitmap(x[0..], 11, 20),
            video.Sprite.from_bitmap(y[0..], 11, 20),
            video.Sprite.from_bitmap(z[0..], 11, 20),
        };
    };

    pub var buffer = @intToPtr([*]volatile u8, 0xB8000);

    pub fn initialize() void {
        var y = @intCast(usize, 0);
        while (y < VGA_HEIGHT) : (y += 1) {
            var x = @intCast(usize, 0);
            while (x < VGA_WIDTH) : (x += 1) {
                putCharAt(' ', x, y);
            }
        }
    }

    pub fn putCharAt(c: u8, x: usize, y: usize) void {
        const index = y * VGA_WIDTH + x;
        buffer[index] = c;
    }

    pub fn putChar(c: u8) void {
        putCharAt(c, column, row);
        column += 1;
        if (column == VGA_WIDTH) {
            column = 0;
            row += 1;
            if (row == VGA_HEIGHT)
                row = 0;
        }
    }

    pub fn write(data: []const u8) void {
        for (data) |c|
            putChar(c);
    }
};
