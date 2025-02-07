# Demoguide: Creating a Site-to-Site VPN Tunnel

## Step-by-Step Instructions

### Introduction
This demoguide walks you through the process of creating a site-to-site (S2S) VPN tunnel using a nested hypervisor setup. The tutorial includes deploying the necessary virtual machines, configuring network gateways, and establishing the VPN tunnel for secure communication between your on-premises network and Azure.

### Step 1: Deploy "Hub Spoke with VPN Gateway and JumpVM"
Begin by deploying the "Hub Spoke with VPN Gateway and JumpVM" from the [Microsoft Trainer demo deploy] (https://microsoftlearning.github.io/trainer-demo-deploy/) website. This deployment will set up the foundational infrastructure required for the VPN tunnel.

### Step 2: Deploy ONPREM-RTR VM
Once the initial deployment is complete, you need to select option 1 in your scenario script to "deploy onprem-rtr vm". This virtual machine will act as your on-premises router.

### Step 3: Install a Local Network Gateway
Upon deploying the ONPREM-RTR VM, the next step is to install a "local network gateway" that points to the public IP address of the nested hypervisor. Use the following details:
- **Public IP Address:** [Public IP of the nested hypervisor]
- **Address Spaces:** 172.33.0.0/24

### Step 4: Create the S2S VPN Tunnel
With the local network gateway in place, you can now create the S2S VPN tunnel on the installed Virtual Network Gateway. Follow these steps:
1. Navigate to the Virtual Network Gateway.
2. Select the newly created local network gateway.
3. Assign a shared key for the VPN tunnel.

### Step 5: Configure the ONPREM-RTR VM
After creating the VPN tunnel, go to the ONPREM-RTR VM and follow these steps:
1. Open Server Manager.
2. Go to "Routing and Remote Access".
3. In the network interface, right-click the "AZUREVPN" network and choose "Properties".
4. In the "General" tab, change the IP address from 11.11.11.11 to the public IP address of the Virtual Network Gateway.
5. In the "Security" tab, change the shared key to the one you used previously.
6. Click "OK".
7. Right-click the "AZUREVPN" network interface and click "Connect".

### Conclusion
You've successfully established a site-to-site VPN tunnel using a nested hypervisor setup. This secure connection allows for seamless communication between your on-premises network and Azure, enabling you to leverage cloud resources while maintaining control over your local infrastructure.