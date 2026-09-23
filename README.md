<div align="center">

# 🎧 Nahimic Game Crash Fix
### Permanent 1-Click Fix for VALORANT, CS2, Apex Legends & Anti-Cheat Games

[![Created by @7_spg_7](https://img.shields.io/badge/Created%20by-@7_spg_7-E4405F?logo=instagram&logoColor=white)](https://instagram.com/7_spg_7)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?logo=windows&logoColor=white)](https://microsoft.com)
[![Anti-Cheat: Verified](https://img.shields.io/badge/Anti--Cheat-Vanguard%20%7C%20EAC%20%7C%20BattlEye-success)](#-compatibility)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status: 100% Working](https://img.shields.io/badge/Status-100%25%20Tested%20%26%20Working-brightgreen.svg)](#)

<p align="center">
  <b>Stops Nahimic Audio from injecting DLLs into games and causing immediate crashes (<code>0xc0000005</code>) — while keeping your Nahimic Equalizer and Smart Engine 100% working.</b>
</p>

**Created & Maintained by [@7_spg_7](https://instagram.com/7_spg_7)**

[⚡ 1-Click Fix](#-quick-1-click-fix) •
[🔍 The Problem](#-the-problem-why-games-crash) •
[💡 How It Works](#-how-the-fix-works) •
[🛠️ Manual Commands](#-manual-command-reference) •
[🎮 Compatibility](#-compatibility) •
[📸 Contact](#-contact--credits)

---

</div>

## ⚡ Quick 1-Click Fix

> [!TIP]
> **No technical knowledge needed!** This automated batch script applies the complete surgical fix in under 3 seconds.

1. **[Download Fix-NahimicValorant.bat](https://raw.githubusercontent.com/samgeorg777/nahimic-game-crash-fix/main/Fix-NahimicValorant.bat)** *(or clone/download this repository)*.
2. **Right-click** `Fix-NahimicValorant.bat` ➔ **Run as administrator**.
3. **Launch your game!** VALORANT or any anti-cheat title will now open immediately with zero crashes, while your Nahimic audio stays active.

---

## 🔍 The Problem: Why Games Crash

If you have a gaming PC or laptop with **Nahimic Audio** installed (common on MSI, Lenovo Legion, ASUS ROG, Alienware, and Dell systems), you may experience games that **refuse to open, crash instantly, or close with a black screen** seconds after clicking *Play*.

### 💥 The Crash Log
In the Windows Event Viewer (`eventvwr.msc`), the crash is always identical:

```text
Faulting application name: VALORANT-Win64-Shipping.exe
Faulting module name: ProductInfo.dll_unloaded
Exception code: 0xc0000005 (Access Violation)
Faulting application path: C:\Riot Games\VALORANT\live\ShooterGame\Binaries\Win64\VALORANT-Win64-Shipping.exe
Faulting module path: ProductInfo.dll
```

### 🛑 What Is Happening Behind the Scenes?

1. **Nahimic's Audio Hook:** When a game launches, Nahimic's audio hook daemon (`SysAudioHook2DaemonModule.dll`) intercepts the game's sound initialization.
2. **Forced DLL Injection:** Nahimic forcibly injects a helper library named **`ProductInfo.dll`** directly into the game's private memory to detect what title you are playing.
3. **Anti-Cheat Defense:** **Riot Vanguard** (or Easy Anti-Cheat / BattlEye) detects an unauthorized foreign DLL invading game memory. Vanguard forcibly kicks the DLL out of memory mid-execution.
4. **The Crash:** Because game threads were running instructions inside that memory space, unloading it instantly causes an **Access Violation (`0xc0000005`)** and kills the game.

```text
┌─────────────────────────┐
│ Game Launches (Valorant)│
└────────────┬────────────┘
             │ (Initializes Audio)
             ▼
┌─────────────────────────┐
│ Nahimic SysAudioHook2   │ ────► Forcibly Injects ProductInfo.dll into Game Memory
└─────────────────────────┘
                                                  │
                                                  ▼
┌─────────────────────────┐        ┌───────────────────────────────┐
│ Riot Vanguard / AntiCheat│ ────► │ FORCIBLY UNLOADS DLL          │
└─────────────────────────┘        └──────────────┬────────────────┘
                                                  │
                                                  ▼
                                   💥 ACCESS VIOLATION (0xc0000005)
                                      GAME TERMINATED INSTANTLY
```

---

## ⚠️ Why Online Advice Breaks Nahimic

Many online forum threads advise gamers to delete or rename `ProductInfo.dll`.

* ❌ **The Side Effect:** While Valorant launches, the **Nahimic app immediately breaks** and displays:
  > *"THIS DEVICE MAY NOT BE SUPPORTED"*
* 🧠 **Why?** `ProductInfo.dll` is also the file that Nahimic uses to read your motherboard's BIOS string to verify your genuine MSI/OEM hardware license. Without it, Nahimic locks you out of your equalizer and Smart Engine.

---

## 💡 How the Fix Works

The core breakthrough: **`ProductInfo.dll` was never the injector — it was merely the payload. The real injector was `SysAudioHook2DaemonModule.dll`.**

| Component | Status in This Fix | What It Accomplishes |
|---|---|---|
| **`ProductInfo.dll`** | ✅ **Kept Intact** | Nahimic verifies your motherboard license normally; no "Device not supported" error. |
| **`SysAudioHook2DaemonModule.dll`** | 🚫 **Disabled** | Kills the injection engine so Nahimic never attempts to hook into game memory. |
| **`BlackApps.dat`** | 🛡️ **Deployed** | Configures Nahimic's daemons to permanently ignore competitive games and anti-cheats. |
| **Hook Tasks** | ⏹️ **Disabled** | Disables `NahimicTask64` & `NahimicTask32` background loop daemons. |

---

## 📁 Repository Structure

```text
├── Fix-NahimicValorant.bat              # ⚡ 1-Click Automated Batch Script (Auto-Elevating)
├── Fix-NahimicValorant.ps1              # 📜 PowerShell Automation Script
├── Nahimic_and_Valorant_Fix_Explained.md # 📖 Plain-English Guide & Deep Dive
├── Complete_Technical_Guide_and_Commands.md # 🛠️ Full Technical Documentation & Commands
└── README.md                            # 📘 This Document
```

---

## 🛠️ Manual Command Reference

<details>
<summary><b>Click here to view manual step-by-step PowerShell commands</b></summary>

If you prefer applying the fix manually via an elevated PowerShell prompt:

```powershell
# 1. Stop Nahimic Services and Processes
Stop-Service -Name "NahimicService" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "Nahimic3", "NahimicSvc64", "NahimicSvc32", "RiotClientCrashHandler", "VALORANT*" -Force -ErrorAction SilentlyContinue

# 2. Disable the Audio Hook Injector (SysAudioHook2)
$hooks = @(
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\SysAudioHook2DaemonModule.dll",
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\x64\SysAudioHook2DaemonModule.dll"
)
foreach ($h in $hooks) {
    if (Test-Path $h) { Rename-Item -Path $h -NewName "$((Split-Path $h -Leaf)).disabled" -Force }
}

# 3. Ensure Hardware License DLL is Intact
$licenses = @(
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Regular\x64\ProductInfo.dll.disabled",
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\ProductInfo.dll.disabled",
    "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\x64\ProductInfo.dll.disabled"
)
foreach ($l in $licenses) {
    if (Test-Path $l) { Rename-Item -Path $l -NewName "ProductInfo.dll" -Force }
}

# 4. Deploy Exclusion List (BlackApps.dat)
$cfg = "C:\ProgramData\A-Volute\A-Volute.Nahimic\Modules\Scheduled\Configurator"
if (!(Test-Path $cfg)) { New-Item $cfg -ItemType Directory -Force | Out-Null }
$blacklist = @"
VALORANT.exe
VALORANT-Win64-Shipping.exe
RiotClientServices.exe
Riot Client.exe
vgc.exe
vgk.sys
cs2.exe
r5apex.exe
r5apex_dx12.exe
FortniteClient-Win64-Shipping.exe
DeadByDaylight-Win64-Shipping.exe
PUBG.exe
TslGame.exe
cod.exe
Overwatch.exe
"@
Set-Content -Path "$cfg\BlackApps.dat" -Value $blacklist -Encoding UTF8

# 5. Disable Background Injection Tasks & Restart Service
@("NahimicTask64", "NahimicTask32", "NahimicSvc64Run", "NahimicSvc32Run") | ForEach-Object {
    Stop-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue
    Disable-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue
}
Start-Service -Name "NahimicService"
```

</details>

---

## 🎮 Compatibility

This fix is confirmed working across all major games and hardware:

### Verified Games & Anti-Cheats
* 🛡️ **VALORANT** (Riot Vanguard)
* 🛡️ **Counter-Strike 2** (Valve Anti-Cheat / VAC)
* 🛡️ **Apex Legends** (Easy Anti-Cheat)
* 🛡️ **Fortnite** (EAC / BattlEye)
* 🛡️ **Call of Duty: Modern Warfare & Warzone** (Ricochet)
* 🛡️ **Rainbow Six Siege** (BattlEye)

### Verified Hardware Platforms
* 💻 **MSI** (GF63 Thin, Katana, Raider, Stealth, Titan, Bravo)
* 💻 **Lenovo Legion** (Legion 5, Legion 7, Slim, LOQ)
* 💻 **ASUS ROG & TUF** (Strix, Zephyrus, Dash)
* 💻 **Alienware / Dell** (m15, m16, x17, G15, G16)

---

## 📸 Contact & Credits

* **Author:** [@7_spg_7](https://instagram.com/7_spg_7)
* **Instagram:** [instagram.com/7_spg_7](https://instagram.com/7_spg_7)
* **License:** Distributed under the [MIT License](LICENSE). Free for all gamers to use, share, and improve.

⭐ **Found this helpful?** Drop a star on this repository and share it with other gamers facing Nahimic audio crashes!
