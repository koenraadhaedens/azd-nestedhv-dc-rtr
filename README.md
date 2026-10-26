# Azure Nested Hypervisor Demos  

This repository showcases a collection of demos leveraging Azure's nested hypervisor capabilities, integrating powerful tools like Azure Arc, Defender for Identity, and more. These demos are designed to demonstrate hybrid cloud management, advanced security, and multi-cloud governance scenarios.  

## Demo List  

1. [**Hybrid Infrastructure Management with Azure Arc**](https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr/tree/main/demoguide-arc)
   Manage on-premises and multi-cloud servers seamlessly using Azure Arc's unified management platform.  

2. [**Securing Identities with Defender for Identity**](https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr/tree/main/demoguide-dc1)  
   Real-time threat detection and identity protection in hybrid Active Directory environments.  

3. **Multi-Tenant Kubernetes Management with Azure Arc**  
   Manage and secure Kubernetes clusters across diverse environments with Azure Arc-enabled Kubernetes.  

4. **Advanced Threat Hunting with Microsoft Sentinel**  
   Cross-cloud threat detection and investigation with Azure Sentinel integrated with Defender for Identity.  

5. **Nested Virtualization with Azure VMs**  
   Run Hyper-V inside an Azure VM for workload isolation and advanced testing scenarios.  

6. [**Azure Arc-Enabled Data Services**](https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr/tree/main/demoguide-arc)  
   Deploy and manage SQL Managed Instances on-premises or other clouds using Azure Arc.  

7. **Hybrid Cloud Security with Microsoft Defender for Cloud**  
   Unified security management across Azure, on-premises, and multi-cloud environments.  

8. **Disaster Recovery with Azure Site Recovery in Nested Hypervisors**  
   Simulate on-premises VM failover and failback using Azure Site Recovery with nested virtualization.  

   [**Policy-Driven Governance using Azure Arc**](https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr/tree/main/demoguide-arc)
   Enforce compliance and security policies across hybrid and multi-cloud resources.  

10. **Zero Trust Architecture with Defender for Identity and Conditional Access**  
   Implement and demonstrate Zero Trust security models in a hybrid identity environment.  

## Getting Started  

Each demo includes detailed setup instructions (under construction, all help is welcome), architecture diagrams, and step-by-step guides.  



# Installing the Infrastructure

## Prerequisites

Before proceeding on local pc, ensure you have one of the following environment set up:
- [Azure Developer CLI (AZD)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) for the prerequisite checks and troubleshooting commands below.

