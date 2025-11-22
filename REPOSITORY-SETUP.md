# Repository Setup Guide

This guide helps you set up a standalone public repository for the Analos Launch SDK.

## Option 1: Create New Repository on GitHub

### Step 1: Create Repository

1. Go to https://github.com/new
2. Repository name: `analos-launch-sdk`
3. Description: "TypeScript SDK for deploying and launching programs on Analos blockchain"
4. Visibility: **Public**
5. **Don't** initialize with README, .gitignore, or license (we have these)
6. Click "Create repository"

### Step 2: Initialize Git

```bash
cd sdk/analos-launch

# Initialize git (if not already)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Analos Launch SDK v1.0.0"

# Add remote (replace with your username/org)
git remote add origin https://github.com/YOUR_USERNAME/analos-launch-sdk.git

# Or if using SSH
git remote add origin git@github.com:YOUR_USERNAME/analos-launch-sdk.git

# Push
git branch -M main
git push -u origin main
```

### Step 3: Create GitHub Release

1. Go to repository → Releases → "Create a new release"
2. Tag: `v1.0.0`
3. Title: `v1.0.0 - Initial Release`
4. Description: Copy from CHANGELOG.md
5. Click "Publish release"

## Option 2: Extract as Standalone Package

If you want to copy the SDK to a new location first:

```bash
# Create new directory
mkdir ../analos-launch-sdk
cd ../analos-launch-sdk

# Copy SDK files
cp -r ../analos-nft-frontend-minimal/sdk/analos-launch/* .

# Initialize git
git init
git add .
git commit -m "Initial commit: Analos Launch SDK v1.0.0"

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/analos-launch-sdk.git
git branch -M main
git push -u origin main
```

## Repository Structure

```
analos-launch-sdk/
├── src/
│   └── index.ts          # Main SDK code (or keep as index.ts)
├── dist/                 # Built files (generated)
├── package.json          # Package configuration
├── tsconfig.json         # TypeScript config
├── README.md             # Main documentation
├── LICENSE               # MIT License
├── CHANGELOG.md          # Version history
├── CONTRIBUTING.md       # Contribution guide
├── .gitignore            # Git ignore rules
├── .npmignore            # npm ignore rules
└── PUBLISH-GUIDE.md      # Publishing instructions
```

## GitHub Repository Settings

### Topics (add these)
- `analos`
- `solana`
- `blockchain`
- `deployment`
- `sdk`
- `typescript`
- `program-launch`
- `smart-contracts`

### Description
"TypeScript SDK for deploying and launching Solana programs on Analos blockchain. Utilities for deployment, verification, network monitoring, and more."

### Website (optional)
If you have a website: `https://analos.io`

## Badges (Add to README)

```markdown
[![npm version](https://badge.fury.io/js/%40analos%2Flaunch-sdk.svg)](https://badge.fury.io/js/%40analos%2Flaunch-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://www.typescriptlang.org/)
```

## Next Steps

1. ✅ Create GitHub repository
2. ✅ Push code
3. ✅ Add topics and description
4. ✅ Create first release
5. ⬜ Publish to npm (optional)
6. ⬜ Add CI/CD workflows
7. ⬜ Create examples repository
8. ⬜ Share on social media

## CI/CD Workflow (Optional)

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: npm install
      - run: npm run build
      - run: npm test
```

## License

Make sure LICENSE file is included (already added as MIT).

## Support

- **GitHub Issues:** https://github.com/YOUR_USERNAME/analos-launch-sdk/issues
- **Documentation:** See README.md
- **Examples:** Create `examples/` directory

