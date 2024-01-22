<#
.SYNOPSIS
    Installs and configures WinGet
.DESCRIPTION
    The script will install and configure Winget and Winget-AutoUpdate
    (https://github.com/Romanitho/Winget-AutoUpdate)

    Deployment tested on:
        - Windows 10
        - Windows 11
        - Windows Sandbox
        - Windows Server 2019
        - Windows Server 2022
        - Windows Server 2022 vNext (Windows Server 2025)
.EXAMPLE
    ./WAU_Install
.LINK
	https://github.com/gabrielvanca/Winget
.NOTES
	Author: Gabriel Vanca
#>

#Requires -RunAsAdministrator
#Requires -PSEdition Desktop

# Force use of TLS 1.2 for all downloads.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ($NULL -eq $IsWindows) checks for Windows Sandbox enviroment
if($IsWindows -or ($NULL -eq $IsWindows)) {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $true) {
        Write-Host "This session is running with Administrator priviledges." -ForegroundColor DarkGreen
    } else {
        Write-Host "This session is not running with Administrator priviledges." -ForegroundColor DarkRed    
        Write-Host "Please close this prompt and restart as admin" -ForegroundColor DarkRed
        Start-Sleep -Seconds 5
        throw "This session is not running with Administrator priviledges."
    }
}

$WAU_WebDownloadPath = "https://github.com/Romanitho/Winget-AutoUpdate/releases/latest/download/WAU.zip"
$WAU_LocalDownloadPath = "$env:Temp\WAU.zip"
$WAU_LocalUnzipPath = "$env:Temp\WAU"

Write-Host "Setting Execution Policy" -ForegroundColor Magenta

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Set-ExecutionPolicy Bypass -Scope Process -Force;


Write-Host "WinGet-AutoUpdate deployment commenced"  -ForegroundColor DarkGreen

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

# Running Install/Update Script
Set-Location $WAU_LocalUnzipPath
.\Winget-AutoUpdate-Install -Silent -UpdatesAtLogon -UpdatesInterval Weekly -InstallUserContext -StartMenuShortcut -DesktopShortcut
Set-Location ..

# Delete unziped files
Write-Host "Cleaning temporary files."
Remove-Item -Path $WAU_LocalUnzipPath -Force -Recurse

# Check installation presence
$WingetUpdatePath = "$env:ProgramData\Winget-AutoUpdate"
if (Test-Path $WingetUpdatePath) {
    Write-Host "WinGet-AutoUpdate installation presence detection completed succesfully" -ForegroundColor DarkGreen
} else {
    Write-Error "WinGet-AutoUpdate installation presence detection failed"
}
