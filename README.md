# OtterOps - Azure Shared Image Gallery Infrastructure

DevOps pipeline to build custom Windows images with Azure Shared Image Gallery infrastructure.

## Overview

This repository contains Infrastructure as Code (IaC) for provisioning an Azure Shared Image Gallery (Azure Compute Gallery) to store custom Windows images.

Azure Shared Image Gallery (now called Azure Compute Gallery) is a service that helps you build structure and organization around your custom VM images. It provides:

- **Global replication** of images across multiple regions
- **Versioning and grouping** of images for easier management
- **Zone-redundant storage** for high availability
- **Sharing** images across subscriptions and Azure AD tenants
- **Scaling** deployments using image replicas

## Architecture

This solution deploys:

1. **Azure Compute Gallery** - The main container for image definitions and versions
2. **Image Definitions** - Logical groupings for custom Windows images with metadata
3. **Soft Delete Policy** - Protection against accidental deletion with configurable retention

## Prerequisites

Before deploying this solution, ensure you have:

- Azure subscription with appropriate permissions
- One of the following tools installed:
  - [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) (recommended)
  - [Azure PowerShell](https://docs.microsoft.com/powershell/azure/install-az-ps)
- [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) (automatically installed with Azure CLI 2.20.0+)
- Appropriate Azure RBAC permissions:
  - `Contributor` role at the resource group level (minimum)
  - Or `Owner` role for full management capabilities

> For detailed repository structure information, see [STRUCTURE.md](STRUCTURE.md)

## File Structure

```
.
├── src/
│   ├── infrastructure/
│   │   ├── main.bicep                  # Main Bicep template
│   │   ├── main.bicepparam             # Default parameters (safe for git)
│   │   ├── main.bicepparam.example     # Example for local customization
│   │   └── deploy.ps1                  # PowerShell deployment script
│   └── cicd/
│       ├── azure-pipelines.yml         # Azure DevOps pipeline
│       └── packer/
│           ├── main.pkr.hcl            # Packer template
│           ├── variables.pkr.hcl       # Packer variables
│           ├── terraform.tfvars.example # Example variable values
│           ├── README.md               # Packer documentation
│           └── scripts/
│               └── install-notepadpp.ps1 # Notepad++ installation script
├── SECURITY.md                         # Security guidelines
├── CONTRIBUTING.md                     # Contribution guidelines
├── STRUCTURE.md                        # Repository structure guide
├── CHANGES.md                          # Change log
├── .gitignore                          # Git ignore patterns
└── README.md                           # This file
```

### Local Development

For production deployments, create a local parameters file:

```powershell
# Navigate to infrastructure directory
cd src/infrastructure

# Copy the example file
cp main.bicepparam.example main.bicepparam.local

# Edit main.bicepparam.local with your specific values
# This file is ignored by git to protect sensitive configuration

# Deploy using your local parameters
./deploy.ps1 -ResourceGroupName "your-rg" -ParametersFile "./main.bicepparam.local"
```

## Configuration

> **⚠️ Security Note:** Never commit Azure credentials, subscription IDs, or sensitive configuration to version control. Use Azure Key Vault or GitHub Secrets for sensitive values in CI/CD pipelines.

### Parameters

Edit `main.bicepparam` to customize your deployment:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `galleryName` | Name of the Azure Compute Gallery (alphanumeric, underscores, and periods only - no dashes) | `sig_customwindows_prod` |
| `location` | Azure region for deployment | `eastus` |
| `galleryDescription` | Description of the gallery | *See parameters file* |
| `windowsImages` | Array of Windows image definitions to create | *See parameters file* |
| `tags` | Resource tags for organization | *See parameters file* |
| `enableSoftDelete` | Enable soft delete protection | `true` |
| `softDeleteRetentionDays` | Retention period for deleted resources (7-90 days) | `30` |

### Windows Image Definitions

The template includes three pre-configured Windows image definitions:

1. **Windows Server 2022 Datacenter** - For server workloads
2. **Windows Server 2019 Datacenter** - For legacy server workloads
3. **Windows 11 Enterprise** - For desktop workloads

You can modify, add, or remove image definitions in the `windowsImages` parameter array.

## Deployment

### Option 1: Using the PowerShell Script (Recommended)

The provided PowerShell script automatically detects whether you have Azure CLI or Azure PowerShell installed and uses the appropriate tool.

```powershell
# Navigate to infrastructure directory
cd src/infrastructure

# Basic deployment
./deploy.ps1 -ResourceGroupName "rg-sharedimages-test"

# Deployment with custom location
./deploy.ps1 -ResourceGroupName "rg-sharedimages-prod" -Location "westus2"

# What-if deployment (preview changes without deploying)
./deploy.ps1 -ResourceGroupName "rg-sharedimages-prod" -WhatIf

# Deployment with custom parameters file
./deploy.ps1 -ResourceGroupName "rg-sharedimages-prod" -ParametersFile "./main.bicepparam.local"
```

### Option 2: Using Azure CLI

```bash
# Navigate to infrastructure directory
cd src/infrastructure

# Create resource group (if it doesn't exist)
az group create --name rg-sharedimages-prod --location eastus

# Deploy the template
az deployment group create \
  --name sig-deployment \
  --resource-group rg-sharedimages-prod \
  --template-file main.bicep \
  --parameters main.bicepparam

# What-if deployment
az deployment group what-if \
  --resource-group rg-sharedimages-prod \
  --template-file main.bicep \
  --parameters main.bicepparam
```

### Option 3: Using Azure PowerShell

```powershell
# Navigate to infrastructure directory
cd src/infrastructure

# Create resource group (if it doesn't exist)
New-AzResourceGroup -Name "rg-sharedimages-prod" -Location "eastus"

# Deploy the template
New-AzResourceGroupDeployment `
  -Name "sig-deployment" `
  -ResourceGroupName "rg-sharedimages-prod" `
  -TemplateFile "./main.bicep" `
  -TemplateParameterFile "./main.bicepparam"

# What-if deployment
New-AzResourceGroupDeployment `
  -Name "sig-deployment" `
  -ResourceGroupName "rg-sharedimages-prod" `
  -TemplateFile "./main.bicep" `
  -TemplateParameterFile "./main.bicepparam" `
  -WhatIf
```

## Post-Deployment Steps

After deploying the Shared Image Gallery, you can:

### 1. Create Image Versions

Create a VM image version from an existing VM, managed disk, or snapshot:

```bash
# From an existing VM
az sig image-version create \
  --resource-group rg-sharedimages-prod \
  --gallery-name sig_customwindows_prod \
  --gallery-image-definition windows-server-2022-datacenter \
  --gallery-image-version 1.0.0 \
  --managed-image /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/images/{image-name}

# From a snapshot
az sig image-version create \
  --resource-group rg-sharedimages-prod \
  --gallery-name sig_customwindows_prod \
  --gallery-image-definition windows-server-2022-datacenter \
  --gallery-image-version 1.0.0 \
  --os-snapshot /subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Compute/snapshots/{snapshot-name}
```

### 2. Deploy VMs from Image Versions

```bash
az vm create \
  --resource-group rg-vms-prod \
  --name vm-app-001 \
  --image "/subscriptions/{sub-id}/resourceGroups/rg-sharedimages-prod/providers/Microsoft.Compute/galleries/sig_customwindows_prod/images/windows-server-2022-datacenter/versions/1.0.0" \
  --admin-username azureuser \
  --generate-ssh-keys \
  --size Standard_D2s_v3

# For Windows VMs, use --admin-password with a secure password or Azure Key Vault reference
```

### 3. Enable Image Replication

Replicate your image versions to additional Azure regions for better availability and faster deployments:

```bash
az sig image-version update \
  --resource-group rg-sharedimages-prod \
  --gallery-name sig_customwindows_prod \
  --gallery-image-definition windows-server-2022-datacenter \
  --gallery-image-version 1.0.0 \
  --target-regions "eastus=1=standard" "westus2=1=standard" "centralus=1=standard"
```

## CI/CD Pipeline - Automated Image Building

This repository includes an Azure DevOps pipeline (`src/cicd/azure-pipelines.yml`) that automates the process of building custom Windows images using Packer.

### Pipeline Overview

The pipeline performs the following stages:

1. **Validate** - Validates Packer templates and Bicep infrastructure
2. **Build** - Builds Windows 11 Enterprise image with Notepad++ installed
3. **Verify** - Verifies image creation in Azure Compute Gallery
4. **Report** - Generates build summary and artifacts

### Pipeline Features

✅ **Automated Image Customization**
- Installs Notepad++ on Windows 11 Enterprise
- Fully extensible for additional software

✅ **Generalization & Capture**
- Automatically runs Windows Sysprep
- Captures image directly to Azure Compute Gallery
- Supports versioning and replication

✅ **Build Validation**
- Format checking for Packer templates
- Validation of infrastructure code
- Azure authentication verification

### Using the Pipeline

**Prerequisites:**
- Azure DevOps project with repository
- Azure service connection configured
- Service principal with gallery access

**Setup:**
1. See [src/cicd/README.md](src/cicd/README.md) for configuration
2. Add pipeline to Azure DevOps
3. Configure service connection and variables
4. Run pipeline manually or on code push

**Customization:**
- Edit `src/cicd/packer/scripts/install-notepadpp.ps1` to add software
- Modify `src/cicd/packer/main.pkr.hcl` for build configuration
- Update `azure-pipelines.yml` for different stages or triggers

### Image Build Process

```
Pipeline Trigger
    ↓
Validate Packer/Bicep Templates
    ↓
Create Temporary Resource Group & VM
    ↓
Run Provisioners (Install Software)
    ↓
Run Windows Sysprep (Generalize)
    ↓
Capture Image to Gallery
    ↓
Cleanup Temporary Resources
    ↓
Verify Image in Gallery
    ↓
Generate Report
```

For detailed instructions, see [src/cicd/README.md](src/cicd/README.md) and [src/cicd/packer/README.md](src/cicd/packer/README.md).

## Security Best Practices

This template follows Azure security best practices:

1. **Managed Identity** - Use managed identities instead of service principals when possible
2. **RBAC** - Apply least-privilege access using Azure RBAC
3. **Soft Delete** - Enabled by default to protect against accidental deletion
4. **Encryption** - All images are encrypted at rest using Azure Storage encryption
5. **Tags** - Resource tagging for governance and cost management
6. **No Hardcoded Secrets** - All sensitive values are parameterized

**Important:** See [SECURITY.md](SECURITY.md) for comprehensive security guidelines including:
- How to properly generalize VMs before creating images
- Protecting credentials and sensitive data
- Secure CI/CD pipeline configuration
- Compliance and governance recommendations

## Cost Optimization

- **Storage costs**: You pay for the storage of image versions based on the size and number of replicas
- **Replica management**: Only replicate to regions where you need to deploy VMs
- **Soft delete**: Consider the retention period for soft-deleted resources
- **Image versions**: Clean up old image versions that are no longer needed

## Troubleshooting

### Common Issues

1. **Deployment fails with "Gallery name already exists"**
   - Change the `galleryName` parameter to a unique value
   - Gallery names must be unique within a resource group

2. **Cannot create image version**
   - Ensure the source VM is generalized using sysprep (Windows)
   - Verify you have the correct permissions on the source image/VM

3. **Soft delete is enabled but resources are immediately deleted**
   - Check if soft delete is properly configured in the deployment
   - Verify the `enableSoftDelete` parameter is set to `true`

## Additional Resources

- [Azure Compute Gallery documentation](https://learn.microsoft.com/azure/virtual-machines/shared-image-galleries)
- [Azure Verified Modules for Compute Gallery](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/compute/gallery)
- [Best practices for VM images](https://learn.microsoft.com/azure/virtual-machines/windows/imaging)
- [Bicep documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)

## Support

For issues or questions:
- Create an issue in this repository
- Consult [Azure documentation](https://docs.microsoft.com/azure/)
- Contact your Azure support team

## License

This template is provided as-is under the MIT License.
