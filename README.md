# WinGet

This is a guided script to install and config WinGet.

🪟This deployment solution was tested on:

* ✅ Windows 10
* ✅Windows 11
* ✅Windows 11 Sandbox
* ✅Windows Server 2019
* ✅Windows Server 2022
* ✅Windows Server 2022 vNext (Windows Server 2025)

## ⚒️ Solution 1: Manual Install

```
./WinGet_Install
```

The script does the following:

    1. Checks whether WinGet is already installed.

    2. If it isn't installed yet, it checks whether VCLibs are installed.

    3. If VCLibs is not installed, it installed it.

    4. It install WinGet.

    5. Verifies if installation has been succesfull.

    4. Updates all WinGet packages

    5. Sets an auto-update configuration

    6. Installs the WinGet GUI tool

### 🌐Networked Install

If you want to quickly get WinGet installed and configured without downloading the script, run the below commands to download and run the script:

```
$deploymentScript = Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/WinGet/main/WinGet_Install.ps1"
Invoke-Expression $deploymentScript
```

## 📦Solution 2: Chocolatey Install

### Step 1: Install Chocolatey

```
$scriptPath = "https://raw.githubusercontent.com/gabriel-vanca/Chocolatey/main/Chocolatey_Deploy.ps1"
$WebClient = New-Object Net.WebClient
$deploymentScript = $WebClient.DownloadString($scriptPath)
$deploymentScript = [Scriptblock]::Create($deploymentScript)
Invoke-Command -ScriptBlock $deploymentScript -ArgumentList ($False, "", "", $False) -NoNewScope

```

For more details, see the Chocolatey repository: [https://github.com/gabriel-vanca/Chocolatey](https://github.com/gabriel-vanca/Chocolatey)

### Step 2: Install WinGet

```
choco install winget-cli -y
```
