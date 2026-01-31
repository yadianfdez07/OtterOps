# ========================================
# Azure Shared Image Gallery Deployment Script
# ========================================
# This script deploys the Azure Shared Image Gallery using Azure CLI or Azure PowerShell

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory = $false)]
    [string]$ParametersFile = "./main.bicepparam",
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf
)

# ========================================
# Variables
# ========================================
$templateFile = "./main.bicep"
$deploymentName = "sig-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')"

# ========================================
# Functions
# ========================================
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# ========================================
# Main Deployment Logic
# ========================================

Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Azure Shared Image Gallery Deployment" "Cyan"
Write-ColorOutput "========================================" "Cyan"
Write-Host ""

# Check if Azure PowerShell module is available
if (Get-Module -ListAvailable -Name Az.Resources) {
    Write-ColorOutput "[✓] Azure PowerShell module detected" "Green"
    $useAzModule = $true
} else {
    Write-ColorOutput "[!] Azure PowerShell module not found. Checking for Azure CLI..." "Yellow"
    $useAzModule = $false
}

# Check if Azure CLI is available
if (-not $useAzModule) {
    $azCliCheck = Get-Command az -ErrorAction SilentlyContinue
    if ($null -eq $azCliCheck) {
        Write-ColorOutput "[✗] Neither Azure PowerShell nor Azure CLI found!" "Red"
        Write-ColorOutput "Please install one of the following:" "Red"
        Write-ColorOutput "  - Azure PowerShell: https://aka.ms/installazpowershell" "Yellow"
        Write-ColorOutput "  - Azure CLI: https://aka.ms/installazurecli" "Yellow"
        exit 1
    }
    Write-ColorOutput "[✓] Azure CLI detected" "Green"
}

Write-Host ""

# Create Resource Group if it doesn't exist
Write-ColorOutput "[*] Checking resource group: $ResourceGroupName" "Cyan"

if ($useAzModule) {
    # Using Azure PowerShell
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if ($null -eq $rg) {
        Write-ColorOutput "[*] Creating resource group: $ResourceGroupName in $Location" "Yellow"
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location | Out-Null
        Write-ColorOutput "[✓] Resource group created successfully" "Green"
    } else {
        Write-ColorOutput "[✓] Resource group already exists" "Green"
    }
} else {
    # Using Azure CLI
    $rgExists = az group exists --name $ResourceGroupName
    if ($rgExists -eq "false") {
        Write-ColorOutput "[*] Creating resource group: $ResourceGroupName in $Location" "Yellow"
        az group create --name $ResourceGroupName --location $Location --output none
        Write-ColorOutput "[✓] Resource group created successfully" "Green"
    } else {
        Write-ColorOutput "[✓] Resource group already exists" "Green"
    }
}

Write-Host ""

# Deploy Bicep template
if ($WhatIf) {
    Write-ColorOutput "[*] Running What-If analysis..." "Cyan"
    Write-Host ""
    
    if ($useAzModule) {
        New-AzResourceGroupDeployment `
            -Name $deploymentName `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $templateFile `
            -TemplateParameterFile $ParametersFile `
            -WhatIf
    } else {
        az deployment group what-if `
            --name $deploymentName `
            --resource-group $ResourceGroupName `
            --template-file $templateFile `
            --parameters $ParametersFile
    }
} else {
    Write-ColorOutput "[*] Starting deployment: $deploymentName" "Cyan"
    Write-Host ""
    
    if ($useAzModule) {
        $deployment = New-AzResourceGroupDeployment `
            -Name $deploymentName `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $templateFile `
            -TemplateParameterFile $ParametersFile `
            -Verbose
        
        if ($deployment.ProvisioningState -eq "Succeeded") {
            Write-Host ""
            Write-ColorOutput "[✓] Deployment completed successfully!" "Green"
            Write-Host ""
            Write-ColorOutput "Deployment Outputs:" "Cyan"
            Write-ColorOutput "===================" "Cyan"
            $deployment.Outputs | Format-Table -AutoSize
        } else {
            Write-ColorOutput "[✗] Deployment failed!" "Red"
            exit 1
        }
    } else {
        $deploymentResult = az deployment group create `
            --name $deploymentName `
            --resource-group $ResourceGroupName `
            --template-file $templateFile `
            --parameters $ParametersFile `
            --output json | ConvertFrom-Json
        
        if ($deploymentResult.properties.provisioningState -eq "Succeeded") {
            Write-Host ""
            Write-ColorOutput "[✓] Deployment completed successfully!" "Green"
            Write-Host ""
            Write-ColorOutput "Deployment Outputs:" "Cyan"
            Write-ColorOutput "===================" "Cyan"
            $deploymentResult.properties.outputs | ConvertTo-Json -Depth 10
        } else {
            Write-ColorOutput "[✗] Deployment failed!" "Red"
            exit 1
        }
    }
}

Write-Host ""
Write-ColorOutput "========================================" "Cyan"
Write-ColorOutput "Deployment Complete" "Cyan"
Write-ColorOutput "========================================" "Cyan"
