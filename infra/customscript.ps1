Start-Transcript "C:\BootstrapHost_log.txt"
$ErrorActionPreference = 'SilentlyContinue'

# Create path OpsDir
$opsDir = "C:\OpsDir"
New-Item -Path $opsDir -ItemType directory -Force

# Create path iso
$iso = "C:\iso"
New-Item -Path $iso -ItemType directory -Force


# download windows server 2022 eval version iso
$downloadUrl = "https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US"
$outputPath = Join-Path -Path $iso -ChildPath "WindowsServer2022.iso"
Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath

# Download PostReboot script
$downloadUrl = "https://raw.githubusercontent.com/koenraadhaedens/azd-nestedhv-dc-rtr/refs/heads/main/infra/PostRebootConfigure.ps1"
$outputPath = Join-Path -Path $opsdir -ChildPath "PostRebootConfigure.ps1"

Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath

# Register task to run post-reboot script once host is rebooted after Hyper-V install
Write-Output "Register post-reboot script as scheduled task"
$action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File $opsDir\PostRebootConfigure.ps1"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "SetUpVMs" -Action $action -Trigger $trigger -Principal $principal


# Install Hyper-V feature
Write-Output "Install Hyper-V and restart"
Stop-Transcript
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart