// ========================================
// Azure Shared Image Gallery - Parameters File
// ========================================
// This parameters file provides DEFAULT values for deploying the Shared Image Gallery
// 
// SECURITY NOTE: This file is committed to version control.
// For production deployments, copy this to main.bicepparam.local and customize.
// The .local file is automatically ignored by .gitignore.
//
// Usage: ./deploy.ps1 -ResourceGroupName "your-rg" -ParametersFile "./main.bicepparam.local"

using './main.bicep'

// Required parameter - Change to your desired gallery name
// Note: Use underscores or periods, not dashes (Azure restriction)
param galleryName = 'example_gallery_name'

// Optional parameters - customize as needed
param location = 'eastus'

param galleryDescription = 'Development Shared Image Gallery for custom Windows workstation images'

param windowsImages = [
  {
    name: 'windows-11-enterprise'
    description: 'Custom Windows 11 Enterprise with company applications'
    publisher: 'OtterOps'
    offer: 'Windows11'
    sku: '11-enterprise-custom'
    osType: 'Windows'
    osState: 'Generalized'
    hyperVGeneration: 'V2'
  }
]

param tags = {
  Environment: 'Production'
  Purpose: 'CustomImageStorage'
  ManagedBy: 'Bicep'
  CostCenter: 'IT'
  Owner: 'Platform-Team'
}

param enableSoftDelete = false
param softDeleteRetentionDays = 7
