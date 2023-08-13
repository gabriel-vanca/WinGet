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

### 🌐Networked Install

If you want to quickly get WinGet installed and configured without downloading the script, run the below commands to download and run the script:

```
$deploymentScript = Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/WinGet/main/WinGet_Install.ps1"
Invoke-Expression $deploymentScript
```
