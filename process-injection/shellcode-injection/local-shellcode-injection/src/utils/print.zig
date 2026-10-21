// Minimal synchronous console output, retaining the original {s}/{d}/{x} formatter.
const DWORD = u32;
const HANDLE = ?*anyopaque;
extern "kernel32" fn GetStdHandle(DWORD) callconv(.winapi) HANDLE;
extern "kernel32" fn WriteFile(HANDLE, [*]const u8, DWORD, *DWORD, ?*anyopaque) callconv(.winapi) i32;
const STDOUT_HANDLE: DWORD = 0xFFFFFFF5;

// Output is best effort: a missing/broken console must not affect protocol cleanup.
pub fn print(s: []const u8) void {
    const stdout = GetStdHandle(STDOUT_HANDLE) orelse return;
    if (@intFromPtr(stdout) == ~@as(usize, 0)) return;
    var offset: usize = 0;
    while (offset < s.len) {
        var written: DWORD = 0;
        const chunk: DWORD = @intCast(@min(s.len - offset, 0xffffffff));
        if (WriteFile(stdout, s[offset..].ptr, chunk, &written, null) == 0 or written == 0 or written > chunk) return;
        offset += written;
    }
}

fn printDec(value: anytype) void {
    var buf: [20]u8 = undefined;
    var n: u64 = @intCast(value);
    var i: usize = buf.len;

    if (n == 0) {
        print("0");
        return;
    }

    while (n != 0) {
        i -= 1;
        buf[i] = '0' + @as(u8, @intCast(n % 10));
        n /= 10;
    }

    print(buf[i..]);
}

fn printHex(value: anytype) void {
    const digits = "0123456789abcdef";

    var buf: [16]u8 = undefined;
    var n: u64 = @intCast(value);
    var i: usize = buf.len;

    if (n == 0) {
        print("0");
        return;
    }

    while (n != 0) {
        i -= 1;
        buf[i] = digits[@intCast(n & 0xf)];
        n >>= 4;
    }

    print(buf[i..]);
}

pub fn printf(comptime fmt: []const u8, args: anytype) void {
    printfImpl(fmt, args, 0);
}

fn printfImpl(
    comptime fmt: []const u8,
    args: anytype,
    comptime arg_index: usize,
) void {

    // Buscar el siguiente {
    comptime var i: usize = 0;

    inline while (i < fmt.len) : (i += 1) {
        if (fmt[i] == '{') {
            if (i > 0)
                print(fmt[0..i]);

            // {s}
            if (i + 2 < fmt.len and
                fmt[i + 1] == 's' and
                fmt[i + 2] == '}')
            {
                print(args[arg_index]);

                printfImpl(
                    fmt[i + 3 ..],
                    args,
                    arg_index + 1,
                );

                return;
            }

            // {d}
            if (i + 2 < fmt.len and
                fmt[i + 1] == 'd' and
                fmt[i + 2] == '}')
            {
                printDec(args[arg_index]);

                printfImpl(
                    fmt[i + 3 ..],
                    args,
                    arg_index + 1,
                );

                return;
            }

            // {x}
            if (i + 2 < fmt.len and
                fmt[i + 1] == 'x' and
                fmt[i + 2] == '}')
            {
                printHex(args[arg_index]);

                printfImpl(
                    fmt[i + 3 ..],
                    args,
                    arg_index + 1,
                );

                return;
            }
        }
    }

    print(fmt);
}
