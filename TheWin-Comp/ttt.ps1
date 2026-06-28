```powershell
# ============================================================
# T3AMX3 / SKWAMX3 SERIAL TOOL
# CYBER CLEAN UI EDITION
# Hidden command mode + Force OK for OEM Update
# ============================================================

$USID = "24154048420000"

$LineID = "twpc-androiidtv110931"
$PhoneNumber = "0842979304"
$FacebookName = "Thawin Khamchanthuek"
$LineGroupUrl = "https://line.me/ti/g2/w5wgqzQbBo1wyBPhTXyIj0GEcH7Vic4cuKtR3w?utm_source=invitation&utm_medium=link_copy&utm_campaign=default&fbclid=IwY2xjawSuMNdleHRuA2FlbQIxMABicmlkETFoUzRsWlZiclpqTHMwdnFWc3J0YwZhcHBfaWQQMjIyMDM5MTc4ODIwMDg5MgABHmQ1Kbm6BjZY0yVjP9EHa6WOfUNxIZ6W3nzfAYZ7TG5A0CBfX7uRueUGS13P_aem_hn-HB18sqcSnizfO9Qqlsg"

# ================= PATH SETUP =================
$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ([string]::IsNullOrWhiteSpace($BaseDir)) {
    $BaseDir = Get-Location
}

Set-Location $BaseDir

$UpdateTool   = Join-Path $BaseDir "update.exe"
$FastbootTool = Join-Path $BaseDir "fastboot.exe"
$LogDir       = Join-Path $BaseDir "logs"

if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# ================= WINDOW SETUP =================
try {
    $rawUI = $Host.UI.RawUI
    $size = $rawUI.WindowSize
    $size.Width = 84
    $size.Height = 30
    $rawUI.WindowSize = $size
    $rawUI.BufferSize = $size
    $rawUI.WindowTitle = "T3AMX3 SKWAMX3 SERIAL TOOL"
}
catch {}

# ================= UI =================
function ClearUI {
    Clear-Host
}

function HR {
    Write-Host "  --------------------------------------------------------------------------" -ForegroundColor DarkGray
}

function TopUI {
    ClearUI
    Write-Host ""
    Write-Host "  ========================================================================" -ForegroundColor DarkCyan
    Write-Host "                     T3AMX3 / SKWAMX3 SERIAL TOOL                         " -ForegroundColor Cyan
    Write-Host "           FRRE Sofwara Unlock TRUE ID BY Thawin Khamchanthuek            " -ForegroundColor White
    Write-Host "  ========================================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  SUPPORT CONTACT" -ForegroundColor Yellow
    HR
    Write-Host "  LINE ID  : $LineID" -ForegroundColor Green
    Write-Host "  PHONE    : $PhoneNumber" -ForegroundColor Green
    Write-Host "  FACEBOOK : $FacebookName" -ForegroundColor Green
    Write-Host "  GROUP    : Press menu 4 to open LINE group" -ForegroundColor Cyan
    HR
    Write-Host ""
}

function MainMenu {
    TopUI

    Write-Host "  MAIN MENU" -ForegroundColor Yellow
    HR
    Write-Host ""
    Write-Host "    [1]  Check Devices" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    [2]  Flash Custom Serial SK/T3" -ForegroundColor Green
    Write-Host ""
    Write-Host "    [3]  Fix T3AMX3 USB Burning Mode" -ForegroundColor Green
    Write-Host ""
    Write-Host "    [4]  Support / Contact" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "    [5]  Exit Tool" -ForegroundColor Red
    Write-Host ""
    HR
    Write-Host ""
}

function WaitMenu {
    Write-Host ""
    HR
    Read-Host "  Press ENTER to return menu"
}

function LoadingBar {
    param(
        [string]$Text
    )

    Write-Host ""
    Write-Host "  $Text" -ForegroundColor Yellow
    Write-Host ""

    $steps = @(
        "[----------] 0%",
        "[#---------] 10%",
        "[##--------] 20%",
        "[###-------] 30%",
        "[####------] 40%",
        "[#####-----] 50%",
        "[######----] 60%",
        "[#######---] 70%",
        "[########--] 80%",
        "[#########-] 90%",
        "[##########] 100%"
    )

    foreach ($s in $steps) {
        Write-Host "  $s" -ForegroundColor Cyan
        Start-Sleep -Milliseconds 45
    }

    Write-Host ""
    Write-Host "  READY" -ForegroundColor Green
}

function SafeName {
    param([string]$Name)

    return ($Name -replace '[\\/:*?"<>| ]', '_')
}

# ================= COMMAND ENGINE =================
function RunCmd {
    param(
        [string]$Name,
        [string]$File,
        [string]$CmdLine,
        [bool]$ShowOutput = $false,
        [bool]$ForceOK = $false
    )

    Write-Host ""
    Write-Host "  TASK   : $Name" -ForegroundColor Yellow

    $CleanName = SafeName $Name
    $TimeNow = Get-Date -Format "yyyyMMdd_HHmmss"
    $LogFile = Join-Path $LogDir "$TimeNow`_$CleanName.log"

    try {
        if (!(Test-Path $File)) {
            "Tool not found: $File" | Out-File -FilePath $LogFile -Encoding UTF8

            if ($ForceOK -eq $true) {
                Write-Host "  STATUS : OK" -ForegroundColor Green
                Write-Host "  NOTE   : Force OK enabled" -ForegroundColor DarkGray
                return $true
            }

            Write-Host "  STATUS : ERROR" -ForegroundColor Red
            Write-Host "  REASON : Tool not found" -ForegroundColor Red
            return $false
        }

        $FullFile = (Resolve-Path $File).Path
        $CommandToRun = "`"$FullFile`" $CmdLine"

        $Result = & cmd.exe /d /c $CommandToRun 2>&1
        $ExitCode = $LASTEXITCODE

        "Command hidden by UI" | Out-File -FilePath $LogFile -Encoding UTF8
        "ExitCode: $ExitCode" | Out-File -FilePath $LogFile -Encoding UTF8 -Append
        "Output:" | Out-File -FilePath $LogFile -Encoding UTF8 -Append
        $Result | Out-File -FilePath $LogFile -Encoding UTF8 -Append

        if ($ExitCode -eq 0) {
            Write-Host "  STATUS : OK" -ForegroundColor Green

            if ($ShowOutput -eq $true) {
                Write-Host ""
                Write-Host "  OUTPUT:" -ForegroundColor Cyan

                if ($Result) {
                    $Result | ForEach-Object {
                        Write-Host "  $_" -ForegroundColor White
                    }
                }
                else {
                    Write-Host "  No output." -ForegroundColor DarkGray
                }
            }

            return $true
        }
        else {
            if ($ForceOK -eq $true) {
                Write-Host "  STATUS : OK" -ForegroundColor Green
                Write-Host "  NOTE   : This step is forced to pass" -ForegroundColor DarkGray
                return $true
            }

            Write-Host "  STATUS : FAIL" -ForegroundColor Red
            Write-Host "  LOG    : $LogFile" -ForegroundColor DarkGray

            if ($ShowOutput -eq $true -and $Result) {
                Write-Host ""
                Write-Host "  OUTPUT:" -ForegroundColor Cyan
                $Result | ForEach-Object {
                    Write-Host "  $_" -ForegroundColor White
                }
            }

            return $false
        }
    }
    catch {
        $_.Exception.Message | Out-File -FilePath $LogFile -Encoding UTF8

        if ($ForceOK -eq $true) {
            Write-Host "  STATUS : OK" -ForegroundColor Green
            Write-Host "  NOTE   : Force OK enabled" -ForegroundColor DarkGray
            return $true
        }

        Write-Host "  STATUS : ERROR" -ForegroundColor Red
        Write-Host "  LOG    : $LogFile" -ForegroundColor DarkGray
        return $false
    }
}

# ================= ACTION 1 =================
function CheckDevices {
    TopUI
    Write-Host "  MODE : CHECK DEVICES" -ForegroundColor Yellow
    HR

    LoadingBar "SCANNING DEVICE"

    RunCmd "Fastboot Devices" $FastbootTool "devices" $true $false

    Write-Host ""
    Write-Host "  CHECK DEVICES FINISHED" -ForegroundColor Green
    WaitMenu
}

# ================= ACTION 2 =================
function FlashSerial {
    TopUI
    Write-Host "  MODE : FLASH CUSTOM SERIAL SK/T3" -ForegroundColor Yellow
    HR

    LoadingBar "PREPARING SERIAL FLASH"

    RunCmd "Keyman Init"  $UpdateTool "bulkcmd `"keyman init 0x1234`"" $false $false
    RunCmd "Write USID"   $UpdateTool "bulkcmd `"keyman write usid str $USID`"" $false $false
    RunCmd "Save ENV"     $UpdateTool "bulkcmd `"saveenv`"" $false $false
    RunCmd "Reset Device" $UpdateTool "bulkcmd `"reset`"" $false $false

    Write-Host ""
    Write-Host "  FLASH SERIAL FINISHED" -ForegroundColor Green
    WaitMenu
}

# ================= ACTION 3 =================
function FixUsbMode {
    TopUI
    Write-Host "  MODE : FIX T3AMX3 USB BURNING MODE" -ForegroundColor Yellow
    HR

    LoadingBar "STARTING USB RECOVERY"

    RunCmd "Fastboot Devices"   $FastbootTool "devices" $true $false
    RunCmd "Unlock Bootloader"  $FastbootTool "flashing unlock" $false $false
    RunCmd "Get Device Info"    $FastbootTool "getvar all" $true $false

    # Force OK enabled for this command.
    RunCmd "OEM Update"         $FastbootTool "oem update" $false $true

    Write-Host ""
    Write-Host "  USB RECOVERY FINISHED" -ForegroundColor Green
    WaitMenu
}

# ================= ACTION 4 =================
function ShowSupport {
    TopUI
    Write-Host "  MODE : SUPPORT / CONTACT" -ForegroundColor Yellow
    HR
    Write-Host ""
    Write-Host "  LINE ID    : $LineID" -ForegroundColor Green
    Write-Host "  PHONE      : $PhoneNumber" -ForegroundColor Green
    Write-Host "  FACEBOOK   : $FacebookName" -ForegroundColor Green
    Write-Host "  LINE GROUP : $LineGroupUrl" -ForegroundColor Cyan
    Write-Host ""
    HR
    Write-Host ""
    Write-Host "  [1] Open LINE Group" -ForegroundColor Cyan
    Write-Host "  [2] Back to Menu" -ForegroundColor Red
    Write-Host ""

    $SupportChoice = Read-Host "  Select option [1-2]"

    switch ($SupportChoice) {
        "1" {
            Start-Process $LineGroupUrl
            Write-Host ""
            Write-Host "  LINE group opened." -ForegroundColor Green
            WaitMenu
        }

        default {
            return
        }
    }
}

# ================= MAIN LOOP =================
while ($true) {
    MainMenu

    $Choice = Read-Host "  Select option [1-5]"

    switch ($Choice) {
        "1" {
            CheckDevices
        }

        "2" {
            FlashSerial
        }

        "3" {
            FixUsbMode
        }

        "4" {
            ShowSupport
        }

        "5" {
            TopUI
            Write-Host "  Exit tool..." -ForegroundColor Red
            Start-Sleep -Seconds 1
            break
        }

        default {
            Write-Host ""
            Write-Host "  Invalid option. Please select 1 - 5." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
```
