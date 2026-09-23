# Technical Guide & Commands: Fixing Game Crashes Caused by Nahimic DLL Injection

> **Author:** [@7_spg_7](https://instagram.com/7_spg_7)  
> *Instagram: [https://instagram.com/7_spg_7](https://instagram.com/7_spg_7)*

---

## 1. The Core Issue: DLL Injection vs. Anti-Cheat

When running games protected by modern anti-cheat systems (**Riot Vanguard, Easy Anti-Cheat, BattlEye, Ricochet, VAC**), systems with **Nahimic Audio** frequently crash immediately upon launch.

### Affected Games Include:
* **VALORANT** (`VALORANT-Win64-Shipping.exe`)
* **Counter-Strike 2** (`cs2.exe`)
* **Apex Legends** (`r5apex.exe`)
* **Fortnite** (`FortniteClient-Win64-Shipping.exe`)
* **Call of Duty** (`cod.exe`)
* **Rainbow Six Siege** (`RainbowSix.exe`)

---

## 2. Technical Crash Analysis

When a game crashes due to Nahimic, the Windows Application Event Log records the following error:

```text
Faulting application name: VALORANT-Win64-Shipping.exe
Faulting module name: ProductInfo.dll_unloaded, version: 1.10.15.0
Exception code: 0xc0000005 (Access Violation)
Fault offset: 0x0000000000016b60
Faulting application path: C:\Riot Games\VALORANT\live\ShooterGame\Binaries\Win64\VALORANT-Win64-Shipping.exe
Faulting module path: ProductInfo.dll
```

### The Injection Pipeline:
1. When the game executable starts, it initializes the Windows Audio subsystem (WASAPI/DirectSound).
2. Nahimic’s audio hook daemon module (**`SysAudioHook2DaemonModule.dll`**) intercepts the audio initialization.
3. It calls `LoadLibrary` to inject **`ProductInfo.dll`** directly into the game's running process memory.
4. **Riot Vanguard** detects an unverified third-party DLL inside the protected game process.
5. Vanguard forcefully unloads the module (`ProductInfo.dll_unloaded`), causing an unhandled memory **Access Violation (`0xc0000005`)** and killing the game.

### The Catch with `ProductInfo.dll`:
* If you delete `ProductInfo.dll`, the game launches, but the **Nahimic app breaks** (*"This device may not be supported"*) because the app needs `ProductInfo.dll` to read your motherboard's hardware license.
* **The Real Fix:** Leave `ProductInfo.dll` alone and disable **`SysAudioHook2DaemonModule.dll`** instead. This completely disables the injection mechanism without breaking the license check.

---

## 3. Full Command Reference (Manual Commands)

Here are the exact PowerShell and terminal commands used to diagnose and resolve this issue:

### Step A: Verify the Injection in Memory
To see which processes currently have `ProductInfo.dll` injected into them:

```powershell
Get-Process | ForEach-Object {
    $p = $_
    try {
        if ($p.Modules.ModuleName -contains "ProductInfo.dll") {
            [PSCustomObject]@{ Id = $p.Id; ProcessName = $p.ProcessName; Path = $p.Path }
        }
    } catch {}
} | Format-Table -AutoSize
```
*(Before the fix, this will show `Riot Client` or other non-audio processes having the DLL injected).*

---

### Step B: Kill Stuck Background Crash Handlers
```powershell
Stop-Process -Name "VALORANT*", "RiotClientCrashHandler" -Force -ErrorAction SilentlyContinue
```

---

### Step C: Stop Nahimic Services
```powershell
Stop-Service -Name "NahimicService" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "Nahimic3", "NahimicSvc64", "NahimicSvc32" -Force -ErrorAction SilentlyContinue
```

---

### Step D: Ensure Hardware License DLL is Intact
Make sure `ProductInfo.dll` is **NOT** deleted or renamed, so Nahimic can verify your hardware license:

```powershell
$licensePaths = @(
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Regular\x64",
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled",
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\x64"
)
foreach ($dir in $licensePaths) {
    if (Test-Path "$dir\ProductInfo.dll.disabled") {
        Rename-Item -Path "$dir\ProductInfo.dll.disabled" -NewName "ProductInfo.dll" -Force
    }
}
```

---

### Step E: Neutralize the Hook Injector (`SysAudioHook2DaemonModule.dll`)
Disable the injection engine so it cannot load `ProductInfo.dll` into any external game:

```powershell
$hooks = @(
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\SysAudioHook2DaemonModule.dll",
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\x64\SysAudioHook2DaemonModule.dll"
)
foreach ($h in $hooks) {
    if (Test-Path $h) {
        Rename-Item -Path $h -NewName "$((Split-Path $h -Leaf)).disabled" -Force
    }
}
```

---

### Step F: Create the Game Exclusion List (`BlackApps.dat`)
Nahimic maintains an exclusion list for applications it must never interact with. Deploy this list to ensure games are skipped:

```powershell
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
```

---

### Step G: Disable Background Hook Tasks & Restart Service
```powershell
@("NahimicTask64", "NahimicTask32", "NahimicSvc64Run", "NahimicSvc32Run") | ForEach-Object {
    Stop-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue
    Disable-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue
}

# Start the audio service back up
Start-Service -Name "NahimicService"
```

---

## 4. Verification

After running the commands (or the 1-click script), verify that the fix is working:

```powershell
# 1. Check that NahimicService is running:
Get-Service -Name "NahimicService" | Format-Table Name, Status

# 2. Check process memory:
Get-Process | ForEach-Object {
    $p = $_
    try {
        if ($p.Modules.ModuleName -contains "ProductInfo.dll") {
            [PSCustomObject]@{ Process = $p.ProcessName; ID = $p.Id }
        }
    } catch {}
} | Format-Table -AutoSize
```

**Expected Result:**
* `NahimicService` is **Running**.
* In the memory check, **only Nahimic's own processes** (`NahimicService`, `NahimicSvc64`) appear. 
* No games, game launchers (Riot Client, Steam), or third-party apps will ever have Nahimic DLLs injected into them again.
* **VALORANT and other anti-cheat games will now launch immediately without crashing.**

---

*Authored by [@7_spg_7](https://instagram.com/7_spg_7) — Follow on Instagram for updates & support.*
