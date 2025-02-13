# Azure Nested Hypervisor Demos  

This repository showcases a collection of demos leveraging Azure's nested hypervisor capabilities, integrating powerful tools like Azure Arc, Defender for Identity, and more. These demos are designed to demonstrate hybrid cloud management, advanced security, and multi-cloud governance scenarios.  

## Demo List  

1. **Hybrid Infrastructure Management with Azure Arc**  
   Manage on-premises and multi-cloud servers seamlessly using Azure Arc's unified management platform.  

2. **Securing Identities with Defender for Identity**  
   Real-time threat detection and identity protection in hybrid Active Directory environments.  

3. **Multi-Tenant Kubernetes Management with Azure Arc**  
   Manage and secure Kubernetes clusters across diverse environments with Azure Arc-enabled Kubernetes.  

4. **Advanced Threat Hunting with Microsoft Sentinel**  
   Cross-cloud threat detection and investigation with Azure Sentinel integrated with Defender for Identity.  

5. **Nested Virtualization with Azure VMs**  
   Run Hyper-V inside an Azure VM for workload isolation and advanced testing scenarios.  

6. **Azure Arc-Enabled Data Services**  
   Deploy and manage SQL Managed Instances on-premises or other clouds using Azure Arc.  

7. **Hybrid Cloud Security with Microsoft Defender for Cloud**  
   Unified security management across Azure, on-premises, and multi-cloud environments.  

8. **Disaster Recovery with Azure Site Recovery in Nested Hypervisors**  
   Simulate on-premises VM failover and failback using Azure Site Recovery with nested virtualization.  

9. **Policy-Driven Governance using Azure Arc**  
   Enforce compliance and security policies across hybrid and multi-cloud resources.  

10. **Zero Trust Architecture with Defender for Identity and Conditional Access**  
   Implement and demonstrate Zero Trust security models in a hybrid identity environment.  

## Getting Started  

Each demo includes detailed setup instructions (under construction, all help is welcome), architecture diagrams, and step-by-step guides.  



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