# Packer Configuration - Local Development

This directory contains the Packer configuration for building custom Windows 11 Enterprise images.

## Directory Structure

```
packer/
├── main.pkr.hcl              # Main Packer template
├── variables.pkr.hcl         # Variable definitions
├── terraform.tfvars.example   # Example variable values
└── scripts/
    └── install-notepadpp.ps1  # Notepad++ installation script
```

## Prerequisites

- [Packer](https://www.packer.io/downloads) >= 1.8.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- Azure subscription with appropriate permissions
- Service Principal with permissions to:
  - Create and manage VMs
  - Access Azure Compute Gallery
  - Create temporary resource groups

## Setup

### 1. Install Packer

```powershell
# Using Chocolatey
choco install packer

# Or download from: https://www.packer.io/downloads
```

### 2. Create terraform.tfvars

```powershell
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
notepad terraform.tfvars
```

### 3. Set Azure Service Principal Variables

```powershell
# Option 1: Set environment variables
$env:AZURE_SUBSCRIPTION_ID = "your-subscription-id"
$env:AZURE_CLIENT_ID = "your-client-id"
$env:AZURE_CLIENT_SECRET = "your-client-secret"
$env:AZURE_TENANT_ID = "your-tenant-id"

# Option 2: Use terraform.tfvars file
# See terraform.tfvars.example for format
```

### 4. Initialize Packer

```powershell
packer init .
```

## Building Locally

### Format Check

```powershell
packer fmt -recursive .
```

### Validate Template

```powershell
packer validate `
  -var-file="terraform.tfvars" `
  .
```

### Build Image

```powershell
packer build `
  -var-file="terraform.tfvars" `
  -on-error=ask `
  .
```

### Build with Debug Output

```powershell
# Enable debug logging
$env:PACKER_LOG = "DEBUG"

packer build `
  -var-file="terraform.tfvars" `
  -debug `
  .

# To continue after breakpoint, press 'c'
```

## Image Customization

### Adding Software

Edit `scripts/install-notepadpp.ps1` to add additional software:

```powershell
# Example: Install another application
$additionalInstallerUrl = "https://example.com/installer.exe"
Invoke-WebRequest -Uri $additionalInstallerUrl -OutFile $tempDir\installer.exe
Start-Process -FilePath $tempDir\installer.exe -ArgumentList "/S" -Wait -NoNewWindow
```

### Modifying Build Configuration

Edit `main.pkr.hcl` to:
- Change base image (variables: `image_publisher`, `image_offer`, `image_sku`)
- Adjust VM size (`vm_size`)
- Add new provisioners or scripts
- Modify Windows configuration

## Understanding the Build Process

1. **Initialization**: Packer validates configuration and required plugins
2. **Authentication**: Connects to Azure using service principal
3. **Resource Creation**: Creates temporary resource group and VM
4. **Provisioning**:
   - Updates Windows components
   - Installs Notepad++
   - Cleans up temporary files
5. **Generalization**: Runs Windows Sysprep to prepare for imaging
6. **Capture**: Captures image to Azure Compute Gallery
7. **Cleanup**: Removes temporary resources

## Troubleshooting

### Build Fails During Provisioning

```powershell
# Check WinRM connectivity
Test-NetConnection -ComputerName <vm-public-ip> -Port 5985

# Increase timeout in main.pkr.hcl
winrm_timeout = "20m"
```

### Sysprep Fails

- Ensure all applications are properly installed
- Check for running processes that lock system files
- Review Windows Event Viewer for errors

### Gallery Upload Fails

- Verify gallery exists: `az sig list`
- Check image definition: `az sig image-definition list`
- Verify resource group permissions

## Security Best Practices

1. **Store Credentials Securely**
   - Never commit terraform.tfvars with real credentials
   - Use Azure Key Vault for CI/CD
   - Use Service Principal with minimal required permissions

2. **Image Content**
   - Remove sensitive data before generalization
   - Disable unnecessary services
   - Apply Windows security updates

3. **Network Security**
   - Consider using Azure Private Link for gallery access
   - Restrict VMs to private networks during build
   - Use NSGs to limit access

## Useful Commands

```powershell
# List images in gallery
az sig image-definition list --resource-group rg-sharedimages-prod --gallery-name sig_customwindows_prod

# List image versions
az sig image-version list `
  --resource-group rg-sharedimages-prod `
  --gallery-name sig_customwindows_prod `
  --gallery-image-definition windows-11-enterprise

# Get image details
az sig image-version show `
  --resource-group rg-sharedimages-prod `
  --gallery-name sig_customwindows_prod `
  --gallery-image-definition windows-11-enterprise `
  --gallery-image-version 1.0.0

# Delete image version
az sig image-version delete `
  --resource-group rg-sharedimages-prod `
  --gallery-name sig_customwindows_prod `
  --gallery-image-definition windows-11-enterprise `
  --gallery-image-version 1.0.0
```

## Documentation

- [Packer Azure Plugin](https://www.packer.io/plugins/builders/azure)
- [Packer Documentation](https://www.packer.io/docs)
- [Azure Compute Gallery](https://docs.microsoft.com/en-us/azure/virtual-machines/shared-image-galleries)
- [Windows Sysprep](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep-overview)

---

**Last Updated**: January 2026
