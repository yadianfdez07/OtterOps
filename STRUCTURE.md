# Repository Structure

This document describes the organization and structure of the OtterOps repository.

## Directory Layout

```
OtterOps/
├── src/
│   └── infrastructure/          # Infrastructure as Code (IaC)
│       ├── main.bicep           # Main Bicep template for Azure Compute Gallery
│       ├── main.bicepparam      # Default parameter values (committed to git)
│       ├── main.bicepparam.example  # Template for local parameter overrides
│       └── deploy.ps1           # PowerShell deployment script
│
├── SECURITY.md                  # Security policy and guidelines
├── CONTRIBUTING.md              # Contribution guidelines for contributors
├── .gitignore                   # Git ignore patterns to protect sensitive files
├── README.md                    # Main documentation (this file's parent)
└── .git/                        # Git repository metadata
```

## Directory Descriptions

### `src/` - Source Code
Top-level directory for all application and infrastructure source code. Currently contains only the infrastructure subdirectory, but can be extended for additional components.

### `src/infrastructure/` - Infrastructure as Code
Contains all Azure infrastructure definitions using Bicep, along with deployment automation scripts.

**Files:**
- **main.bicep** - Primary Bicep template defining the Azure Compute Gallery resources
- **main.bicepparam** - Default parameters file with example values (safe for public repositories)
- **main.bicepparam.example** - Template showing how to customize parameters locally
- **deploy.ps1** - PowerShell script for automated deployment to Azure

## File Purpose Reference

| File | Purpose | Git Status |
|------|---------|-----------|
| `main.bicep` | Bicep template | Committed |
| `main.bicepparam` | Default parameters with example values | Committed |
| `main.bicepparam.example` | Template for local overrides | Committed |
| `main.bicepparam.local` | **User's local parameters** | **Ignored by .gitignore** |
| `deploy.ps1` | Deployment script | Committed |
| `*.bicepparam.local` | Local parameter overrides | Ignored |
| `.env*` | Environment variables | Ignored |
| `secrets.json` | Sensitive configuration | Ignored |

## How to Use This Structure

### For New Deployments

```powershell
# 1. Navigate to infrastructure directory
cd src/infrastructure

# 2. Copy the example parameters file
cp main.bicepparam.example main.bicepparam.local

# 3. Edit with your specific values
# Edit main.bicepparam.local with your Azure subscription, gallery name, etc.

# 4. Deploy
./deploy.ps1 -ResourceGroupName "your-rg" -ParametersFile "./main.bicepparam.local"
```

### For Contributing

When contributing changes to this repository:

1. Make modifications to Bicep templates or deployment scripts
2. Do **NOT** commit local parameter files (`*.local`)
3. Update main.bicepparam with example/safe default values
4. Test thoroughly before submitting a PR

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Future Structure Considerations

As the project grows, you may expand the structure as follows:

```
src/
├── infrastructure/
│   ├── main/                # Main gallery resources
│   │   ├── main.bicep
│   │   └── main.bicepparam
│   ├── networking/          # Networking resources (Private Link, etc.)
│   │   ├── vnet.bicep
│   │   └── vnet.bicepparam
│   └── scripts/
│       ├── deploy.ps1
│       └── cleanup.ps1
├── automation/              # CI/CD workflows and scripts
│   ├── github/
│   │   └── workflows/
│   └── azure-devops/
│       └── pipelines/
└── docs/                    # Additional documentation
    ├── architecture/
    └── guides/
```

## Security Considerations

- **Committed files**: Only include non-sensitive, example values
- **Ignored files**: Sensitive configuration, credentials, subscription IDs
- **Local files**: Use `.local` pattern for user-specific overrides
- **.gitignore**: Properly configured to prevent accidental commits (see [SECURITY.md](SECURITY.md))

## Naming Conventions

### Files
- **main.bicep** - Primary/default template file
- ***.bicepparam** - Bicep parameter files
- ***.bicepparam.local** - Local parameter overrides (not committed)
- **deploy.ps1** - Main deployment script
- **cleanup.ps1** - Resource cleanup script (if present)

### Directories
- **src/** - Source code root
- **infrastructure/** - Infrastructure definitions
- **scripts/** - Standalone scripts
- **workflows/** - CI/CD workflow definitions

## Maintenance

When modifying this structure:

1. Update this document to reflect changes
2. Ensure .gitignore remains current
3. Update README.md with new paths
4. Update CONTRIBUTING.md with new guidelines
5. Test all paths in deployment documentation

---

**Last Updated:** January 2026
