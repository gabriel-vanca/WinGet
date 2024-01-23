<#
.SYNOPSIS
    Manually installs Winget
.DESCRIPTION
    The script does the following:
    1. Checks whether WinGet is already installed.
    2. If it isn't installed yet, it checks whether VCLibs are installed.
    3. If VCLibs is not installed, it installed it.
    4. It install WinGet.
    5. If the primary installation method fails, it used a redundancy method.
    6. Verifies if installation has been successful

    Deployment tested on:
        - Windows 10
        - Windows 11
        - Windows Sandbox
        - Windows Server 2019
        - Windows Server 2022
        - Windows Server 2022 vNext (Windows Server 2025)
.EXAMPLE
    ./WinGet_Install
.LINK
	https://github.com/gabrielvanca/WinGet
.NOTES
	Author: Gabriel Vanca
#>


#Requires -RunAsAdministrator

# Force use of TLS 1.2 for all downloads.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$wingetDownloadPath = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$wingetLocalDownloadPath = "$env:Temp\winget.msixbundle"
$wingetRequiredVersion = "1.20.1881.0" #Current: v1.5.1881 = 1.20.1881.0 = 2023.707.2257.0

$installationRequired = $False
$TestWinGet = Get-AppPackage -name "Microsoft.DesktopAppInstaller"
if ($TestWinGet){
    if([Version]$TestWinGet.Version -ge $wingetRequiredVersion) {
        Write-Host "WinGet is already installed and version is up to date. Skipping installation step." -ForegroundColor DarkGreen
        $installationRequired = $False
    } else {
        Write-Host "WinGet is already installed, but version is old. Proceeding with installation" -ForegroundColor Yellow
        $installationRequired = $True
    }
} else {
    Write-Host "No existing WinGet installation found. Beginning installation." -ForegroundColor Yellow
    $installationRequired = $True
}

if($installationRequired) {
    try{
        Write-Host "Checking for VCLibs package compliance"
        $VCLibs_installScript =  Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/VCLibs/main/Deploy_MS_VCLibs.ps1"
        Invoke-Expression $VCLibs_installScript
    } catch {
        Write-Error "Microsoft.VCLibs.140.00.UWPDesktop installation failure"
        Start-Sleep -Seconds 2
        throw "Microsoft.VCLibs.140.00.UWPDesktop installation failure"
    }

    # WinGet usually fails to install in the Windows Sandbox with the this method, but works on Windows Server
    try{
        Add-AppxPackage -Path $wingetDownloadPath
    } catch {
        Write-Host "WinGet primary installation failure" -ForegroundColor DarkRed
    }

    $TestWinGet = Get-AppPackage -name "Microsoft.DesktopAppInstaller"
    if ($TestWinGet -and ([Version]$TestWinGet.Version -ge $wingetRequiredVersion)) {
        winget -v
        Write-Host "WinGet primary installation succesful" -ForegroundColor DarkGreen
    } else {
        Write-Host "WinGet primary installation failure" -ForegroundColor DarkRed        
        Write-Host "Trying a different method to install WinGet" -ForegroundColor Yellow

        # Download the WinGet install file to $env:Temp
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($wingetDownloadPath, $wingetLocalDownloadPath)
        # Install from file
        try{
            Add-AppxPackage $wingetLocalDownloadPath
        } catch {
            Write-Host "WinGet secondary installation failure" -ForegroundColor DarkRed
        }
        # Delete install file
        Remove-Item $wingetLocalDownloadPath

        $TestWinGet = Get-AppPackage -name "Microsoft.DesktopAppInstaller"
        if ($TestWinGet -and ([Version]$TestWinGet.Version -ge $wingetRequiredVersion)) {
            winget -v
            Write-Host "WinGet secondary installation method succesful" -ForegroundColor DarkGreen
        } else {
            Write-Error "WinGet secondary installation failure"
            Start-Sleep -Seconds 4
            throw "WinGet secondary installation failure"
        }
    }
}
