const windows = @import("std").os.windows;

// constants
pub const MEM_COMMIT: DWORD = 0x00001000;
pub const MEM_RESERVE: DWORD = 0x00002000;
pub const PAGE_READWRITE: DWORD = 0x04;
pub const PAGE_READ_EXECUTE: DWORD = 0x20;
pub const INFINITE: DWORD = 0xFFFFFFFF;
pub const WAIT_FAILED: DWORD = 0xFFFFFFFF;
pub const MEM_RELEASE: DWORD = 0x00008000;

pub const SIZE_T = windows.SIZE_T;
pub const DWORD = windows.DWORD;
pub const LPVOID = windows.LPVOID;
pub const LPCVOID = windows.LPCVOID;
pub const BOOL = windows.BOOL;
pub const HANDLE = windows.HANDLE;
pub const SECURITY_ATTRIBUTES = windows.SECURITY_ATTRIBUTES;
pub const LPTHREAD_START_ROUTINE = *const fn (lpParameter: ?LPVOID) callconv(.winapi) DWORD;

// function definitions
pub extern "kernel32" fn VirtualAlloc(lpAddress: ?LPVOID, dwSize: SIZE_T, flAllocationType: DWORD, flProtect: DWORD) callconv(.winapi) ?LPVOID;
pub extern "kernel32" fn GetLastError() callconv(.winapi) DWORD;
pub extern "kernel32" fn WriteProcessMemory(hProcess: HANDLE, lpBaseAddress: LPVOID, lpBuffer: LPCVOID, nSize: SIZE_T, lpNumberOfBytesWritten: ?*SIZE_T) callconv(.winapi) BOOL;
pub extern "kernel32" fn VirtualProtect(lpAddress: LPVOID, dwSize: SIZE_T, flNewProtect: DWORD, lpflOldProtect: *DWORD) callconv(.winapi) BOOL;
pub extern "kernel32" fn VirtualFree(lpAddress: LPVOID, dwSize: SIZE_T, dwFreeType: DWORD) callconv(.winapi) BOOL;
pub extern "kernel32" fn CloseHandle(hObject: HANDLE) callconv(.winapi) BOOL;
pub extern "kernel32" fn GetCurrentProcess() callconv(.winapi) HANDLE;
pub extern "kernel32" fn CreateThread(lpThreadAttributes: ?*SECURITY_ATTRIBUTES, dwStackSize: SIZE_T, lpStartAddress: LPTHREAD_START_ROUTINE, lpParameter: ?LPVOID, dwCreationFlags: DWORD, lpThreadId: ?*DWORD) callconv(.winapi) ?HANDLE;
pub extern "kernel32" fn WaitForSingleObject(hHandle: HANDLE, dwMilliseconds: DWORD) callconv(.winapi) DWORD;
