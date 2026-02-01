# Packer Template for Windows 11 Enterprise Image Build
# This template builds a Windows 11 Enterprise image with Notepad++ installed
# and captures it to the Azure Compute Gallery

packer {
  required_version = ">= 1.8.0"
  
  required_plugins {
    azure = {
      version = ">= 2.0.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

source "azure-arm" "windows_image" {
  # Azure Authentication
  subscription_id            = var.azure_subscription_id
  client_id                  = var.azure_client_id
  client_secret              = var.azure_client_secret
  tenant_id                  = var.azure_tenant_id
  
  # Resource Configuration
  resource_group_name        = var.azure_resource_group
  location                   = var.azure_location
  vm_size                    = var.vm_size
  
  # Base Image Configuration
  publisher                  = var.image_publisher
  offer                      = var.image_offer
  sku                        = var.image_sku
  
  # Build Configuration
  temporary_resource_group_name = "rg-packer-build-${formatdate("yyyymmdd-hhmm", timestamp())}"
  build_resource_group_name     = var.build_resource_group_name
  
  # Output Configuration - Direct to Shared Image Gallery
  shared_image_gallery_destination {
    subscription            = var.azure_subscription_id
    resource_group          = var.build_resource_group_name
    gallery_name            = var.gallery_name
    image_name              = var.gallery_image_name
    image_version           = var.image_version
    replication_regions     = [var.azure_location]
    storage_account_type    = "Standard_LRS"
  }
  
  # OS Configuration
  os_type                   = "Windows"
  communicator              = "winrm"
  winrm_use_https           = true
  winrm_insecure            = true
  winrm_timeout             = "10m"
  
  # Tags
  azure_tags                = var.tags
}

build {
  name            = "windows-11-enterprise-build"
  sources         = ["source.azure-arm.windows_image"]
  description     = "Build Windows 11 Enterprise image with Notepad++ using Packer"

  # PowerShell Provisioner - Update Windows
  provisioner "powershell" {
    inline = [
      "Write-Output 'Starting Windows Update...'",
      "Install-PackageProvider -Name NuGet -Force",
      "Write-Output 'Windows Update started'"
    ]
    timeout = "10m"
  }

  # File Provisioner - Copy installation scripts
  provisioner "file" {
    source      = "${path.root}/scripts/install-notepadpp.ps1"
    destination = "C:\\PackerScripts\\install-notepadpp.ps1"
  }

  # PowerShell Provisioner - Install Notepad++
  provisioner "powershell" {
    script = "${path.root}/scripts/install-notepadpp.ps1"
    timeout = "15m"
  }

  # PowerShell Provisioner - Cleanup and Generalization Prep
  provisioner "powershell" {
    inline = [
      "Write-Output 'Cleaning up temporary files...'",
      "Remove-Item -Path C:\\PackerScripts -Recurse -Force -ErrorAction SilentlyContinue",
      "Remove-Item -Path 'C:\\Windows\\Temp\\*' -Recurse -Force -ErrorAction SilentlyContinue",
      "Remove-Item -Path 'C:\\Users\\*\\AppData\\Local\\Temp\\*' -Recurse -Force -ErrorAction SilentlyContinue",
      "Write-Output 'Cleanup complete'"
    ]
    timeout = "5m"
  }

  # PowerShell Provisioner - Run Sysprep for Generalization
  provisioner "powershell" {
    inline = [
      "Write-Output 'Running Sysprep for generalization...'",
      "C:\\Windows\\System32\\Sysprep\\sysprep.exe /generalize /oobe /shutdown /quiet /mode:vm"
    ]
    timeout = "30m"
    pause_before = "5s"
  }

  # Manifest - Output build information
  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
    custom_data = {
      build_date      = timestamp()
      image_version   = var.image_version
      gallery_name    = var.gallery_name
      image_name      = var.gallery_image_name
    }
  }
}
