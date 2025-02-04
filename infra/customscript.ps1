
# download windows server 2022 eval version iso
$downloadUrl = "https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US"
$outputPath = "C:\Your\Desired\Folder\WindowsServer2022.iso"
Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath


# Install Hyper-V feature
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -restart