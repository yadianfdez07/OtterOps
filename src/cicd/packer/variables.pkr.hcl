# Packer Variables for Windows Image Build
# This file defines variables used in the Packer template

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID"
  sensitive   = true
}

variable "azure_client_id" {
  type        = string
  description = "Azure service principal client ID"
  sensitive   = true
}

variable "azure_client_secret" {
  type        = string
  description = "Azure service principal client secret"
  sensitive   = true
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant ID"
  sensitive   = true
}

variable "azure_resource_group" {
  type        = string
  description = "Azure resource group name for temporary VM"
  default     = "rg-packer-temp"
}

variable "azure_location" {
  type        = string
  description = "Azure region for image build"
  default     = "eastus"
}

variable "image_publisher" {
  type        = string
  description = "Publisher of the base Windows image"
  default     = "MicrosoftWindowsDesktop"
}

variable "image_offer" {
  type        = string
  description = "Offer of the base Windows image"
  default     = "Windows-11"
}

variable "image_sku" {
  type        = string
  description = "SKU of the base Windows image"
  default     = "win11-22h2-ent"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size for image building"
  default     = "Standard_D4s_v3"
}

variable "build_resource_group_name" {
  type        = string
  description = "Resource group for the built image"
  default     = "rg-sharedimages-prod"
}

variable "gallery_name" {
  type        = string
  description = "Azure Compute Gallery name"
  default     = "customimages"
}

variable "gallery_image_name" {
  type        = string
  description = "Image definition name in gallery"
  default     = "windows-11-enterprise"
}

variable "image_version" {
  type        = string
  description = "Version of the image (format: major.minor.patch)"
  default     = "1.0.0"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default = {
    "Environment" = "Production"
    "ManagedBy"   = "Packer"
    "Purpose"     = "CustomImageBuild"
  }
}
