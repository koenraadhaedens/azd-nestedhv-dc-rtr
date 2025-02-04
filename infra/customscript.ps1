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



# Install Hyper-V feature
Write-Output "Install Hyper-V and restart"
Stop-Transcript
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -restart