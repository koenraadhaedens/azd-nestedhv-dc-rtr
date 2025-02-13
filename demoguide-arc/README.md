

## Prerequisites  
- Azure Subscription with permissions to onboard Azure Arc  
- Azure CLI installed on the management machine  
- VPN connection established between on-premises and Azure (using onprem-rtr)  
- Internet access for the on-premises VMs  

---

# Hybrid Infrastructure Management with Azure Arc  

Manage on-premises and multi-cloud servers seamlessly using Azure Arc's unified management platform. This guide assumes you have the following environment:  
- A nested hypervisor setup with the following VMs:  
  - **onprem-rtr**: Router VM with S2S VPN tunnel [Guide to install RTR + 2s2 vpn tunnel](https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr/tree/main/demoguide-s2svpn)
  - **onprem-dc1**: Domain Controller VM  [Guide to install Domain Controller](https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr/tree/main/demoguide-dc1)
  - **onprem-sql1**: SQL Server VM   [Guide to install SQL Server](https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr/tree/main/demoquide-sql)

---

## Step 1: Register Azure Arc Resource Provider  
Open Azure Cloud Shell or use the Azure CLI locally:  
```sh
az login
az account set --subscription <your-subscription-id>
az provider register --namespace Microsoft.HybridCompute
az provider register --namespace Microsoft.GuestConfiguration
```

---

## Step 2: Create Azure Service Principal  
This service principal will authenticate the on-premises VMs to Azure Arc.  
```sh
az ad sp create-for-rbac --name "ArcSP" --role "Contributor" --scopes /subscriptions/<your-subscription-id> --query "{clientId:appId,clientSecret:password,tenantId:tenant}" --output table
```
Note down the output values:  
- **clientId**  
- **clientSecret**  
- **tenantId**  

---

## Step 3: Install Azure Arc Agent on VMs  
On each on-premises VM (onprem-dc1 and onprem-sql1), run the following:  

1. Download and install the Azure Arc agent:  
```powershell
$agentUrl = "https://aka.ms/AzureConnectedMachineAgent"
Invoke-WebRequest -Uri $agentUrl -OutFile AzureConnectedMachineAgent.msi
Start-Process msiexec.exe -ArgumentList "/i AzureConnectedMachineAgent.msi /quiet" -Wait
```

2. Connect the VM to Azure Arc:  
```powershell
$tenantId = "<tenantId>"
$clientId = "<clientId>"
$clientSecret = "<clientSecret>"
$resourceGroup = "<resource-group>"
$region = "<azure-region>"

$connectScript = "https://aka.ms/AzureArcVMOnboardingScript"
Invoke-WebRequest -Uri $connectScript -OutFile ConnectArc.ps1
PowerShell.exe -ExecutionPolicy Unrestricted -File .\ConnectArc.ps1 -tenantId $tenantId -appId $clientId -appSecret $clientSecret -resourceGroup $resourceGroup -region $region
```

---

## Step 4: Verify Azure Arc Integration  
1. Go to the Azure Portal: https://portal.azure.com  
2. Navigate to **Azure Arc** > **Servers**  
3. Confirm that **onprem-dc1** and **onprem-sql1** appear as connected machines.  

---

## Step 5: Manage and Monitor VMs  
1. From the Azure Portal, click on the onboarded VMs under Azure Arc.  
2. Use Azure Monitor, Security Center, and Update Management for:  
   - Monitoring performance and health  
   - Managing updates and security baselines  
   - Implementing policies and compliance standards  

---

## Step 6: Enable Azure Security and Governance  
1. Navigate to **Azure Security Center**.  
2. Enable Security Center recommendations for Arc-enabled servers.  
3. Apply Azure Policies for governance and compliance.  

---

## Step 7: Test and Validate  
- Test connectivity between **onprem-rtr** and Azure resources.  
- Verify domain integration with **onprem-dc1**.  
- Check SQL connectivity and performance for **onprem-sql1** using Azure Monitor.

---

## Step 8: Cleanup (Optional)  
To remove Azure Arc integration from a VM:  
```powershell
$uninstallPath = "C:\Program Files\AzureConnectedMachineAgent\azcmagent.exe"
& $uninstallPath disconnect
```

---

## Conclusion  
You have successfully integrated on-premises VMs into Azure Arc, enabling centralized management and governance. Continue exploring Azure Arc's capabilities for hybrid cloud management.

---