# PowerShell Script to Install Notepad++
# This script downloads and installs Notepad++ silently

param(
    [string]$InstallPath = "C:\Program Files\Notepad++",
    [switch]$ForceInstall = $false
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

try {
    Write-Log "Starting Notepad++ installation..."
    
    # Create temporary directory for download
    $tempDir = "C:\Temp\Notepad++Install"
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        Write-Log "Created temporary directory: $tempDir"
    }

    # Download Notepad++
    Write-Log "Downloading Notepad++ installer..."
    $installerUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.3/npp.8.6.3.Installer.x64.exe"
    $installerPath = Join-Path $tempDir "npp-installer.exe"
    
    # Use TLS 1.2 for secure download
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -ErrorAction Stop
    Write-Log "Installer downloaded: $installerPath"

    # Verify installer exists
    if (-not (Test-Path $installerPath)) {
        throw "Installer download failed"
    }

    # Install Notepad++ silently
    Write-Log "Installing Notepad++..."
    $installArgs = @(
        "/S"  # Silent install
        "/D=$InstallPath"  # Installation directory
    )
    
    Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -NoNewWindow
    Write-Log "Notepad++ installation completed"

    # Verify installation
    $notepadExe = Join-Path $InstallPath "notepad++.exe"
    if (Test-Path $notepadExe) {
        Write-Log "Notepad++ successfully installed at: $InstallPath" "SUCCESS"
    } else {
        throw "Notepad++ installation verification failed"
    }

    # Cleanup temporary files
    Write-Log "Cleaning up temporary installation files..."
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "Cleanup completed"

    Write-Log "Notepad++ installation finished successfully" "SUCCESS"
    exit 0
}
catch {
    Write-Log "Error during installation: $_" "ERROR"
    exit 1
}
