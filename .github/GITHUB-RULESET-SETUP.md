# 🔒 GitHub Ruleset Setup Guide

This guide will help you set up repository rulesets for the Analos Launch SDK repository.

## 🎯 Recommended Rulesets

### 1. Main Branch Protection

**Protects the `main` branch from:**
- Direct pushes (requires pull requests)
- Merging without approval
- Merging without passing CI checks
- Force pushes and deletions

### 2. Pull Request Requirements

**Enforces:**
- At least 1 approval before merging
- All review threads must be resolved
- Stale reviews are dismissed on new commits

### 3. Status Checks

**Requires:**
- Build must pass before merging
- Tests must pass (if added)

## 📋 Manual Setup Steps

### Option 1: Using GitHub Web Interface

1. **Go to Repository Settings:**
   - Navigate to: https://github.com/Dubie-eth/analos-launch-sdk/settings/rules
   - Or: Repository → Settings → Rules → Rulesets

2. **Create Branch Protection Ruleset:**
   - Click "New ruleset"
   - Select "Ruleset source: Branch ruleset"
   - Name: `Main Branch Protection`

3. **Configure Branch Rules:**
   - **Target branches:** `main`
   - **Enforcement:** Active

4. **Add Rules:**

   **a) Pull Request:**
   - ✅ Require a pull request before merging
   - ✅ Require approvals: `1`
   - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require review from Code Owners: ❌ (optional, since we don't have CODEOWNERS yet)

   **b) Status Checks:**
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - Required status checks: `build` (when CI is added)

   **c) Restrict Deletions:**
   - ✅ Do not allow bypassing the above settings

   **d) Force Pushes:**
   - ❌ Allow force pushes
   - ✅ Allow deletions (optional - you can disable this)

5. **Save Ruleset**

### Option 2: Using GitHub API (Advanced)

You can also set up rulesets via GitHub API. See the JSON file in `.github/rulesets/` for the structure.

## ✅ Recommended Rules

### Minimum Protection (Recommended for Public SDK)

```yaml
Branch Protection for `main`:
  - Require pull request reviews: 1 approval
  - Dismiss stale reviews on new commits: ✅
  - Require status checks: ✅ (when CI added)
  - Require branches to be up to date: ✅
  - Do not allow force pushes: ✅
  - Do not allow deletions: ✅ (optional)
```

### Additional Rules (Optional)

**Issue Labels:**
- Require issues to have labels
- Require pull requests to have labels

**Commit Messages:**
- Require conventional commits (optional)

**Code Owners:**
- Create `.github/CODEOWNERS` file to require reviews from specific people

## 🔧 Step-by-Step Setup

### Step 1: Access Repository Settings

1. Go to: https://github.com/Dubie-eth/analos-launch-sdk
2. Click **Settings** tab
3. Click **Rules** in the left sidebar
4. Click **Rulesets**

### Step 2: Create Branch Protection Ruleset

1. Click **"New ruleset"**
2. Choose **"Branch ruleset"**
3. Fill in the form:

**Name:** `Main Branch Protection`

**Target branches:** `main`

**Enforcement:** 
- ✅ Active (enforce rules immediately)

**Rules to add:**

1. **Pull Request:**
   - ✅ Require a pull request before merging
   - Require approvals: `1`
   - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require review from Code Owners: ❌ (leave unchecked for now)

2. **Status Checks:**
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - Required status checks: (leave empty for now, add `build` when CI is set up)

3. **Conversation Resolution:**
   - ✅ Require all comments on the pull request to be resolved before merging

4. **Restrictions:**
   - ❌ Allow force pushes
   - ❌ Allow deletions

5. **Bypass List:**
   - (Optional) Add repository admins who can bypass rules

6. Click **"Create ruleset"**

### Step 3: Test the Ruleset

1. Try to push directly to `main` - should be blocked
2. Create a test branch and pull request
3. Verify that merging requires approval

## 📝 Example: Create CODEOWNERS (Optional)

Create `.github/CODEOWNERS`:

```
# Global owners
* @Dubie-eth

# SDK code
/index.ts @Dubie-eth
/package.json @Dubie-eth
/tsconfig.json @Dubie-eth
```

This ensures these files always require your approval.

## 🚀 After CI/CD is Added

Once you add CI/CD (GitHub Actions), update the ruleset to require:
- ✅ Status check: `build`
- ✅ Status check: `lint` (if you add linting)
- ✅ Status check: `test` (if you add tests)

## ✅ Checklist

- [ ] Branch protection ruleset created
- [ ] Main branch requires pull requests
- [ ] Requires 1 approval before merging
- [ ] Force pushes disabled
- [ ] Deletions disabled (optional)
- [ ] Status checks required (when CI added)
- [ ] CODEOWNERS file created (optional)
- [ ] Tested ruleset with a test PR

## 🔗 Useful Links

- **Repository Settings:** https://github.com/Dubie-eth/analos-launch-sdk/settings/rules
- **GitHub Docs:** https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets
- **Branch Protection:** https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches

---

**Note:** Rulesets are available on GitHub Free tier for public repositories. You can set up comprehensive protection even without a paid plan!

