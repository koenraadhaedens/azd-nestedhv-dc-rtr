# Installing the Infrastructure

## Prerequisites

Before proceeding on local pc, ensure you have one of the following environment set up:
- [Azure Developer CLI (AZD)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)

You can also use Azure Cloud Shell where AZD is preinstalled
- [Azure Cloud Shell](https://shell.azure.com)
  
- Ensure the required VM SKU is available in the chosen region by running:
 ```sh
 az vm list-skus --query "[?name=='Standard_D8s_v3'].[name, locations]" --output table
 ```

 **TIP:** All downloadable files are located in **North Europe**, so deploying additional resources in the nested VM within this region may improve performance.


## Installation Steps

1. **Clone the Repository**
   ```sh
   git clone https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr.git
   ```
2. **Navigate to the Project Directory**
   ```sh
   cd azd-nestedhv-dc-rtr
   ```
3. **Provision the Infrastructure**
   ```sh
   azd provision
   ```
4. **Select the Required Options**
   - Enter a new environment name (Will be the name of the Resource Group to rg-xxxxxxx where xxxxxxx is your new environment name)
   - Choose the Azure subscription.
   - Select the region.
   - Provide a password for the VM.

## VM Access Details

- **Username:** `vmadmin`
- **Password:** (Provided during provisioning)

## Post Installation

Once the setup is complete:
- Create NSG rue to allow only your client ip or use Just-in-time policy
- Login to the VM.


## Choose a scenario or install VMs within the nested hypervisor as needed.

[Creating a Site-to-Site VPN Tunnel demo](https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr/blob/main/demoguide-s2svpn/README.md)



## Cleaning Up
   ```sh
   azd down
   ```



For any issues, refer to the Azure documentation or open an issue in the repository.