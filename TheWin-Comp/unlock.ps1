#requires -Version 5.1
# TrueID v2 SKWAMX3 FIRMWARE - IEX / GitHub Raw edition
# Run:
# powershell -NoProfile -ExecutionPolicy Bypass -Command "irm 'RAW_URL' | iex"

$ErrorActionPreference = 'Continue'

function Pause-Hidden {
    [void][Console]::ReadKey($true)
}

function Pause-Visible {
    Write-Host 'Press any key to continue . . .'
    [void][Console]::ReadKey($true)
}

function Test-FirmwareFolder {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return $false
    }

    $RequiredFiles = @(
        'update.exe',
        'fastboot.exe',
        'wait.exe',
        'dtb.img',
        'aik\android_win_tools\avb\bld.img',
        'img\boot.img',
        'img\logo.img',
        'img\vbmeta.img',
        'img\super.img',
        'img\recovery.img'
    )

    foreach ($File in $RequiredFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $Path $File) -PathType Leaf)) {
            return $false
        }
    }

    return $true
}

function Find-FirmwareFolder {
    $CurrentFolder = (Get-Location).Path
    $Candidates = New-Object System.Collections.Generic.List[string]

    # กำหนดเองได้ก่อนรัน:
    # $env:TRUEID_FIRMWARE_DIR = 'D:\TrueID\firmware'
    if (-not [string]::IsNullOrWhiteSpace($env:TRUEID_FIRMWARE_DIR)) {
        $Candidates.Add($env:TRUEID_FIRMWARE_DIR)
    }

    # ใช้โฟลเดอร์ปัจจุบัน เพราะการรันผ่าน irm | iex ไม่มี $PSScriptRoot
    $Candidates.Add((Join-Path $CurrentFolder 'firmware'))
    $Candidates.Add($CurrentFolder)

    # ตำแหน่งที่ผู้ใช้มักเก็บไฟล์
    if (-not [string]::IsNullOrWhiteSpace($HOME)) {
        $Candidates.Add((Join-Path $HOME 'Downloads\firmware'))
        $Candidates.Add((Join-Path $HOME 'Desktop\firmware'))
    }

    # ค้นหาโฟลเดอร์ย่อยชั้นแรกของตำแหน่งปัจจุบัน
    try {
        Get-ChildItem -LiteralPath $CurrentFolder -Directory -ErrorAction Stop |
            ForEach-Object { $Candidates.Add($_.FullName) }
    }
    catch {}

    foreach ($Candidate in ($Candidates | Select-Object -Unique)) {
        try {
            $Resolved = [IO.Path]::GetFullPath($Candidate)
        }
        catch {
            continue
        }

        if (Test-FirmwareFolder -Path $Resolved) {
            return $Resolved
        }
    }

    return $null
}

Clear-Host

try {
    $Host.UI.RawUI.WindowTitle = 'TrueID SKWAMX3 FIRMWARE'
    $Host.UI.RawUI.ForegroundColor = 'White'
    $Host.UI.RawUI.BackgroundColor = 'DarkBlue'
}
catch {}

try { cmd.exe /c 'chcp 65001>nul' } catch {}
try { cmd.exe /c 'color 1f' } catch {}
try { cmd.exe /c 'mode con lines=35 cols=67' } catch {}

Clear-Host

$FirmwareDir = Find-FirmwareFolder

if (-not $FirmwareDir) {
    Write-Host 'TRUEID_SKWAMX3 - CHEETAH'
    Write-Host ''
    Write-Host '[ERROR] Firmware files were not found.' -ForegroundColor Red
    Write-Host ''
    Write-Host 'Open PowerShell inside the package folder first:'
    Write-Host ''
    Write-Host '  Package\'
    Write-Host '    firmware\'
    Write-Host '      update.exe'
    Write-Host '      fastboot.exe'
    Write-Host '      wait.exe'
    Write-Host '      dtb.img'
    Write-Host '      aik\android_win_tools\avb\bld.img'
    Write-Host '      img\boot.img'
    Write-Host '      img\logo.img'
    Write-Host '      img\vbmeta.img'
    Write-Host '      img\super.img'
    Write-Host '      img\recovery.img'
    Write-Host ''
    Write-Host 'Current folder:' -ForegroundColor Yellow
    Write-Host "  $((Get-Location).Path)"
    Write-Host ''
    Pause-Visible
    return
}

