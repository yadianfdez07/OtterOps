// ========================================
// Azure Shared Image Gallery - Main Bicep Template
// ========================================
// This template deploys an Azure Shared Image Gallery with a Windows image definition
// for storing custom Windows images

targetScope = 'resourceGroup'

// ========================================
// Parameters
// ========================================

@description('Name of the Azure Compute Gallery (Shared Image Gallery)')
@minLength(1)
@maxLength(80)
param galleryName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Description of the gallery')
param galleryDescription string = 'Shared Image Gallery for custom Windows images'

@description('Array of Windows image definitions to create')
param windowsImages array = [
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

@description('Tags to apply to all resources')
param tags object = {
  Environment: 'Production'
  Purpose: 'CustomImageStorage'
  ManagedBy: 'IaC'
}

@description('Enable soft delete policy')
param enableSoftDelete bool = false

@description('Soft delete retention days (7-90 days)')
@minValue(7)
@maxValue(90)
param softDeleteRetentionDays int = 7

// ========================================
// Azure Verified Module - Compute Gallery
// ========================================

module gallery 'br/public:avm/res/compute/gallery:0.9.0' = {
  name: '${galleryName}-deployment'
  params: {
    name: galleryName
    location: location
    description: galleryDescription
    tags: tags
    
    // Configure soft delete policy
    softDeletePolicy: enableSoftDelete ? {
      isSoftDeleteEnabled: true
      softDeleteRetentionInDays: softDeleteRetentionDays
    } : {}
    
    // Create Windows image definitions
    images: [for image in windowsImages: {
      name: image.name
      description: image.description
      osType: image.osType
      osState: image.osState
      hyperVGeneration: image.hyperVGeneration
      identifier: {
        publisher: image.publisher
        offer: image.offer
        sku: image.sku
      }
      // Recommended for Windows images
      isAcceleratedNetworkSupported: true
      // Resource recommendations for typical Windows workloads
      vCPUs: {
        min: 2
        max: 16
      }
      memory: {
        min: 4
        max: 64
      }
    }]
  }
}

// ========================================
// Outputs
// ========================================

@description('The resource ID of the Compute Gallery')
output galleryResourceId string = gallery.outputs.resourceId

@description('The name of the Compute Gallery')
output galleryName string = gallery.outputs.name

@description('The resource group of the Compute Gallery')
output galleryResourceGroup string = gallery.outputs.resourceGroupName

@description('The resource IDs of the image definitions')
output imageDefinitionResourceIds array = gallery.outputs.imageResourceIds

@description('The location where resources were deployed')
output location string = gallery.outputs.location
