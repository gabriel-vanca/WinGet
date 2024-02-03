<#
.SYNOPSIS
    Installs and configures WinGet
.DESCRIPTION
    This is a guided script to install and config WinGet and
    configures winget packages to auto-update every two days at 10PM.

    🪟This deployment solution was tested on:

    - ✅Windows 10
    - ✅Windows 11
    - ✅Windows 11 Sandbox
    - ✅Windows Server 2019
    - ✅Windows Server 2022
    - ✅Windows Server 2022 vNext (Windows Server 2025)

    **The script does the following:**

    1. Checks whether WinGet is already installed.
        1. If it isn't installed yet, it checks whether Chocolatey is installed.
        2. If Chocolatey is present, it installs/update via Chocolatey.
        3. If Chocolatey is not present, is calls the Winget_Install.ps1 script to initiate manual installations.
            1. The script checks if VCLibs is installed.
            2. If VCLibs is not installed, it installs it.
            3. It installs WinGet.
            4. If the primary installation method fails, it used a redundancy method.
        4. It verifies if installation has been succesfull.
    2. Updates all WinGet packages
    3. Sets an auto-update configuration through Winget-AutoUpdate
.EXAMPLE
    ./Winget_Deploy
.LINK
	https://github.com/gabrielvanca/Winget
.NOTES
	Author: Gabriel Vanca
#>


#Requires -RunAsAdministrator

# Force use of TLS 1.2 for all downloads.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "Step 1: Installing/Updating WinGet" -ForegroundColor DarkBlue

$wingetRequiredVersion = "1.20.1881.0" #Current: v1.5.1881 = 1.20.1881.0 = 2023.707.2257.0

$installationRequired = $False
$TestWinGet = Get-AppPackage -name "Microsoft.DesktopAppInstaller"

if ($TestWinGet){
    if([Version]$TestWinGet.Version -ge $wingetRequiredVersion) {
        Write-Host "WinGet is already installed. Skipping installation step." -ForegroundColor DarkGreen
        $installationRequired = $False
    } else {
        Write-Host "WinGet is already installed, but version is old. Proceeding with installation" -ForegroundColor Yellow
        $installationRequired = $True
    }
} else {
    Write-Host "No existing WinGet installation found. Beginning installation."
    $installationRequired = $True
}

if($installationRequired) {
    try{
        # Expected path of the choco.exe file.
        $chocoInstallPath = "$Env:ProgramData/chocolatey/choco.exe"
        if (Test-Path "$chocoInstallPath") {
            Write-Host "Using Chocolatey to install/update Winget" -ForegroundColor DarkGreen
            Start-Sleep -Seconds 3
            choco upgrade winget-cli -y
        } else {
            Write-Host "Chocolatey not installed. Recommended method therefore unavailable." -ForegroundColor DarkYellow
            Start-Sleep -Seconds 5
            Write-Host "Installing/Updating Winget manually" -ForegroundColor DarkYellow
            Start-Sleep -Seconds 3
            $deploymentScript = Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/WinGet/main/Winget_Install.ps1"
            Invoke-Expression $deploymentScript
        }
    } catch {
        Write-Error "Winget installation failure"
        Start-Sleep -Seconds 2
        throw "Winget installation failure"
    }
}


Write-Host "Step 2: Installing app updates through winget"  -ForegroundColor DarkBlue
winget upgrade --all --silent --include-unknown --accept-package-agreements --accept-source-agreements
Write-Host "WinGet updates installed." -ForegroundColor DarkGreen


# https://github.com/Romanitho/Winget-AutoUpdate
Write-Host "Step 3: Installing and Configuring WinGet-AutoUpdate"  -ForegroundColor DarkBlue

# Ensure it runs in PowerShell Desktop
powershell {
    $deploymentScript = Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/WinGet/main/WAU_Install.ps1"
    Invoke-Expression $deploymentScript
}


# Write-Host "Step 4: Installing gsudo"  -ForegroundColor DarkBlue

# https://github.com/marticliment/WingetUI
# Write-Host "Step 5: Installs the WinGet GUI tool"  -ForegroundColor DarkBlue
# 
# winget install -e --id SomePythonThings.WingetUIStore  `
#                 --accept-package-agreements  `
#                 --accept-source-agreements   `
#                 --silent  `
#                 --disable-interactivity  `
#                 --override "/NoAutoStart /ALLUSERS /silent /supressmsgboxes /norestart"



