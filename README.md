# WinGet

This is a guided script to install and config WinGet.

🪟This deployment solution was tested on:

* ✅ Windows 10
* ✅Windows 11
* ✅Windows 11 Sandbox
* ✅Windows Server 2019
* ✅Windows Server 2022
* ✅Windows Server 2022 vNext (Windows Server 2025)

## WinGet Deployment

```
./Winget_Deploy
```

The script does the following:

    1. Checks whether WinGet is already installed.

    1.1. If it isn't installed yet, it checks whether Chocolatey is installed.

    1.2. If Chocolatey is present, it installs/update via Chocolatey.

    1.3. If Chocolatey is not present, is calls the Winget_Install script to initiate manual installations.

    1.3.1. The script checks if VCLibs is installed.

    1.3.2. If VCLibs is not installed, it installs it.

    1.3.3. It installs WinGet.

    1.3.4. If the primary installation method fails, it used a redundancy method.

    1.4. It verifies if installation has been succesfull.

    2. Sets an auto-update configuration through`Winget-AutoUpdate`

    3. Installs the`WinGet GUI` tool

    4. Updates all WinGet packages

### 🌐Networked Install

If you want to quickly get WinGet and all the other tools deployerd and configured without downloading the script, run the below commands to download and run the script:

```
$deploymentScript = Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/WinGet/main/WinGet_Deploy.ps1"
Invoke-Expression $deploymentScript
```

## Manual Deployment

You can deploy WinGet manually without the usage of the `Winget_Deploy.ps1` script. There are two methods for that.

### ⚒️ Solution 1: Manual Install

#### Step 1: Install WinGet

```
./WinGet_Install
```

The script does the following:

    1. Checks whether WinGet is already installed.

    2. If it isn't installed yet, it checks whether VCLibs are installed.

    3. If VCLibs is not installed, it installed it.

    4. It install WinGet.

    5. If the primary installation method fails, it used a redundancy method.

    6. Verifies if installation has been successful

⚠️The installation of VCLibs, if necessary, is managed by another script I've written and available at: [https://github.com/gabriel-vanca/VCLibs](https://github.com/gabriel-vanca/VCLibs)

##### 🌐Networked Install

If you want to quickly get WinGet installed and configured without downloading the script, run the below commands to download and run the script:

```
$deploymentScript = Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/WinGet/main/WinGet_Install.ps1"
Invoke-Expression $deploymentScript
```

#### Step 2: Install the WinGet Update and GUI tools

After that, you can install the two WinGet tools (or either of them) by running:

* for WinGet-AutoUpdate ([https://github.com/Romanitho/Winget-AutoUpdate](https://github.com/Romanitho/Winget-AutoUpdate)):

  ```
  .\WAU_Install
  ```

  or

  ```
  powershell { # Ensures it runs in PowerShell Desktop
      $deploymentScript = Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/WinGet/main/WAU_Install.ps1"
      Invoke-Expression $deploymentScript
  }
  ```
* for WinGetUI ([https://github.com/marticliment/WingetUI](https://github.com/marticliment/WingetUI))

  ```
  winget install wingetui --accept-package-agreements --accept-source-agreements
  ```

### 📦Solution 2: Chocolatey Install

#### Step 1: Install Chocolatey

```
$scriptPath = "https://raw.githubusercontent.com/gabriel-vanca/Chocolatey/main/Chocolatey_Deploy.ps1"
$WebClient = New-Object Net.WebClient
$deploymentScript = $WebClient.DownloadString($scriptPath)
$deploymentScript = [Scriptblock]::Create($deploymentScript)
Invoke-Command -ScriptBlock $deploymentScript -ArgumentList ($False, "", "", $False) -NoNewScope

```

For more details, see the Chocolatey repository: [https://github.com/gabriel-vanca/Chocolatey](https://github.com/gabriel-vanca/Chocolatey)

#### Step 2: Install WinGet

```
choco install winget-cli -y
```

#### Step 3: Install the WinGet Update and GUI tools

After that, you can install the two WinGet tools (or either of them) by running:

* for WinGet-AutoUpdate ([https://github.com/Romanitho/Winget-AutoUpdate](https://github.com/Romanitho/Winget-AutoUpdate)):

  ```
  .\WAU_Install
  ```

  or

  ```
  powershell { # Ensures it runs in PowerShell Desktop
      $deploymentScript = Invoke-RestMethod "https://raw.githubusercontent.com/gabriel-vanca/WinGet/main/WAU_Install.ps1"
      Invoke-Expression $deploymentScript
  }
  ```
* for WinGetUI ([https://github.com/marticliment/WingetUI](https://github.com/marticliment/WingetUI))

  ```
  choco install wingetui -y
  ```
