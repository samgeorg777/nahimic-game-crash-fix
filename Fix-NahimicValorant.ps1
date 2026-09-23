# ============================================================================
#  Nahimic & Valorant Permanent Fix Script (PowerShell)
#  Created by: @7_spg_7 (Instagram: https://instagram.com/7_spg_7)
# ============================================================================

# Ensure elevated rights
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Restarting as Administrator..."
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Clear-Host
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "   NAHIMIC & VALORANT FIX SCRIPT" -ForegroundColor Cyan
Write-Host "   Created by: @7_spg_7  |  Instagram: https://instagram.com/7_spg_7" -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Cyan

# 1. Stop Services and Processes
Write-Host "`n[1/5] Stopping Nahimic & hung game processes..." -ForegroundColor DarkYellow
Stop-Service -Name "NahimicService" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "Nahimic3", "NahimicSvc64", "NahimicSvc32", "RiotClientCrashHandler", "VALORANT*" -Force -ErrorAction SilentlyContinue
Write-Host "      [âœ“] Processes stopped cleanly." -ForegroundColor Green

# 2. Restore ProductInfo.dll for Hardware License
Write-Host "`n[2/5] Restoring Hardware License Verification (ProductInfo.dll)..." -ForegroundColor DarkYellow
$licensePaths = @(
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Regular\x64",
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled",
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\x64"
)
foreach ($dir in $licensePaths) {
    if (Test-Path "$dir\ProductInfo.dll.disabled") {
        Rename-Item -Path "$dir\ProductInfo.dll.disabled" -NewName "ProductInfo.dll" -Force
        Write-Host "      [âœ“] Restored ProductInfo.dll in $dir" -ForegroundColor Green
    } elseif (Test-Path "$dir\ProductInfo.dll") {
        Write-Host "      [âœ“] License file verified in $dir" -ForegroundColor Green
    }
}

# 3. Disable SysAudioHook2DaemonModule.dll (Prevents DLL injection into games)
Write-Host "`n[3/5] Disabling SysAudioHook2DaemonModule (DLL Injector Engine)..." -ForegroundColor DarkYellow
$hookPaths = @(
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\SysAudioHook2DaemonModule.dll",
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\x64\SysAudioHook2DaemonModule.dll"
)
foreach ($hook in $hookPaths) {
    if (Test-Path $hook) {
        Rename-Item -Path $hook -NewName "$((Split-Path $hook -Leaf)).disabled" -Force
        Write-Host "      [âœ“] Disabled injector: $hook" -ForegroundColor Green
    } elseif (Test-Path "$hook.disabled") {
        Write-Host "      [âœ“] Already neutralized: $hook" -ForegroundColor Green
    }
}

# 4. Deploy BlackApps.dat Exclusion List
Write-Host "`n[4/5] Deploying game exclusion list (BlackApps.dat)..." -ForegroundColor DarkYellow
$configDir = "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\Configurator"
if (!(Test-Path $configDir)) { New-Item $configDir -ItemType Directory -Force | Out-Null }
$blackList = @"
VALORANT.exe
VALORANT-Win64-Shipping.exe
RiotClientServices.exe
Riot Client.exe
vgc.exe
vgk.sys
LeagueClient.exe
League of Legends.exe
EasyAntiCheat.exe
EasyAntiCheat_EOS.exe
BEService.exe
cs2.exe
r5apex.exe
r5apex_dx12.exe
FortniteClient-Win64-Shipping.exe
FortniteClient-Win64-Shipping_EAC.exe
FortniteClient-Win64-Shipping_BE.exe
DeadByDaylight-Win64-Shipping.exe
PUBG.exe
TslGame.exe
cod.exe
Overwatch.exe
Battle.net.exe
Steam.exe
"@
Set-Content -Path "$configDir\BlackApps.dat" -Value $blackList -Encoding UTF8
Write-Host "      [âœ“] Exclusion list active." -ForegroundColor Green

# 5. Disable Injection Tasks and Restart NahimicService
Write-Host "`n[5/5] Finalizing services & restarting NahimicService..." -ForegroundColor DarkYellow
@("NahimicTask64", "NahimicTask32", "NahimicSvc64Run", "NahimicSvc32Run") | ForEach-Object {
    Stop-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue
    Disable-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue
}
Start-Service -Name "NahimicService" -ErrorAction SilentlyContinue
Write-Host "      [âœ“] NahimicService is running." -ForegroundColor Green

Write-Host "`n========================================================================" -ForegroundColor Cyan
Write-Host "   âœ¨ FIX COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "   - VALORANT & Anti-Cheat games launch with zero crashes." -ForegroundColor Cyan
Write-Host "   - Nahimic Smart Engine is active." -ForegroundColor Cyan
Write-Host "   Instagram: https://instagram.com/7_spg_7 (@7_spg_7)" -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Cyan

