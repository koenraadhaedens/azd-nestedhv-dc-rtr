Start-Sleep -Seconds 60

Start-Transcript -Path "C:\PostRebootConfigure_log.txt"
$cmdLogPath = "C:\PostRebootConfigure_log_cmd.txt"

# Create the NAT network
Write-Output "Create internal NAT"
$natName = "InternalNat"
New-NetNat -Name $natName -InternalIPInterfaceAddressPrefix 172.33.0.0/24

# Create an internal switch with NAT
Write-Output "Create internal switch"
$switchName = 'InternalNATSwitch'
New-VMSwitch -Name $switchName -SwitchType Internal
$adapter = Get-NetAdapter | Where-Object { $_.Name -like "*"+$switchName+"*" }

# Create an internal network (gateway first)
Write-Output "Create gateway"
New-NetIPAddress -IPAddress 172.33.0.1 -PrefixLength 24 -InterfaceIndex $adapter.ifIndex

# Enable Enhanced Session Mode on Host
Write-Output "Enable Enhanced Session Mode"
Set-VMHost -EnableEnhancedSessionMode $true

# create scenario script 

@'
# Define functions for each scenario
function Download-Server2022EvalISO {
    Write-Output "Downloading Windows Server 2022 Evaluation ISO..."
    # Add your script logic here
    $webClient = New-Object System.Net.WebClient
    $url = "https://go.microsoft.com/fwlink/p/?LinkID=2195280&clcid=0x409&culture=en-us&country=US"
    $output = "C:\iso\winserver2022eval.iso"
    $webClient.DownloadFile($url, $output)
}

function Deploy-RouterVM {
    Write-Output "Downloading and deploying Router VM..."
    # Add your script logic here
    Write-Output "under construction"
       Write-Output "Downloading and deploying Router VM..."
    # Add your script logic here
    Write-Output "dowloading vm to c:\import folder. Please wait until the prompt returns"
  
    $webClient = New-Object System.Net.WebClient
    $url = "https://sagithubdemokhd.blob.core.windows.net/public/ONPREM-RTR.zip"
    $output = "C:\import\onpremrtrvm.zip"
    $webClient.DownloadFile($url, $output)

    Write-Output "Unzip the folder to c:\virtual machines and import as new vm in hyper-v"
}

function Deploy-DomainControllerVM {
    Write-Output "Downloading and deploying Domain Controller VM..."
    # Add your script logic here
    Write-Output "under construction"
}

function Deploy-SQLServerVM {
    Write-Output "Downloading and deploying SQL Server VM..."
    # Add your script logic here
    Write-Output "under construction"
}

# Display menu
Write-Output "Please choose a scenario:"
Write-Output "1) Download Windows Server 2022 Evaluation ISO"
Write-Output "2) Download and Deploy Router VM"
Write-Output "3) Download and Deploy Domain Controller VM"
Write-Output "4) Download and Deploy SQL Server VM"

# Get user input
$choice = Read-Host "Enter the number of your choice"

# Execute the corresponding function based on the user's choice
switch ($choice) {
    1 { Download-Server2022EvalISO }
    2 { Deploy-RouterVM }
    3 { Deploy-DomainControllerVM }
    4 { Deploy-SQLServerVM }
    default { Write-Output "Invalid choice. Please run the script again and choose a valid option." }
}
'@ | Out-File -FilePath "C:\OpsDir\scenarioscript.ps1"

# Create shortcut on desktop for scenario choice
# Parameters
$scriptPath = "C:\OpsDir\scenarioscript.ps1"
$publicDesktopPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("CommonDesktopDirectory"), "choose_scenario.lnk")

# Create WScript.Shell COM Object
$wshShell = New-Object -ComObject WScript.Shell

# Create Shortcut
$shortcut = $wshShell.CreateShortcut($publicDesktopPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-File `"$scriptPath`"" 
$shortcut.WorkingDirectory = "C:\OpsDir"
$shortcut.Save()

Write-Output "Shortcut created at: $publicDesktopPath"





Stop-Transcript