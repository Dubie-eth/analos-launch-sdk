# 🔓 Enabling Updates to Your Repository

This guide shows how to configure your repository so you (and others) can deploy updates.

## 🎯 Options

### Option 1: Add Yourself to Bypass List (Recommended for Updates)

This allows you to push directly to `main` for updates while still protecting the branch.

### Option 2: Use Pull Request Workflow (Recommended for Team)

This requires pull requests for all changes (even from you).

### Option 3: Set Up CI/CD for Automated Deployments

This allows automated deployments via GitHub Actions.

---

## 🔓 Option 1: Add Yourself to Bypass List

### Step 1: Access Repository Settings

1. Go to: https://github.com/Dubie-eth/analos-launch-sdk/settings/rules
2. Click **"Rulesets"**
3. Click on **"Main Branch Protection"** ruleset
4. Click **"Edit ruleset"** (or the edit button)

### Step 2: Add Bypass

1. Scroll down to **"Bypass list"** section
2. Click **"+ Add bypass"**
3. Select your account:
   - Choose **"Repository administrators"** (if you're the owner)
   - OR add your specific account: **"Dubie-eth"**
4. Click **"Save"** or **"Add"**

### Step 3: Verify

After adding yourself to bypass:
- ✅ You can push directly to `main`
- ✅ Other users still need pull requests
- ✅ Branch protection still active for others

### Step 4: Test Bypass

Try pushing directly to main:
```bash
git checkout main
git push origin main
```

**Should work now!** ✅

---

## 🔄 Option 2: Use Pull Request Workflow (Standard)

**For all updates, use branches and pull requests:**

### Workflow for Updates:

```bash
# 1. Create feature branch
git checkout -b update/sdk-feature

# 2. Make your changes
# ... edit files ...

# 3. Commit changes
git add .
git commit -m "Update SDK with new feature"

# 4. Push to branch
git push -u origin update/sdk-feature

# 5. Create Pull Request on GitHub
# Go to: https://github.com/Dubie-eth/analos-launch-sdk/pulls
# Click "New Pull Request"
# Select: update/sdk-feature → main
# Review and approve
# Merge!
```

**This is the recommended workflow for teams!**

---

## 🤖 Option 3: Set Up Automated Deployments (CI/CD)

### Create GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to npm

on:
  push:
    branches: [main]
    tags:
      - 'v*'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
          registry-url: 'https://registry.npmjs.org'
      
      - run: npm install
      - run: npm run build
      
      - name: Publish to npm
        if: startsWith(github.ref, 'refs/tags/v')
        run: npm publish --access public
        env:
          NODE_AUTH_TOKEN: ${{secrets.NPM_TOKEN}}
```

### For Automated Deployments:

1. **Set up secrets:**
   - Go to: Repository → Settings → Secrets → Actions
   - Add: `NPM_TOKEN` (your npm access token)

2. **Version bumping:**
   - Create tags like `v1.0.1`
   - Workflow will automatically publish to npm

---

## ⚙️ Recommended Configuration

### For Solo Development:

**Enable bypass for yourself:**
- ✅ Add yourself to bypass list
- ✅ Can push directly to main
- ✅ Still protected from others

**Or use branches (safer):**
- ✅ Always use branches
- ✅ Review changes via PR
- ✅ Merge after review

### For Team Development:

**Use pull request workflow:**
- ✅ Everyone uses branches
- ✅ All changes require review
- ✅ CI/CD runs on all PRs
- ✅ Merge after approval

---

## 🔧 Quick Setup: Enable Bypass

### Via GitHub Web Interface:

1. Go to: https://github.com/Dubie-eth/analos-launch-sdk/settings/rules
2. Click **"Rulesets"** → **"Main Branch Protection"**
3. Click **"Edit"** or **"Edit ruleset"**
4. Scroll to **"Bypass list"**
5. Click **"+ Add bypass"**
6. Select **"Repository administrators"** or your username
7. Save

### After Enabling Bypass:

You can now push directly:
```bash
git checkout main
git push origin main
```

**✅ Updates enabled!**

---

## 📋 Configuration Checklist

### For Direct Updates (Bypass):
- [ ] Go to Settings → Rules → Rulesets
- [ ] Edit "Main Branch Protection" ruleset
- [ ] Add yourself to bypass list
- [ ] Test pushing to main
- [ ] Verify it works

### For PR Workflow (Standard):
- [ ] Keep branch protection active
- [ ] Always create branches for changes
- [ ] Create pull requests
- [ ] Review and approve
- [ ] Merge to main

### For Automated Deployments:
- [ ] Create `.github/workflows/deploy.yml`
- [ ] Set up NPM_TOKEN secret
- [ ] Test workflow
- [ ] Create version tag (e.g., `v1.0.1`)
- [ ] Verify automatic deployment

---

## 🎯 Recommended Approach

**For a public SDK repository:**

1. **Enable bypass for yourself** (owner/admin)
   - Allows quick updates when needed
   - Still protects from others

2. **Use pull requests for major changes**
   - Review your own changes
   - Document changes in PR
   - Maintain history

3. **Set up CI/CD for releases**
   - Automatically publish to npm
   - Version management
   - Release automation

---

## 🔗 Quick Links

- **Repository Rules:** https://github.com/Dubie-eth/analos-launch-sdk/settings/rules
- **Bypass Settings:** Rulesets → Main Branch Protection → Edit → Bypass list
- **GitHub Actions:** https://github.com/Dubie-eth/analos-launch-sdk/actions

---

**After setting up bypass, you can push updates directly to main!** ✅

