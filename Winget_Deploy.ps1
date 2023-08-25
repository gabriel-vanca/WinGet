<#
.SYNOPSIS
    Installs and configures WinGet
.DESCRIPTION
    The script will:
    1. Checks whether WinGet is already installed.
        1.1. If it isn't installed yet, it checks whether Chocolatey is installed.
        1.2. If Chocolatey is present, it installs/update via Chocolatey.
        1.3. If Chocolatey is not present, is calls the Winget_Install script to initiate manual installations.
            1.3.1. The script checks if VCLibs is installed.
            1.3.2. If VCLibs is not installed, it installs it.
            1.3.3. It installs WinGet.
        1.4. It verifies if installation has been succesfull.
    2. Sets an auto-update configuration
    3. Installs the WinGet GUI tool
    4. Updates all WinGet packages

    Deployment tested on:
        - Windows 10
        - Windows 11
        - Windows Sandbox
        - Windows Server 2019
        - Windows Server 2022
        - Windows Server 2022 vNext (Windows Server 2025)
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
$WAU_WebDownloadPath = "https://github.com/Romanitho/Winget-AutoUpdate/releases/latest/download/WAU.zip"
$WAU_LocalDownloadPath = "$env:Temp\WAU.zip"
$WAU_LocalUnzipPath = "$env:Temp\WAU"

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
            Start-Sleep -Seconds 5
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
        throw "Winget installation failure"
    }
}


Write-Host "Step 2: Installing and Configuring WinGet-AutoUpdate"  -ForegroundColor DarkBlue
# Download the WinGet-AutoUpdate install to $env:Temp
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($WAU_WebDownloadPath, $WAU_LocalDownloadPath)
# Unlocking zip
Unblock-File -Path $WAU_LocalDownloadPath
# Unzip
try {
    Expand-Archive -Path $WAU_LocalDownloadPath -DestinationPath $WAU_LocalUnzipPath -Force
} catch {
    throw "Unzipping WAU failed"
}
# Delete downloaded zip
Remove-Item $WAU_LocalDownloadPath
# Unlocking unzipped files (optional)
Get-ChildItem $WAU_LocalUnzipPath -Recurse | Unblock-File

powershell {
    Set-ExecutionPolicy RemoteSigned -Force
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $true) {
        Write-Host "This session is running with Administrator priviledges." -ForegroundColor DarkGreen
    } else {
        Write-Host "This session is not running with Administrator priviledges." -ForegroundColor DarkRed    
        Write-Host "Please close this prompt and restart as admin" -ForegroundColor DarkRed
        Start-Sleep -Seconds 5
        throw "This session is not running with Administrator priviledges."
    }

    Set-Location "$env:Temp\WAU"
    .\Winget-AutoUpdate-Install -Silent -UpdatesAtLogon -UpdatesInterval Weekly -InstallUserContext -StartMenuShortcut -DesktopShortcut
} 

# Delete unziped files
Remove-Item -Path $WAU_LocalUnzipPath -Force -Recurse


Write-Host "Step 3: Installs the WinGet GUI tool"

winget install wingetui --accept-package-agreements --accept-source-agreements


Write-Host "Step 4: Installing app updates through winget"
winget upgrade --all
Write-Host "WinGet updates installed."

