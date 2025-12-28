# Basick8s - Azure Infrastructure with Terraform

This Terraform configuration sets up a basic Azure infrastructure with:
- **Azure Kubernetes Service (AKS)** - Container orchestration platform
- **Azure Front Door (v2)** - Global load balancer and CDN
- **Networking** - Virtual network with proper subnet configuration

## Architecture

```
Internet → Azure Front Door (v2) → AKS Public Service → Internal Services
```

- **Front Door**: Provides global load balancing and acts as the public entry point
- **Public-facing container**: Exposed through AKS LoadBalancer/Ingress, connected to Front Door
- **Internal container**: Only accessible from within the AKS cluster network

## Prerequisites

1. **Azure CLI**: Install from [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform**: Install from [here](https://www.terraform.io/downloads)
3. **kubectl**: Install from [here](https://kubernetes.io/docs/tasks/tools/)
4. **Azure Subscription**: You need an active Azure subscription

## Setup Instructions

### 1. Login to Azure

```powershell
az login
az account set --subscription "<your-subscription-id>"
```

### 2. Initialize Terraform

```powershell
cd terraform
terraform init
```

### 3. Review and Customize Variables

Edit `variables.tf` or create a `terraform.tfvars` file:

```hcl
resource_group_name = "rg-basick8s"
location           = "westeurope"
aks_cluster_name   = "aks-basick8s"
aks_node_count     = 2
```

### 4. Plan and Apply

```powershell
# Review what will be created
terraform plan

# Apply the configuration
terraform apply
```

This will create:
- Resource Group
- Virtual Network with AKS subnet
- AKS cluster with 2 nodes
- Public IP for ingress
- Azure Front Door profile and endpoint
- Routing configuration

### 5. Get AKS Credentials

After deployment completes:

```powershell
az aks get-credentials --resource-group rg-basick8s --name aks-basick8s
```

Or use the output command:
```powershell
terraform output -raw get_aks_credentials_command
```

## Deploying Applications

### Public-Facing Container (Connected to Front Door)

Create a deployment and LoadBalancer service:

```yaml
# public-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: public-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: public-app
  template:
    metadata:
      labels:
        app: public-app
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: public-app-service
spec:
  type: LoadBalancer
  loadBalancerIP: <use-aks_public_ip-from-terraform-output>
  selector:
    app: public-app
  ports:
  - port: 80
    targetPort: 80
```

Deploy:
```powershell
kubectl apply -f public-app.yaml
```

### Internal Container (Only Accessible from Public Container)

```yaml
# internal-app.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: internal-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: internal-app
  template:
    metadata:
      labels:
        app: internal-app
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: internal-app-service
spec:
  type: ClusterIP  # Only accessible within the cluster
  selector:
    app: internal-app
  ports:
  - port: 80
    targetPort: 80
```

Deploy:
```powershell
kubectl apply -f internal-app.yaml
```

The public container can reach the internal service at: `http://internal-app-service`

## Accessing Your Application

1. **Via Front Door**: Use the Front Door endpoint hostname
   ```powershell
   terraform output frontdoor_endpoint_hostname
   ```
   Access at: `http://<endpoint-hostname>`

2. **Directly via AKS Public IP**:
   ```powershell
   terraform output aks_public_ip
   ```

## Network Communication

- **Public → Internal**: The public-facing pods can communicate with internal services using the service name:
  ```bash
  curl http://internal-app-service
  ```

- **External → Public**: Traffic flows through Front Door → AKS LoadBalancer → Public Pods

- **External → Internal**: Not possible - internal services are ClusterIP only

## Useful Commands

```powershell
# Get cluster info
kubectl cluster-info

# List all services
kubectl get services

# List all pods
kubectl get pods

# Test internal connectivity from public pod
kubectl exec -it <public-pod-name> -- curl http://internal-app-service

# View Front Door status
az afd profile show --resource-group rg-basick8s --profile-name afd-basick8s

# View AKS nodes
kubectl get nodes
```

## Outputs

After deployment, get important values:

```powershell
# Front Door endpoint
terraform output frontdoor_endpoint_hostname

# AKS Public IP
terraform output aks_public_ip

# Command to get kubeconfig
terraform output get_aks_credentials_command
```

## Cleanup

To destroy all resources:

```powershell
terraform destroy
```

## Cost Considerations

This setup includes:
- AKS cluster (2 nodes × Standard_D2s_v3)
- Azure Front Door Standard tier
- Public IP address
- Virtual Network (free)

Approximate cost: ~$200-300/month depending on region and usage.

## Next Steps

1. Configure Ingress Controller (e.g., NGINX Ingress)
2. Set up SSL/TLS certificates
3. Configure Front Door WAF policies
4. Implement monitoring with Azure Monitor
5. Set up CI/CD pipeline for deployments
6. Configure network policies for enhanced security

## Troubleshooting

### Front Door not routing to AKS
- Ensure the LoadBalancer service is using the correct Public IP
- Check health probe status in Front Door
- Verify security group rules allow traffic

### Cannot access internal service
- Verify the service type is ClusterIP
- Check that pods are running: `kubectl get pods`
- Test DNS resolution: `kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup internal-app-service`

### AKS authentication issues
- Re-run: `az aks get-credentials --resource-group rg-basick8s --name aks-basick8s --overwrite-existing`
- Verify Azure CLI is logged in: `az account show`
