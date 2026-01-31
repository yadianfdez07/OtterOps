# Contributing to OtterOps

Thank you for your interest in contributing to this project!

## How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

## Pull Request Guidelines

- Provide a clear description of the changes
- Ensure all Bicep files follow best practices
- Test your changes in a non-production Azure subscription
- Update documentation (README.md) if needed
- Never commit sensitive data (credentials, subscription IDs, etc.)

## Code Standards

### Bicep Code

- Use descriptive parameter and variable names
- Add `@description()` decorators to all parameters
- Follow [Azure Bicep best practices](https://learn.microsoft.com/azure/azure-resource-manager/bicep/best-practices)
- Use Azure Verified Modules where possible

### Documentation

- Keep README.md updated with any new features
- Use clear examples without sensitive data
- Include cost implications for new resources

## Security

- Review [SECURITY.md](SECURITY.md) before contributing
- Never commit secrets, passwords, or API keys
- Use placeholder values in examples (e.g., `{sub-id}`, `{your-value}`)
- Run `git log --all --full-history -- *` to check for accidentally committed secrets

## Testing

Before submitting a PR:

1. Navigate to the infrastructure directory: `cd src/infrastructure`
2. Test deployment in a sandbox Azure subscription
3. Verify Bicep compilation: `az bicep build --file main.bicep`
4. Run what-if analysis: `./deploy.ps1 -ResourceGroupName "test-rg" -WhatIf`
5. Clean up test resources after validation
6. Never commit local parameter files (`*.bicepparam.local`)

## Questions?

Feel free to open an issue for:
- Bug reports
- Feature requests
- Documentation improvements
- Questions about the code

---

Thank you for helping improve this project! 🎉