You can also use Azure Cloud Shell where AZD is preinstalled
- [Azure Cloud Shell](https://shell.azure.com)
  
- Ensure the required VM SKU is available in the chosen region by running:
 ```sh
 az vm list-skus --resource-type virtualMachines --all --query "[?name=='Standard_D8s_v7'].{Name:name, Locations:locations, Restrictions:restrictions}" --output json
 ```

The template defaults to Windows Server 2025 Datacenter and `Standard_D8s_v7`.
Check regional availability, subscription restrictions, vCPU quota, and nested
virtualization support before deployment. The VM explicitly uses `Standard`
security rather than relying on the API's default security type.

## Storage and restricted environments

**No customer-managed storage account is required or deployed.** The host OS and
256-GiB data disk use Azure managed disks. Boot diagnostics uses
[Azure-managed storage](https://learn.microsoft.com/en-us/azure/virtual-machines/boot-diagnostics)
by enabling diagnostics without a `storageUri`. This avoids deploying a storage
account with a public endpoint, shared keys, or a legacy account kind. The
Azure-managed diagnostics account is not a storage-account resource in your
subscription.

This addresses policies that prohibit public network access on storage accounts
deployed in your subscription. It is **not a claim of full SFI compliance**:

- The host NIC has no public IP. A Standard NAT Gateway on `hvhostSubnet`
  provides outbound connectivity using its own Azure-allocated Standard static
  public IP. Default outbound access is explicitly disabled on the subnet.
  No bring-your-own IP address, custom IP prefix, or preview feature is requested.
- RDP is denied by default. Use your organization's approved access method; do
  not add a broad Internet allow rule.
- Bootstrap still downloads scripts from `raw.githubusercontent.com`, tools and
  demo VM archives from the separately hosted
  `sagithubdemokhd.blob.core.windows.net` public container, and software from
  Microsoft download endpoints and package sources. Removing the diagnostics
  account does not remove these public download dependencies.
- NAT Gateway still requires a public IP resource. If your environment prohibits
  all public IP resources, including NAT Gateway IPs, this configuration will
  still be blocked. It is not a workaround for tenant restrictions. If public
  blob endpoints are blocked, private artifact hosting with authentication and
  DNS is also required.
- The template no longer applies `SecurityControl: Ignore` / `CostControl: Ignore`
  tags.
- The postprovision hooks send deployment statistics to the existing Azure
  Automation webhook. The machine running `azd provision` needs outbound HTTPS
  access to that endpoint; this does not require a storage account in the lab.

## Private host access and NAT Gateway

The NAT Gateway is outbound-only: its public IP does not accept unsolicited
inbound traffic and cannot be used for RDP or as a site-to-site VPN endpoint.
Access to the VM requires an approved private path into `hostvnet`, such as an
existing connected network or an independently provisioned Bastion deployment.
This template does not provision that access path.

Deployment outputs are `Jumphost_VM_private_IP_address` (the host's private IP)
and `natGatewayPublicIpAddress` (outbound traffic only). These replace the former
`Jumphost_VM_IP_address` public-IP output; update any external consumers.

NAT Gateway incurs additional hourly and data-processing charges. The existing
[site-to-site VPN demo](./demoguide-s2svpn/README.md) assumes an inbound-capable
public endpoint and is not supported by this private-host configuration.

When updating an existing host with a NIC public IP, deployment removes that
NIC association and any active public-IP RDP session will disconnect. Arrange
private access first. Incremental deployment leaves the old
`winhvhostnamePublicIp` resource in place; inspect its dependencies before
removing it manually. Existing VMs may need to be stopped/deallocated and
started again for the subnet's default-outbound-access change to take effect.

## Retrying an older failed deployment

The old `kind: Storage` account was only for boot diagnostics. The updated
template removes it instead of changing it to another account kind. Run
`azd provision` again with the existing environment after updating this checkout.
An incremental deployment does **not** delete an old storage account that was
already created; inspect it for data and dependencies before deleting it manually.

The old template also used a 2019 public-IP API. The updated template uses a
stable newer Network API and requests an ordinary Azure-allocated public IP
for the NAT Gateway, not the VM.
The template does not request BYOIP, but updating the API alone may not resolve
`SubscriptionNotRegisteredForFeature` for `AllowBringYourOwnPublicIpAddress`.
Inspect the failed operation in the target subscription for the exact resource
and service error:

```sh
az deployment operation group list --subscription <subscription-id> --resource-group rg-<environment-name> --name hvhost --query "[?properties.provisioningState=='Failed'].properties.{Target:targetResource, Error:statusMessage}" --output json
```

Resource-group operations show failures inside the nested `hvhost` deployment.
If it never started, inspect the subscription deployment using the name from the
error's Azure Portal link:

```sh
az deployment operation sub list --subscription <subscription-id> --name <deployment-name> --query "[?properties.provisioningState=='Failed'].properties.{Target:targetResource, Error:statusMessage}" --output json
```

If Azure continues to require that feature, ask your subscription administrator
to approve and perform the registration. This changes subscription configuration;
it is not performed automatically by this template:

```sh
az feature register --subscription <subscription-id> --namespace Microsoft.Network --name AllowBringYourOwnPublicIpAddress
az feature show --subscription <subscription-id> --namespace Microsoft.Network --name AllowBringYourOwnPublicIpAddress --query properties.state --output tsv
```

Wait until the feature state is `Registered`, then refresh the provider:

```sh
az provider register --subscription <subscription-id> --namespace Microsoft.Network
az provider show --subscription <subscription-id> --namespace Microsoft.Network --query registrationState --output tsv
```

Once the provider is `Registered`, retry `azd provision`. If registration is
unavailable, remains pending, or does not resolve the error, open an Azure Support
request with the failed operation and correlation ID. Do not bypass organizational
restrictions on feature registration or public IPs.

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
 
   If you are not using Azure Cloud Shell, log in to Azure with the following command:
   ```sh
   azd auth login
   ```
   If you are working inside a development container and prefer to use a device code for authentication, run:
   ```sh
   azd auth login --use-device-code
   ```   
4. **Provision the Infrastructure**
   ```sh
   azd provision
   ```
5. **Select the Required Options**
   - Enter a new environment name (Will be the name of the Resource Group to rg-xxxxxxx where xxxxxxx is your new environment name)
   - Choose the Azure subscription.
   - Select the region.
   - Provide a password for the VM.

## VM Access Details

- **Username:** `adminuser`
- **Password:** (Provided during provisioning)
- **Address:** `Jumphost_VM_private_IP_address` from the deployment outputs.
  Connect through your approved private access path, not the NAT public IP.

## Post Installation

Once the setup is complete:
- If approved by your organization, add an NSG rule allowing only your private
  management source IP or CIDR
  at a priority above the default RDP deny rule (a number below 1000), or use
  Just-in-time access where supported. An NSG rule does not create private
  connectivity.
- Login to the VM.


## Choose a scenario or install VMs within the nested hypervisor as needed.

[Creating a Site-to-Site VPN Tunnel demo](https://github.com/koenraadhaedens/azd-nestedhv-dc-rtr/blob/main/demoguide-s2svpn/README.md)



## Cleaning Up
   ```sh
   azd down
   ```



For any issues, refer to the Azure documentation or open an issue in the repository.
