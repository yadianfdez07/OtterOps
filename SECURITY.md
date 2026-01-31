# Security Policy

## Reporting Security Issues

If you discover a security vulnerability in this project, please report it by:

1. **DO NOT** open a public GitHub issue
2. Email the repository maintainers privately
3. Provide detailed information about the vulnerability

We take security seriously and will respond promptly to valid security concerns.

## Security Best Practices

### For Repository Maintainers

1. **Never commit sensitive data:**
   - Azure subscription IDs
   - Resource IDs with sensitive information
   - API keys or secrets
   - Passwords or connection strings
   - Personal access tokens

2. **Use `.gitignore` properly:**
   - Verify `.gitignore` includes all sensitive file patterns
   - Check for accidental commits using `git log --all --full-history -- *sensitive-file*`

3. **Parameter files:**
   - Keep `main.bicepparam` with example/default values only
   - Use `*.bicepparam.local` for environment-specific overrides (already in `.gitignore`)
   - Document required parameters without exposing actual values

4. **Code review:**
   - Review all PRs for accidentally committed secrets
   - Use tools like `git-secrets` or GitHub's secret scanning

### For Users Deploying This Solution

1. **Protect your credentials:**
   - Use Azure Key Vault for secrets
   - Enable Azure Managed Identity where possible
   - Use GitHub Secrets for CI/CD pipelines

2. **RBAC and permissions:**
   - Follow principle of least privilege
   - Use Azure AD groups for access management
   - Regularly audit permissions

3. **Image security:**
   - Generalize VMs properly before capturing images (remove sensitive data)
   - Use Windows sysprep to remove machine-specific information
   - Scan images for security vulnerabilities
   - Keep base images updated with security patches

4. **Network security:**
   - Restrict access to gallery resources using Azure Private Link
   - Use Azure Firewall or NSGs to control traffic
   - Enable Azure Defender for enhanced security monitoring

5. **Soft delete:**
   - Enable soft delete in production (`enableSoftDelete = true`)
   - Set appropriate retention periods (30+ days recommended)

## Secure Development Workflow

### Local Development

```powershell
# Create a local parameters file (ignored by git)
cp main.bicepparam main.bicepparam.local

# Edit the local file with your specific values
# Deploy using your local file
./deploy.ps1 -ResourceGroupName "your-rg" -ParametersFile "./main.bicepparam.local"
```

### CI/CD Pipeline Security

When setting up automated deployments:

1. **Store secrets in GitHub Secrets or Azure Key Vault**
2. **Use service principals with minimal required permissions**
3. **Enable branch protection rules**
4. **Require code reviews before merging**
5. **Use GitHub Actions or Azure DevOps with secure runners**

Example GitHub Actions secret usage:
```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}  # Never hardcode!
```

## Compliance and Governance

- **Azure Policy**: Enforce organizational standards
- **Resource tags**: Track ownership and cost center
- **Audit logging**: Enable Azure Activity Log and monitor for suspicious activity
- **Encryption**: All images are encrypted at rest (Azure default)
- **Regular reviews**: Audit access and clean up unused resources

## Known Security Considerations

### This Repository

✅ **Safe to share publicly:**
- Bicep templates with parameterized values
- Deployment scripts without credentials
- Documentation and examples

⚠️ **User responsibility:**
- Protecting local parameter files
- Managing Azure credentials securely
- Securing deployed resources in Azure

### Image Content Security

Remember that custom VM images may contain:
- Application configurations
- Installed software with potential vulnerabilities
- Cached credentials (if not properly generalized)

**Always:**
- Run sysprep before capturing Windows images
- Remove temporary files and logs
- Update all software to latest security patches
- Scan for malware before creating image versions

## Security Updates

This repository follows these practices:
- Regular dependency updates
- Monitoring for security advisories
- Using official Azure Verified Modules (AVM)
- Following Microsoft's Bicep best practices

## References

- [Azure Security Best Practices](https://learn.microsoft.com/azure/security/fundamentals/best-practices-and-patterns)
- [Securing Azure Compute Gallery](https://learn.microsoft.com/azure/virtual-machines/shared-image-galleries-security)
- [Azure Bicep Security](https://learn.microsoft.com/azure/azure-resource-manager/bicep/security)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)

---

**Last Updated:** January 2026  
**Version:** 1.0