Set-Location -LiteralPath $FirmwareDir

Write-Host 'TRUEID_SKWAMX3 - CHEETAH'
Write-Host ''
Write-Host '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
Write-Host '+           TrueID v2 SKWAMX3 FIRMWARE - TaWin           +'
Write-Host '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
Write-Host '       Device need connect to USB burning tool before'
Write-Host '                  then press ENTER'
Write-Host '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
Write-Host ''
Write-Host "[INFO] Firmware: $FirmwareDir" -ForegroundColor Green
Write-Host '[INFO] ENTER START'
Pause-Hidden

& '.\update.exe' identify 7
Write-Host ' 0k ...'
Pause-Visible

Write-Host 'bypassing step 1'
& '.\update.exe' bulkcmd 'store init 3' *> $null
& '.\wait.exe' 2
& '.\update.exe' bulkcmd 'store rom_protect off' *> $null
& '.\wait.exe' 2
& '.\update.exe' bulkcmd 'store scrub all' *> $null
& '.\wait.exe' 2
& '.\update.exe' bulkcmd 'store erase key' *> $null
& '.\wait.exe' 2
& '.\update.exe' bulkcmd 'store erase boot' *> $null
& '.\wait.exe' 2
& '.\update.exe' bulkcmd 'store erase data' *> $null
& '.\wait.exe' 2
& '.\update.exe' bulkcmd 'store erase dtb' *> $null

Write-Host 'bypassing step 2'
& '.\wait.exe' 2
& '.\update.exe' bulkcmd 'mmc erase 0 0x4000' *> $null
& '.\wait.exe' 2
& '.\update.exe' partition bootloader 'aik/android_win_tools/avb/bld.img'
& '.\wait.exe' 2
& '.\update.exe' partition _aml_dtb 'dtb.img' *> $null

Write-Host ''
Write-Host 'Check Mwrite status carefully before pressing Enter'
& '.\update.exe' bulkcmd 'reboot'

Write-Host '------------------------------------------------'
Write-Host 'Wait for the USB burning tool appear Connect success'
Write-Host 'Then press ENTER'
Write-Host '------------------------------------------------'
Pause-Visible

& '.\update.exe' bulkcmd 'fastboot'
& '.\wait.exe' 5
& '.\fastboot.exe' oem unlock *> $null
& '.\fastboot.exe' flashing unlock
& '.\fastboot.exe' flash bootloader 'aik/android_win_tools/avb/bld.img'
& '.\fastboot.exe' reboot

Write-Host '------------------------------------------------'
Write-Host 'Wait for the USB burning tool appear Connect success'
Write-Host 'Then press ENTER'
Write-Host '------------------------------------------------'
Pause-Visible

& '.\update.exe' bulkcmd 'fastboot'
& '.\wait.exe' 5
& '.\fastboot.exe' flash boot 'img/boot.img'
& '.\fastboot.exe' flash logo 'img/logo.img'
& '.\fastboot.exe' flash vbmeta 'img/vbmeta.img' *> $null
& '.\fastboot.exe' flash super 'img/super.img' *> $null
& '.\fastboot.exe' flash recovery 'img/recovery.img'

Write-Host '------------------------------------------------'
Write-Host '- DONE, REMOVE USB STICK THEN PRESS ENTER      -'
Write-Host '------------------------------------------------'
Pause-Visible

& '.\fastboot.exe' reboot
Clear-Host
