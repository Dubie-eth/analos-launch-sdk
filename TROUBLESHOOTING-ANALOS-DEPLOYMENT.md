# 🔧 Troubleshooting Analos Deployment Issues

## Common Problems & Solutions

If you've deployed to devnet successfully via Playground and have all the files (keypair, binary, IDL) but deployment to Analos is failing, use this guide.

---

## 🚨 Common Error Messages & Fixes

### Error 1: "No default signer found" or "unrecognized signer source"

**Problem:** The deployer keypair path is incorrect or not specified.

**Solution:**
```bash
# Windows PowerShell
solana program deploy "C:\path\to\program.so" `
  --url https://rpc.analos.io `
  --keypair "C:\path\to\deployer-keypair.json" `
  --program-id "C:\path\to\program-keypair.json" `
  --use-rpc

# Linux/Mac
solana program deploy /path/to/program.so \
  --url https://rpc.analos.io \
  --keypair /path/to/deployer-keypair.json \
  --program-id /path/to/program-keypair.json \
  --use-rpc
```

**Key Points:**
- Always use `--keypair` flag with full path to your deployer wallet
- Always use `--program-id` flag with full path to program keypair
- Use absolute paths (not relative paths)

---

### Error 2: "Account ... has insufficient funds" or "Below rent-exempt threshold"

**Problem:** The program account needs to be funded before deployment.

**Solution:**

#### Step 1: Check program account balance
```bash
# Get program ID from keypair
solana address -k "C:\path\to\program-keypair.json"

# Check balance
solana balance <PROGRAM_ID> --url https://rpc.analos.io
```

#### Step 2: Fund the program account
```bash
# Transfer SOL to program account
solana transfer <PROGRAM_ID> 3.6 `
  --url https://rpc.analos.io `
  --keypair "C:\path\to\funded-wallet-keypair.json" `
  --allow-unfunded-recipient

# Linux/Mac
solana transfer <PROGRAM_ID> 3.6 \
  --url https://rpc.analos.io \
  --keypair /path/to/funded-wallet-keypair.json \
  --allow-unfunded-recipient
```

#### Step 3: Verify balance
```bash
solana balance <PROGRAM_ID> --url https://rpc.analos.io
```

**Expected Balance:** At least 3-5 LOS for initial deployment.

---

### Error 3: "Either an account has already been initialized or an account balance is below rent-exempt threshold"

**Problem:** This usually means one of:
- The program account already exists but has 0 SOL
- The program account was partially created but not funded
- There's a mismatch between the program ID and keypair

**Solution:**

#### Option A: Fund existing program account (recommended)
```bash
# 1. Get program ID
PROGRAM_ID=$(solana address -k "C:\path\to\program-keypair.json")

# 2. Check if account exists
solana account $PROGRAM_ID --url https://rpc.analos.io

# 3. If it exists but has 0 SOL, fund it
solana transfer $PROGRAM_ID 3.6 `
  --url https://rpc.analos.io `
  --keypair "C:\path\to\funded-wallet-keypair.json" `
  --allow-unfunded-recipient

# 4. Deploy again with upgrade (not initial deploy)
solana program deploy "C:\path\to\program.so" `
  --url https://rpc.analos.io `
  --keypair "C:\path\to\deployer-keypair.json" `
  --program-id "C:\path\to\program-keypair.json" `
  --use-rpc `
  --max-sign-attempts 100
```

#### Option B: Use upgrade authority (if program already deployed)
```bash
solana program deploy "C:\path\to\program.so" `
  --url https://rpc.analos.io `
  --keypair "C:\path\to\deployer-keypair.json" `
  --program-id "C:\path\to\program-keypair.json" `
  --upgrade-authority "C:\path\to\deployer-keypair.json" `
  --use-rpc
```

---

### Error 4: WebSocket connection errors or "Connection refused"

**Problem:** Analos RPC sometimes has WebSocket issues.

**Solution:**
- **Always use `--use-rpc` flag** - This forces HTTP-only mode
- Use `--max-sign-attempts` for reliability

```bash
solana program deploy "C:\path\to\program.so" `
  --url https://rpc.analos.io `
  --keypair "C:\path\to\deployer-keypair.json" `
  --program-id "C:\path\to\program-keypair.json" `
  --use-rpc `
  --max-sign-attempts 100 `
  --with-compute-unit-price 1000
