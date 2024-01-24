# WinGet

This is a guided script to install and config WinGet and configures winget packages to auto-update every two days at 10PM.

🪟This deployment solution was tested on:

* ✅Windows 10
* ✅Windows 11
* ✅Windows 11 Sandbox
* ✅Windows Server 2019
* ✅Windows Server 2022
* ✅Windows Server 2022 vNext (Windows Server 2025)

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

## 🚀WinGet Deployment

```
./Winget_Deploy
```

⚠️ Make sure you run this using admin priviledges.

### 🌐Networked Install

If you want to quickly get WinGet and all the other tools deployerd and configured without downloading the script, run the below commands to download and run the script:

```
# Ensure it runs in PowerShell Desktop
powershell {
    $deploymentScript = Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/WinGet/main/WAU_Install.ps1"
    Invoke-Expression $deploymentScript
}

```
