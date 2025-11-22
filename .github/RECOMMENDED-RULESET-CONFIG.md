# ✅ Recommended Ruleset Configuration

This guide shows exactly which rules to enable for the Analos Launch SDK repository.

## 🎯 Essential Rules (Enable These)

### 1. ✅ **Require a pull request before merging**
- **Enable:** Yes
- **Settings:**
  - ✅ Require pull request approvals: `1`
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from Code Owners: ❌ (Optional - only if you want CODEOWNERS enforcement)
  - ✅ Restrict who can dismiss pull request reviews: ❌ (Optional)

**Why:** Ensures all changes are reviewed before merging to main branch.

---

### 2. ✅ **Block force pushes**
- **Enable:** Yes

**Why:** Prevents accidental or malicious overwriting of commit history.

---

### 3. ✅ **Restrict deletions**
- **Enable:** Yes (Recommended)

**Why:** Prevents accidental deletion of the main branch.

---

### 4. ✅ **Restrict updates** (Optional but Recommended)
- **Enable:** Yes

**Why:** Adds an extra layer of protection - requires bypass permission to update matching refs.

---

### 5. ✅ **Require status checks to pass** (Enable after CI is added)
- **Enable:** Yes (once CI workflow is set up)
- **Settings:**
  - ✅ Require branches to be up to date before merging
  - **Required status checks:** (Add these after CI is set up)
    - `build` (TypeScript compilation)
    - `lint` (if you add linting)
    - `test` (if you add tests)

**Why:** Ensures code compiles and tests pass before merging.

---

## ⚠️ Optional Rules (Consider Later)

### 6. **Require linear history**
- **Enable:** ❌ (Not recommended initially)
- **Why:** Makes history cleaner but can be restrictive for some workflows. Can enable later if needed.

---

### 7. **Require signed commits**
- **Enable:** ❌ (Optional - can enable later)
- **Why:** Adds security but requires GPG setup. Good for enterprise, optional for open source.

---

### 8. **Restrict creations**
- **Enable:** ❌ (Not needed for public SDK)
- **Why:** Only needed if you want to restrict who can create branches. For public repos, anyone can fork.

---

### 9. **Require deployments to succeed**
- **Enable:** ❌ (Not applicable)
- **Why:** Only relevant if you have deployment environments. Not needed for SDK.

---

### 10. **Require code scanning results**
- **Enable:** ❌ (Can enable later)
- **Why:** Advanced security feature. Can add later if needed.

---

### 11. **Require code quality results**
- **Enable:** ❌ (Can enable later)
- **Why:** Advanced feature. Can add later if needed.

---

### 12. **Automatically request Copilot code review**
- **Enable:** ❌ (Optional)
- **Why:** Requires GitHub Copilot subscription. Nice to have but not essential.

---

## 📋 Step-by-Step Setup

### Step 1: Basic Protection

1. Go to: https://github.com/Dubie-eth/analos-launch-sdk/settings/rules
2. Click **"New ruleset"**
3. Select **"Branch ruleset"**
4. Name: `Main Branch Protection`
5. Target branches: `main`

### Step 2: Enable Essential Rules

Enable these rules in order:

**Rule 1: Require a pull request before merging**
- ✅ Enable
- Require approvals: `1`
- ✅ Dismiss stale reviews
- ❌ Require Code Owners (optional)

**Rule 2: Block force pushes**
- ✅ Enable

**Rule 3: Restrict deletions**
- ✅ Enable

**Rule 4: Restrict updates**
- ✅ Enable (recommended)

### Step 3: Save

Click **"Create ruleset"**

### Step 4: Add Status Checks (After CI Setup)

Once you add CI/CD workflow, come back and enable:

**Require status checks to pass**
- ✅ Enable
- ✅ Require branches to be up to date
- Add required checks: `build`

## ✅ Recommended Configuration Summary

```
Main Branch Protection Ruleset:

✅ Require pull request before merging
   └─ Require approvals: 1
   └─ Dismiss stale reviews: Yes

✅ Block force pushes

✅ Restrict deletions

✅ Restrict updates (recommended)

❌ Require linear history (optional later)

❌ Require signed commits (optional later)

⏳ Require status checks (enable after CI setup)
   └─ build (add this when CI is ready)
```

## 🔄 After CI/CD is Added

Once you create a CI workflow (`.github/workflows/ci.yml`), update the ruleset:

1. Go back to Rules → Rulesets → Main Branch Protection
2. Edit the ruleset
3. Enable **"Require status checks to pass"**
4. Check **"Require branches to be up to date"**
5. Add `build` to required status checks
6. Save

## 🎯 What This Protects Against

✅ Direct pushes to main branch  
✅ Merging without review  
✅ Force pushing (rewriting history)  
✅ Deleting the main branch  
✅ Merging broken code (once CI is added)  

## 📝 Bypass Settings

Consider who can bypass these rules:
- **Repository administrators:** Usually can bypass (you)
- **Other bypass actors:** Leave empty for now

You can always edit the ruleset later to add exceptions if needed.

---

**Quick Setup Checklist:**
- [ ] Go to Settings → Rules → Rulesets
- [ ] Create new branch ruleset
- [ ] Enable: Require pull request
- [ ] Enable: Block force pushes
- [ ] Enable: Restrict deletions
- [ ] Enable: Restrict updates
- [ ] Save ruleset
- [ ] Test by trying to push directly to main (should be blocked)
- [ ] Create test PR to verify it requires approval

