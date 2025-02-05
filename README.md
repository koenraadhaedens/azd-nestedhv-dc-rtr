# Installing the Infrastructure

## Prerequisites

Before proceeding on local pc, ensure you have one of the following environment set up:
- [Azure Developer CLI (AZD)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)

You can also use Azure Cloud Shell where AZD is preinstalled
- [Azure Cloud Shell](https://shell.azure.com)

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
   - Choose the Azure subscription.
   - Select the region.
   - Ensure the required VM SKU is available in the chosen region by running:
     ```sh
     az vm list-skus --query "[?name=='Standard_D8s_v3'].[name, locations]" --output table
     ```
   - Provide a password for the VM.

## VM Access Details

- **Username:** `vmadmin`
- **Password:** (Provided during provisioning)

## Post Installation

Once the setup is complete:
- Login to the VM.
- Choose a scenario or install VMs within the nested hypervisor as needed.

## Cleaning Up
   ```sh
   azd down
   ```


For any issues, refer to the Azure documentation or open an issue in the repository.