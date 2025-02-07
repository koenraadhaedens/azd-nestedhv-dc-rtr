Start-Transcript "C:\BootstrapHost_log.txt"
$ErrorActionPreference = 'SilentlyContinue'

# Create path OpsDir
$opsDir = "C:\OpsDir"
New-Item -Path $opsDir -ItemType directory -Force

# Create path iso
$iso = "C:\iso"
New-Item -Path $iso -ItemType directory -Force


# download windows server 2022 eval version iso
# $downloadUrl = "https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US"
# $outputPath = Join-Path -Path $iso -ChildPath "WindowsServer2022.iso"
# Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath

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

# install 7zip
Write-Output "Download with Bits"
$sourceFolder = 'https://sagithubdemokhd.blob.core.windows.net/public'
$downloads = @( `
     "$sourceFolder/7za.exe" `
    ,"$sourceFolder/7za.dll" `
    ,"$sourceFolder/7zxa.dll" `
    )

$destinationFiles = @( `
     "c:\OpsDir\7za.exe" `
    ,"c:\OpsDir\7za.dll" `
    ,"c:\OpsDir\7zxa.dll" `
    )

Import-Module BitsTransfer
Start-BitsTransfer -Source $downloads -Destination $destinationFiles

# Install Hyper-V feature
Write-Output "Install Hyper-V and restart"
Stop-Transcript
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart