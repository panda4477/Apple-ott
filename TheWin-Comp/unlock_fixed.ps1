#requires -Version 5.1
# TrueID v2 SKWAMX3 FIRMWARE
# GitHub Raw / irm | iex edition
#
# Run:
# powershell -NoProfile -ExecutionPolicy Bypass -Command "irm 'https://github.com/panda4477/Apple-ott/raw/refs/heads/main/TheWin-Comp/unlock.ps1' | iex"

$ErrorActionPreference = 'Continue'

function Pause-Hidden {
    try {
        [void][Console]::ReadKey($true)
    }
    catch {
        [void](Read-Host)
    }
}

function Pause-Visible {
    Write-Host 'Press any key to continue . . .'
    Pause-Hidden
}

function Add-Candidate {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[string]]$List,

        [AllowNull()]
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    try {
        $FullPath = [IO.Path]::GetFullPath($Path)
    }
    catch {
        return
    }

    if (-not $List.Contains($FullPath)) {
        $List.Add($FullPath)
    }
}

function Test-ToolFolder {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return $false
    }

    # ใช้ update.exe เป็นตัวระบุโฟลเดอร์หลัก
    return (Test-Path -LiteralPath (Join-Path $Path 'update.exe') -PathType Leaf)
}

function Find-FirmwareFolder {
    $Candidates = New-Object 'System.Collections.Generic.List[string]'
    $Current = (Get-Location).Path

    # กำหนดตำแหน่งเองได้:
    # $env:TRUEID_FIRMWARE_DIR = 'D:\Package\firmware'
    Add-Candidate -List $Candidates -Path $env:TRUEID_FIRMWARE_DIR

    # ตรวจโฟลเดอร์ปัจจุบัน และไล่ย้อนขึ้นไปจนถึงรากไดรฟ์
    $Cursor = $Current
    $Level = 0

    while (-not [string]::IsNullOrWhiteSpace($Cursor) -and $Level -lt 12) {
        Add-Candidate -List $Candidates -Path $Cursor
        Add-Candidate -List $Candidates -Path (Join-Path $Cursor 'firmware')
        Add-Candidate -List $Candidates -Path (Join-Path $Cursor 'Firmware')

        # ตรวจโฟลเดอร์ย่อยชั้นแรก เผื่อแพ็กเกจถูกแตกซ้อนชื่อโฟลเดอร์
        try {
            Get-ChildItem -LiteralPath $Cursor -Directory -ErrorAction SilentlyContinue |
                ForEach-Object {
                    Add-Candidate -List $Candidates -Path $_.FullName
                    Add-Candidate -List $Candidates -Path (Join-Path $_.FullName 'firmware')
                }
        }
        catch {}

        try {
            $Parent = [DirectoryInfo]$Cursor
            if ($null -eq $Parent.Parent) {
                break
            }

            $Next = $Parent.Parent.FullName
            if ($Next -eq $Cursor) {
                break
            }

            $Cursor = $Next
        }
        catch {
            break
        }

        $Level++
    }

    # ตำแหน่งมาตรฐาน
    if (-not [string]::IsNullOrWhiteSpace($HOME)) {
        Add-Candidate -List $Candidates -Path (Join-Path $HOME 'Downloads\firmware')
        Add-Candidate -List $Candidates -Path (Join-Path $HOME 'Desktop\firmware')
    }

    foreach ($Candidate in $Candidates) {
        if (Test-ToolFolder -Path $Candidate) {
            return $Candidate
        }
    }

    return $null
}

function Get-MissingFirmwareFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FirmwareDir
    )

    $Required = @(
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

    $Missing = New-Object 'System.Collections.Generic.List[string]'

    foreach ($RelativePath in $Required) {
        $FullPath = Join-Path $FirmwareDir $RelativePath
        if (-not (Test-Path -LiteralPath $FullPath -PathType Leaf)) {
            $Missing.Add($RelativePath)
        }
    }

    return $Missing
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
    Write-Host '[ERROR] Cannot find the firmware folder.' -ForegroundColor Red
    Write-Host ''
    Write-Host 'The folder must contain update.exe, for example:'
    Write-Host ''
    Write-Host '  Package\'
    Write-Host '    firmware\'
    Write-Host '      update.exe'
    Write-Host '      fastboot.exe'
    Write-Host '      wait.exe'
    Write-Host '      dtb.img'
    Write-Host '      aik\'
    Write-Host '      img\'
    Write-Host ''
    Write-Host 'Current folder:' -ForegroundColor Yellow
    Write-Host "  $((Get-Location).Path)"
    Write-Host ''
    Pause-Visible
    return
}

$MissingFiles = @(Get-MissingFirmwareFiles -FirmwareDir $FirmwareDir)

if ($MissingFiles.Count -gt 0) {
    Write-Host 'TRUEID_SKWAMX3 - CHEETAH'
    Write-Host ''
    Write-Host "[INFO] Firmware folder found:" -ForegroundColor Green
    Write-Host "  $FirmwareDir"
    Write-Host ''
    Write-Host '[ERROR] Some required files are missing:' -ForegroundColor Red

    foreach ($MissingFile in $MissingFiles) {
        Write-Host "  MISSING: $MissingFile" -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host 'Copy the missing files into the firmware folder, then run again.'
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
