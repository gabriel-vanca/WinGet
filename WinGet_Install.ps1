<#
.SYNOPSIS
    Manually install WinGet
.DESCRIPTION
    Deployment tested on:
        - Windows 10
        - Windows 11
        - Windows Sandbox
        - Windows Server 2019
        - Windows Server 2022
        - Windows Server 2022 vNext (Windows Server 2025)
.EXAMPLE
    PS> ./WinGet_Install
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

$installationRequired = $False
$TestWinGet = Get-AppPackage -name "Microsoft.DesktopAppInstaller"

if ($TestWinGet){

    #Current: v1.5.1881 = 1.20.1881.0 = 2023.707.2257.0
    if([Version]$TestWinGet.Version -ge "1.20.1881.0") {
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
        Write-Host "Checking for VCLibs package compliance"
        $VCLibs_installScript =  Invoke-RestMethod https://raw.githubusercontent.com/gabriel-vanca/VCLibs/main/Deploy_MS_VCLibs.ps1
        Invoke-Expression $VCLibs_installScript
    } catch {
        throw "Microsoft.VCLibs.140.00.UWPDesktop installation failure"
    }

    # WinGet usually fails to install in the Windows Sandbox with the this method, but works on Windows Server
    Add-AppxPackage -Path $wingetDownloadPath

    if (Get-AppPackage -name "Microsoft.DesktopAppInstaller") {
        winget
        Write-Host "WinGet primary installation succesful" -ForegroundColor DarkGreen
    } else {
        Write-Host "WinGet primary installation failure" -ForegroundColor DarkRed        
        Write-Host "Trying a different method to install WinGet" -ForegroundColor Yellow

        # Download the WinGet install file to $env:Temp
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($wingetDownloadPath, $wingetLocalDownloadPath)
        # Install from file
        Add-AppxPackage $wingetLocalDownloadPath
        # Delete install file
        Remove-Item $wingetLocalDownloadPath

        if (Get-AppPackage -name "Microsoft.DesktopAppInstaller") {
            winget
            Write-Host "WinGet secondary installation method succesful" -ForegroundColor DarkGreen
        } else {
            Write-Error "WinGet secondary installation failure"
            Write-Host "This prompt will exit in 20 seconds" -ForegroundColor DarkMagenta
            Start-Sleep -Seconds 20
            Exit 1
        }
    }
}

Write-Host "Installing app updates through winget..."
winget upgrade --all
Write-Host "WinGet updates installed."