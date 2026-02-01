# Azure DevOps Pipeline Configuration

This directory contains Azure DevOps pipeline configurations for automated image building.

## Files

### `azure-pipelines.yml`

Main Azure DevOps pipeline that orchestrates the image build process using Packer.

**Pipeline Stages:**

1. **Validate** - Validates Packer templates and Bicep infrastructure
2. **Build** - Builds the Windows image with Packer
3. **Verify** - Verifies the image was created in the gallery
4. **Report** - Generates build summary and artifacts

## Setup in Azure DevOps

### Prerequisites

- Azure DevOps project with repository
- Azure Pipelines enabled
- Service connection to Azure subscription

### 1. Configure Service Connection

```bash
# In Azure DevOps Project Settings:
# 1. Go to Project Settings > Service Connections
# 2. Create new "Azure Resource Manager" connection
# 3. Select "Service principal (automatic)"
# 4. Name it: "Azure-ServiceConnection"
# 5. Grant admin access
```

### 2. Create Variable Group (Optional but Recommended)

```bash
# In Azure DevOps Pipelines:
# 1. Go to Pipelines > Library
# 2. Create new Variable Group named "Packer-Build-Variables"
# 3. Add secret variables:
#    - AZURE_SUBSCRIPTION_ID
#    - AZURE_CLIENT_ID
#    - AZURE_CLIENT_SECRET
#    - AZURE_TENANT_ID
# 4. Link to pipeline
```

### 3. Create Pipeline

```bash
# In Azure DevOps:
# 1. Go to Pipelines > Create Pipeline
# 2. Select repository and branch
# 3. Select "Existing Azure Pipelines YAML file"
# 4. Select: src/cicd/azure-pipelines.yml
# 5. Review and Run
```

### 4. Configure Variables

Update the pipeline variables in `azure-pipelines.yml`:

```yaml
variables:
  PACKER_VERSION: '1.9.4'      # Packer version to use
  AZURE_LOCATION: 'eastus'     # Azure region
  IMAGE_VERSION: '1.0.0'       # Image version (semantic versioning)
  GALLERY_NAME: 'sig_customwindows_prod'  # Gallery name
  GALLERY_IMAGE_NAME: 'windows-11-enterprise'  # Image definition
```

## Running the Pipeline

### Manual Trigger

```bash
# In Azure DevOps:
# 1. Go to Pipelines
# 2. Select the pipeline
# 3. Click "Run pipeline"
# 4. Select branch (main)
# 5. Click "Run"
```

### Automatic Trigger

The pipeline automatically runs when:
- Changes are pushed to `src/cicd/packer/` on main branch
- Changes are pushed to `src/infrastructure/` on main branch

### Pull Request Validation

Pipeline validates (doesn't build) when:
- Pull request is created with changes to `src/cicd/packer/`

## Pipeline Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| AZURE_SUBSCRIPTION_ID | Azure subscription ID | `00000000-0000-0000-0000-000000000000` |
| AZURE_CLIENT_ID | Service principal client ID | `00000000-0000-0000-0000-000000000000` |
| AZURE_CLIENT_SECRET | Service principal secret | Secret value |
| AZURE_TENANT_ID | Azure tenant ID | `00000000-0000-0000-0000-000000000000` |
| PACKER_VERSION | Packer version | `1.9.4` |
| AZURE_LOCATION | Azure region | `eastus` |
| IMAGE_VERSION | Image version (semantic) | `1.0.0` |
| GALLERY_NAME | Compute gallery name | `sig_customwindows_prod` |
| GALLERY_IMAGE_NAME | Image definition name | `windows-11-enterprise` |

## Monitoring Builds

### View Pipeline Runs

```bash
# In Azure DevOps:
# 1. Go to Pipelines > All
# 2. Select pipeline
# 3. View run history
# 4. Click run to see detailed logs
```

### Common Issues

**Validation fails:**
- Check Packer syntax: `packer fmt -check .`
- Verify variables are set correctly
- Review pipeline logs for details

**Build timeout:**
- Image build can take 30-60 minutes
- Check VM size (larger = faster)
- Check internet connectivity for downloads
- Review Packer logs in pipeline output

**Image not found in gallery:**
- Verify gallery exists in target resource group
- Check image definition is created first via Bicep
- Verify service principal permissions

## Customizing the Pipeline

### Add New Provisioning Steps

Edit `src/cicd/packer/main.pkr.hcl`:

```hcl
provisioner "powershell" {
    inline = [
        "Write-Output 'Installing custom software...'",
        "# Your installation commands"
    ]
    timeout = "15m"
}
```

### Change Build Conditions

Modify trigger in `azure-pipelines.yml`:

```yaml
trigger:
  branches:
    include:
      - main
      - develop  # Add branch
  paths:
    include:
      - src/cicd/packer/**
      - src/infrastructure/**
```

### Add New Build Stage

Add to `azure-pipelines.yml`:

```yaml
- stage: CustomStage
  displayName: 'Custom Stage'
  dependsOn: Build
  jobs:
    - job: CustomJob
      displayName: 'Custom Job'
      steps:
        - script: echo "Custom step"
          displayName: 'Run Custom Step'
```

## Security Considerations

1. **Store Secrets in Variable Groups**
   - Never commit credentials
   - Use Azure Key Vault integration
   - Rotate service principal keys regularly

2. **Limit Service Principal Permissions**
   - Grant only required roles
   - Use resource group scoping
   - Consider managed identities

3. **Audit Pipeline Runs**
   - Monitor successful/failed builds
   - Review build logs for sensitive data
   - Archive build artifacts

4. **Secure Image Content**
   - Remove temporary files during build
   - Disable unnecessary services
   - Apply Windows security patches

## Documentation

- [Azure Pipelines](https://docs.microsoft.com/azure/devops/pipelines)
- [Packer Documentation](https://www.packer.io/docs)
- [Azure Service Connections](https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints)
- [Variable Groups](https://docs.microsoft.com/azure/devops/pipelines/library/variable-groups)

---

**Last Updated**: January 2026