```

---

### Error 5: "Transaction simulation failed" or "Program failed to execute"

**Problem:** The program binary might be invalid or the program ID doesn't match.

**Solution:**

#### Step 1: Verify program ID matches keypair
```bash
# Get address from keypair
solana address -k "C:\path\to\program-keypair.json"

# This should match the program ID you're using
```

#### Step 2: Verify binary was built correctly
```bash
# Check file exists and has reasonable size (> 10KB typically)
ls -lh "C:\path\to\program.so"

# Windows PowerShell
Get-Item "C:\path\to\program.so" | Select-Object Length
```

#### Step 3: Verify you're using the correct keypair files
- **Deployer keypair:** The wallet that pays for deployment (needs LOS)
- **Program keypair:** The program's identity (used for `--program-id`)
- These should be **different files**!

---

### Error 6: "Signature verification failed" or "Invalid signature"

**Problem:** The keypair file is corrupted or in wrong format.

**Solution:**

#### Verify keypair format
The keypair should be a JSON array of 64 numbers (32-byte secret key).

Example valid format:
```json
[1,2,3,...,64]
```

#### Regenerate if needed
```bash
# Generate new program keypair (only if you don't already have one!)
solana-keygen new -o "C:\path\to\program-keypair.json"

# Get the program ID
solana address -k "C:\path\to\program-keypair.json"
```

⚠️ **Warning:** If you regenerate, you'll get a **new program ID**, which means:
- You need to update `declare_id!()` in your program
- You need to rebuild the program
- The old program ID won't work anymore

---

## ✅ Pre-Deployment Checklist

Before deploying, verify all of these:

- [ ] **Deployer wallet has sufficient LOS** (check: `solana balance --url https://rpc.analos.io`)
  - Minimum: 3-5 LOS for first deployment
  - Recommended: 5-10 LOS

- [ ] **Program account is funded** (check: `solana balance <PROGRAM_ID> --url https://rpc.analos.io`)
  - If account exists: Should have 3-5 LOS
  - If account doesn't exist: It will be created during deployment

- [ ] **Program ID matches keypair** (verify: `solana address -k <keypair-path>`)

- [ ] **Binary file exists and is valid** (check file size > 10KB)

- [ ] **Keypair files are valid JSON** (should be array of 64 numbers)

- [ ] **Using correct RPC URL**: `https://rpc.analos.io`

- [ ] **Using `--use-rpc` flag** for Analos

- [ ] **Deployer keypair is different from program keypair**

---

## 🚀 Complete Deployment Command (Recommended)

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

**Flag Explanations:**
- `--use-rpc`: Forces HTTP-only mode (bypasses WebSocket issues)
- `--max-sign-attempts 100`: Retries up to 100 times if needed
- `--with-compute-unit-price 1000`: Sets transaction priority (higher = faster)
- `--commitment confirmed`: Waits for confirmed status

---

## 🔍 Diagnostic Commands

Run these to diagnose issues:

```bash
# 1. Check Solana CLI version
solana --version

# 2. Check current config
solana config get

# 3. Set Analos RPC
solana config set --url https://rpc.analos.io

# 4. Check deployer balance
solana balance --url https://rpc.analos.io

# 5. Get program ID from keypair
solana address -k "C:\path\to\program-keypair.json"

# 6. Check program account (if exists)
solana account <PROGRAM_ID> --url https://rpc.analos.io

# 7. Verify keypair is valid
solana address -k "C:\path\to\keypair.json"
```

---

## 📞 Still Having Issues?

1. **Check the exact error message** - Copy the full error output

2. **Verify file paths** - Use absolute paths, check file exists

3. **Check account balances** - Both deployer and program account

4. **Try step-by-step:**
   - First: Fund program account
   - Second: Verify keypair addresses
   - Third: Deploy with all flags

5. **Alternative: Use the helper script** - See `deploy-to-analos.ps1` or `deploy-to-analos.sh`

---

## 🎯 Quick Reference

| Issue | Solution |
|-------|----------|
| "No default signer" | Use `--keypair` flag with full path |
| "Insufficient funds" | Fund program account with `solana transfer` |
| "Account already initialized" | Fund existing account, use upgrade |
| WebSocket errors | Use `--use-rpc` flag |
| Transaction failed | Check program ID matches keypair |
| Invalid signature | Verify keypair JSON format |

---

**Last Updated:** 2024-01-XX
**For:** Analos Launch SDK v1.0.0

