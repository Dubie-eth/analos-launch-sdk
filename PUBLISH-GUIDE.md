# Publishing @analos/launch-sdk to npm

## Prerequisites

1. npm account with access to `@analos` organization
2. Authenticated npm CLI: `npm login`
3. Clean git repository

## Publishing Steps

### 1. Build the Package

```bash
cd sdk/analos-launch
npm install
npm run build
```

### 2. Check Package Contents

```bash
# See what will be published
npm pack --dry-run

# Or create a tarball to inspect
npm pack
tar -tzf analos-launch-sdk-1.0.0.tgz
```

### 3. Version the Package

```bash
# Update version in package.json
npm version patch  # 1.0.0 -> 1.0.1
npm version minor  # 1.0.0 -> 1.1.0
npm version major  # 1.0.0 -> 2.0.0
```

Or manually update in `package.json`:
```json
{
  "version": "1.0.1"
}
```

### 4. Update Changelog

Update `CHANGELOG.md` with your changes.

### 5. Publish to npm

```bash
# Dry run first
npm publish --dry-run

# Publish (requires npm login)
npm publish --access public
```

**Note:** Since the package name starts with `@analos/`, you need the `--access public` flag for organization-scoped packages.

### 6. Create GitHub Release

After publishing:

1. Create a new release on GitHub
2. Tag the release: `git tag v1.0.0 && git push origin v1.0.0`
3. Include changelog in release notes

## Automated Publishing (CI/CD)

Create `.github/workflows/publish.yml`:

```yaml
name: Publish to npm

on:
  release:
    types: [created]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'
      - run: npm install
      - run: npm run build
      - run: npm publish --access public
        env:
          NODE_AUTH_TOKEN: ${{secrets.NPM_TOKEN}}
```

## Troubleshooting

### Error: "You must be logged in to publish packages"

```bash
npm login
```

### Error: "Package name already exists"

Check if the package name is already taken. You may need to:
- Use a different name
- Contact the owner
- Request transfer

### Error: "Access denied"

Ensure you have publish access to the `@analos` organization on npm.

## Verification

After publishing, verify the package:

```bash
# Install from npm
npm install @analos/launch-sdk

# Test import
node -e "require('@analos/launch-sdk')"
```

## Next Steps

1. Update documentation in main repo to reference npm package
2. Share on social media
3. Add to package comparison sites
4. Request feedback from users

