# ========================================================
# สคริปต์สำหรับดาวน์โหลดและเปิดใช้งาน Test.exe อัตโนมัติ
# ========================================================

# [1] ลิงก์ดาวน์โหลดตรงของ Test.exe จาก GitHub ZenX ของคุณ
$exeUrl = "https://raw.githubusercontent.com/zenx285/ZenX/main/Test.exe"

# [2] กำหนดโฟลเดอร์ปลายทางในเครื่องผู้ใช้ (ใช้ AppData ของผู้ใช้ ไม่ติดสิทธิ์ Admin)
$installDir = "$env:LOCALAPPDATA\TestApp"
$exePath = "$installDir\Test.exe"

try {
    # สร้างโฟลเดอร์หากยังไม่มี
    if (!(Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       กำลังเตรียมความพร้อม Test.exe    " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    # ดาวน์โหลดไฟล์ Test.exe
    Write-Host "[+] กำลังดาวน์โหลดไฟล์โปรแกรม..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing

    Write-Host "[+] ดาวน์โหลดเสร็จเรียบร้อย!" -ForegroundColor Green

    # (ตัวเลือกเสริม) สร้าง Shortcut บน Desktop ให้ผู้ใช้เปิดครั้งต่อไปได้ง่ายขึ้น
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = "$desktopPath\Test.lnk"
    if (!(Test-Path $shortcutPath)) {
        $wscriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $wscriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.WorkingDirectory = $installDir
        $shortcut.Save()
        Write-Host "[+] สร้างไอคอนทางลัดบนหน้า Desktop แล้ว" -ForegroundColor Gray
    }

    # เปิดโปรแกรมทันที
    Write-Host "[+] กำลังเปิดโปรแกรม Test.exe..." -ForegroundColor Green
    Start-Process -FilePath $exePath -WorkingDirectory $installDir

}
catch {
    Write-Host "[!] เกิดข้อผิดพลาด: $_" -ForegroundColor Red
    Pause
}

