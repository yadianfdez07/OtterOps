# Azure DevOps Pipeline Setup & Configuration Guide

## Overview

This guide walks you through setting up and configuring the Azure DevOps pipeline for automated Windows image building with Packer.

## Prerequisites

- ✅ Azure DevOps project created
- ✅ Git repository connected (GitHub or Azure Repos)
- ✅ Azure subscription with appropriate permissions
- ✅ Service Principal with required permissions

## Step 1: Create Azure Service Principal

### Option A: Using Azure CLI

```bash
# Set variables
$subscriptionId = "your-subscription-id"
$resourceGroupName = "rg-sharedimages-prod"
$spName = "sp-packer-pipeline"

# Login to Azure
az login
az account set --subscription $subscriptionId

# Create service principal
$sp = az ad sp create-for-rbac `
  --name $spName `
  --role "Contributor" `
  --scopes "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName" `
  --format json | ConvertFrom-Json

# Save these values - you'll need them for Azure DevOps
Write-Output "Service Principal Details:"
Write-Output "Client ID: $($sp.clientId)"
Write-Output "Client Secret: $($sp.clientSecret)"
Write-Output "Tenant ID: $($sp.tenantId)"
```

### Option B: Using Azure Portal

1. Go to Azure AD > App Registrations
2. Click "New registration"
3. Enter name: `sp-packer-pipeline`
4. Click "Register"
5. Note the Application (client) ID and Tenant ID
6. Go to "Certificates & secrets"
7. Create new client secret
8. Copy the secret value

## Step 2: Create Azure DevOps Variable Group

### Via Azure DevOps Web UI

```
1. Go to your Azure DevOps project
2. Pipelines > Library
3. Click "+ Variable group"
4. Name: "Packer-Pipeline-Variables"
5. Add the following secret variables:
```

| Variable Name | Value |
|---------------|-------|
| AZURE_SUBSCRIPTION_ID | From service principal |
| AZURE_CLIENT_ID | Application (client) ID |
| AZURE_CLIENT_SECRET | Client secret (mark as secret) |
| AZURE_TENANT_ID | Tenant ID |

### Via Azure CLI

```bash
# Create variable group using Azure DevOps CLI extension
az devops variable-group create `
  --name "Packer-Pipeline-Variables" `
  --variables `
    AZURE_SUBSCRIPTION_ID="your-subscription-id" `
    AZURE_LOCATION="eastus" `
    IMAGE_VERSION="1.0.0" `
  --org https://dev.azure.com/your-org `
  --project "your-project"

# Add secret variables (one at a time)
az devops variable-group variable create `
  --group-id <group-id> `
  --name "AZURE_CLIENT_ID" `
  --value "your-client-id" `
  --secret `
  --org https://dev.azure.com/your-org `
  --project "your-project"
```

## Step 3: Create Azure Service Connection

### Via Azure DevOps Web UI

```
1. Project Settings > Service connections
2. Click "New service connection"
3. Select "Azure Resource Manager"
4. Select "Service principal (automatic)"
5. Select Subscription and Resource Group
6. Name: "Azure-ServiceConnection"
7. Save
```

### Via Azure DevOps CLI

```bash
# Create service connection
az devops service-endpoint azurerm create `
  --azure-rm-subscription-id $subscriptionId `
  --azure-rm-subscription-name "Your Subscription" `
  --azure-rm-tenant-id $tenantId `
  --name "Azure-ServiceConnection" `
  --org https://dev.azure.com/your-org `
  --project "your-project"
```

## Step 4: Create the Pipeline

### Via Azure DevOps Web UI

```
1. Pipelines > Create Pipeline
2. Select repository
3. Select "Existing Azure Pipelines YAML file"
4. Branch: main
5. Path: src/cicd/azure-pipelines.yml
6. Review the YAML
7. Click "Run" or "Save"
```

### Via Azure DevOps CLI

```bash
az pipelines create `
  --name "Build-Windows-Image" `
  --repository "OtterOps" `
  --branch main `
  --yml-path "src/cicd/azure-pipelines.yml" `
  --org https://dev.azure.com/your-org `
  --project "your-project"
```

## Step 5: Configure Pipeline Variables

Update the following in `src/cicd/azure-pipelines.yml`:

```yaml
variables:
  PACKER_VERSION: '1.9.4'           # Packer version
  AZURE_LOCATION: 'eastus'          # Azure region
  IMAGE_VERSION: '1.0.0'            # Semantic version
  GALLERY_NAME: 'sig_customwindows_prod'  # Gallery name
  GALLERY_IMAGE_NAME: 'windows-11-enterprise'  # Image definition
