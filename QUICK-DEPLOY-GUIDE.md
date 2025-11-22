# ⚡ Quick Deploy Guide for Analos

## 📋 Prerequisites

Before deploying, make sure you have:

- ✅ **All files from Playground:**
  - Program binary (`.so` file)
  - Program keypair (`.json` file)
  - IDL (`.json` file)
  - Program ID (public key string)

- ✅ **Deployer wallet** with sufficient LOS (5-10 LOS recommended)

- ✅ **Solana CLI** installed and configured

---

## 🚀 Option 1: Use Helper Script (Recommended)

### Windows PowerShell

```powershell
# Basic deployment
.\deploy-to-analos.ps1 `
  -ProgramBinaryPath "C:\Users\Downloads\my-program.so" `
  -ProgramKeypairPath "C:\Users\Downloads\program-keypair.json" `
  -DeployerKeypairPath "C:\path\to\deployer-keypair.json"

# With custom funding amount
.\deploy-to-analos.ps1 `
  -ProgramBinaryPath "C:\Users\Downloads\my-program.so" `
  -ProgramKeypairPath "C:\Users\Downloads\program-keypair.json" `
  -DeployerKeypairPath "C:\path\to\deployer-keypair.json" `
  -FundAmount 5.0

# Verify only (test without deploying)
.\deploy-to-analos.ps1 `
  -ProgramBinaryPath "C:\Users\Downloads\my-program.so" `
  -ProgramKeypairPath "C:\Users\Downloads\program-keypair.json" `
  -DeployerKeypairPath "C:\path\to\deployer-keypair.json" `
  -VerifyOnly
```

### Linux/Mac Bash

```bash
# Make script executable (first time only)
chmod +x deploy-to-analos.sh

# Basic deployment
./deploy-to-analos.sh \
  --binary /path/to/my-program.so \
  --program-keypair /path/to/program-keypair.json \
  --deployer-keypair /path/to/deployer-keypair.json

# With custom funding amount
./deploy-to-analos.sh \
  --binary /path/to/my-program.so \
  --program-keypair /path/to/program-keypair.json \
  --deployer-keypair /path/to/deployer-keypair.json \
  --fund-amount 5.0

# Verify only (test without deploying)
./deploy-to-analos.sh \
  --binary /path/to/my-program.so \
  --program-keypair /path/to/program-keypair.json \
  --deployer-keypair /path/to/deployer-keypair.json \
  --verify-only
```

**What the script does:**
1. ✅ Verifies all files exist and are valid
2. ✅ Checks deployer wallet balance
3. ✅ Checks program account (if exists) and funds it if needed
4. ✅ Verifies program ID matches keypair
5. ✅ Deploys with correct flags for Analos
6. ✅ Verifies deployment after completion

---

## 🚀 Option 2: Manual Deployment

If you prefer to deploy manually, follow these steps:

### Step 1: Verify Files

```bash
# Get program ID from keypair
solana address -k "C:\path\to\program-keypair.json"

# Check deployer balance
solana balance --url https://rpc.analos.io --keypair "C:\path\to\deployer-keypair.json"

# Check program account (if exists)
solana account <PROGRAM_ID> --url https://rpc.analos.io
```

### Step 2: Fund Program Account (if needed)

If the program account exists but has 0 SOL:

```bash
# Windows PowerShell
solana transfer <PROGRAM_ID> 3.6 `
  --url https://rpc.analos.io `
  --keypair "C:\path\to\deployer-keypair.json" `
  --allow-unfunded-recipient

# Linux/Mac
solana transfer <PROGRAM_ID> 3.6 \
  --url https://rpc.analos.io \
  --keypair /path/to/deployer-keypair.json \
  --allow-unfunded-recipient
```

### Step 3: Deploy

```bash
# Windows PowerShell
solana program deploy "C:\path\to\program.so" `
  --url https://rpc.analos.io `
  --keypair "C:\path\to\deployer-keypair.json" `
  --program-id "C:\path\to\program-keypair.json" `
  --use-rpc `
  --max-sign-attempts 100 `
  --with-compute-unit-price 1000 `
  --commitment confirmed

# Linux/Mac
solana program deploy /path/to/program.so \
  --url https://rpc.analos.io \
  --keypair /path/to/deployer-keypair.json \
  --program-id /path/to/program-keypair.json \
  --use-rpc \
  --max-sign-attempts 100 \
  --with-compute-unit-price 1000 \
  --commitment confirmed
```

### Step 4: Verify Deployment

```bash
solana program show <PROGRAM_ID> --url https://rpc.analos.io
```

---

## 🔧 Common Issues & Quick Fixes

### Issue 1: "No default signer found"

**Fix:** Always specify `--keypair` flag with full path to deployer keypair

```bash
--keypair "C:\full\path\to\deployer-keypair.json"
```

### Issue 2: "Account has insufficient funds"

**Fix:** Fund the program account first (see Step 2 above)

### Issue 3: "Account already initialized"

**Fix:** Program account exists but has 0 SOL. Fund it, then deploy again (it will upgrade)

### Issue 4: WebSocket errors

**Fix:** Always use `--use-rpc` flag for Analos deployments

### Issue 5: "Program ID doesn't match keypair"

**Fix:** Verify program ID matches the keypair:
```bash
solana address -k "C:\path\to\program-keypair.json"
```

---

## 📋 Deployment Checklist

Before deploying, verify:

- [ ] Program binary exists and is valid (> 10KB typically)
- [ ] Program keypair exists and is valid JSON
- [ ] Deployer keypair exists and has sufficient LOS (5-10 LOS)
- [ ] Program ID matches keypair address
- [ ] Program account is funded (3-5 LOS) if it already exists
- [ ] RPC URL is correct: `https://rpc.analos.io`
- [ ] Using `--use-rpc` flag for Analos

---

## 🆘 Still Having Issues?

1. **Check the troubleshooting guide:** [TROUBLESHOOTING-ANALOS-DEPLOYMENT.md](./TROUBLESHOOTING-ANALOS-DEPLOYMENT.md)

2. **Use verify-only mode** to check configuration:
   ```powershell
   .\deploy-to-analos.ps1 -ProgramBinaryPath "..." -ProgramKeypairPath "..." -DeployerKeypairPath "..." -VerifyOnly
   ```

3. **Check the error message** - It usually tells you what's wrong

4. **Verify file paths** - Use absolute paths, check files exist

5. **Check balances** - Both deployer and program account

---

## ✅ Success!

After successful deployment, you should see:

```
✅ Deployment successful!

Program Id: <YOUR_PROGRAM_ID>
```

**Next Steps:**
1. Save your Program ID
2. Update your frontend/IDL with the new Program ID
3. Test your program on Analos mainnet!

**Explorer:** https://explorer.analos.io/address/<YOUR_PROGRAM_ID>

---

**Last Updated:** 2024-01-XX
**For:** Analos Launch SDK v1.0.0