```

## Step 6: Link Variable Group to Pipeline

Add to `azure-pipelines.yml`:

```yaml
variables:
  - group: Packer-Pipeline-Variables  # Add this line
  PACKER_VERSION: '1.9.4'
  # ... other variables
```

## Step 7: Set Up Service Connection in Pipeline

Update the `AzureCLI@2` tasks:

```yaml
- task: AzureCLI@2
  displayName: 'Azure Login'
  inputs:
    azureSubscription: 'Azure-ServiceConnection'  # Your connection name
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      echo "Azure authenticated"
```

## Step 8: Verify Installation

### Check Required Tools

```bash
# Verify Packer installation
packer --version

# Verify Azure CLI
az --version

# Verify Bicep
az bicep version

# Verify git
git --version
```

## Step 9: Run Pipeline Manually

```
1. Go to Pipelines > [Your Pipeline]
2. Click "Run pipeline"
3. Select branch: main
4. Click "Run"
5. Monitor the build in the queue
```

## Step 10: Monitor Pipeline Execution

### View Pipeline Runs

```
1. Pipelines > All > [Your Pipeline]
2. View run history
3. Click specific run to see logs
```

### Common Log Locations

- **Validation logs**: Validate stage
- **Packer build logs**: Build stage
- **Verification logs**: Verify stage

## Troubleshooting

### Authentication Errors

**Error**: `AADSTS70002: Client authentication failed`

**Solution**:
- Verify service principal credentials in variable group
- Ensure client secret hasn't expired
- Regenerate secret if needed

### Permission Errors

**Error**: `User does not have permission to perform action Microsoft.Compute/galleries/write`

**Solution**:
- Grant Contributor role to service principal
- Scope to resource group: `/subscriptions/{id}/resourceGroups/{rg}`

### Packer Validation Fails

**Error**: `Error parsing template`

**Solution**:
```bash
# Validate locally
cd src/cicd/packer
packer fmt -recursive .
packer validate -var-file="terraform.tfvars" .
```

### Build Timeout

**Error**: `Build exceeded timeout`

**Solution**:
- Increase timeout in pipeline: `timeoutInMinutes: 240`
- Use larger VM size in Packer: `vm_size = "Standard_D8s_v3"`
- Check internet connectivity for downloads

### Image Not Found in Gallery

**Error**: `Image version not found in gallery`

**Solution**:
- Verify gallery exists: `az sig list`
- Check resource group: `az sig show --resource-group rg-sharedimages-prod --gallery-name sig_customwindows_prod`
- Verify image definition created

## Advanced Configuration

### Enable Badge in Repository

```markdown
# In README.md
[![Build Status](https://dev.azure.com/your-org/your-project/_apis/build/status/Build-Windows-Image?branchName=main)](https://dev.azure.com/your-org/your-project/_build/latest?definitionId=XX&branchName=main)
```

### Add Scheduled Builds

```yaml
schedules:
  - cron: "0 2 * * 0"  # Every Sunday at 2 AM UTC
    displayName: Weekly image rebuild
    branches:
      include:
        - main
```

### Add Approval Gates

```yaml
approvals:
  - environment: 'Production'
    approvers:
      - [your-email@company.com]
```

### Add Notifications

Via Azure DevOps UI:
```
1. Project Settings > Service connections
2. Create Slack/Teams connection
3. Add notification step in pipeline
```

## Security Best Practices

1. **Rotate Credentials Regularly**
   - Regenerate client secrets every 90 days
   - Update in variable group

2. **Limit Service Principal Scope**
   - Use resource group scope, not subscription
   - Apply principle of least privilege

3. **Audit Pipeline Runs**
   - Monitor successful/failed builds
   - Review build logs regularly

4. **Secure Build Logs**
   - Don't log credentials
   - Redact sensitive information

5. **Use Managed Identity (If Available)**
   - Prefer managed identity over service principal
   - No credential rotation needed

## Useful Commands

```bash
# List all pipelines
az pipelines list --org https://dev.azure.com/your-org --project "your-project"

# Get pipeline details
az pipelines show --id <pipeline-id> --org https://dev.azure.com/your-org --project "your-project"

# Queue a build
az pipelines run --id <pipeline-id> --org https://dev.azure.com/your-org --project "your-project"

# View latest build
az pipelines builds list --org https://dev.azure.com/your-org --project "your-project" --top 1
```

## Documentation

- [Azure DevOps Pipelines](https://docs.microsoft.com/azure/devops/pipelines)
- [Packer Azure Plugin](https://www.packer.io/plugins/builders/azure)
- [Azure Service Connections](https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints)
- [Variable Groups](https://docs.microsoft.com/azure/devops/pipelines/library/variable-groups)

---

**Last Updated**: January 2026
**Version**: 1.0
