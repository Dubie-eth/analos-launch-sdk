# 🚀 Complete Deployment Workflow: Playground → Analos

This guide walks through the complete workflow for deploying programs to Analos using Solana Playground and CLI.

## 📋 Overview

**Complete Workflow:**
1. ✅ **Build & Test** in Solana Playground (devnet)
2. ✅ **Deploy to Devnet** via Playground
3. ✅ **Download Artifacts** (binary, keypair, IDL)
4. ✅ **Deploy to Analos Mainnet** via Solana CLI with proper flags

---

## 🎯 Part 1: Solana Playground Setup

### Step 1: Open Solana Playground

1. Go to: **https://beta.solpg.io**
2. Create a new project (or open existing)
3. Select **"Anchor"** framework

### Step 2: Copy Your Program Files

Copy these files to Playground:

**Required Files:**
- `Cargo.toml` → Paste into Playground `Cargo.toml`
- `Anchor.toml` → Paste into Playground `Anchor.toml`
- `src/lib.rs` → Paste into Playground `src/lib.rs`
- `src/instructions/` → All instruction files
- `src/state/` → All state files
- `src/errors.rs` → Error definitions

**⚠️ IMPORTANT:** Make sure `src/lib.rs` has placeholder ID:
```rust
declare_id!("11111111111111111111111111111111");
```

### Step 3: Generate Program ID

**In Playground terminal:**
```bash
solana-keygen new -o target/deploy/my_program-keypair.json
solana address -k target/deploy/my_program-keypair.json
```

**📋 COPY THE PROGRAM ID!** Example: `AbCdEfGhIjKlMnOpQrStUvWxYz1234567890`

### Step 4: Update Program ID in Playground

**1. Update `src/lib.rs`:**
```rust
declare_id!("YOUR_PROGRAM_ID_HERE");
```

**2. Update `Anchor.toml`:**
```toml
[programs.localnet]
my_program = "YOUR_PROGRAM_ID_HERE"

[programs.devnet]
my_program = "YOUR_PROGRAM_ID_HERE"

[programs.mainnet]
my_program = "YOUR_PROGRAM_ID_HERE"
```

### Step 5: Build the Program

1. Click **"Build"** button (🔨) in Playground
2. Wait for compilation (1-2 minutes)
3. Should show: **"Build successful"** ✅

### Step 6: Deploy to Devnet

1. Make sure Playground wallet has SOL on devnet
   - If not, click **"Airdrop"** button (💧)
2. Click **"Deploy"** button in Playground
3. Confirm the deployment transaction
4. Wait for confirmation

**Expected Output:**
```
Deploying...
Program Id: YOUR_PROGRAM_ID
Deploy successful. Completed in Xs.
Signature: AbCdEfGhIjKlMnOpQrStUvWxYz1234567890...
```

**✅ Deployment successful on devnet!**

---

## 📦 Part 2: Download Artifacts from Playground

After successful devnet deployment, download these **3 critical files**:

### File 1: Program Binary (`.so` file)

1. In Playground, navigate to: `target/deploy/`
2. Right-click on `my_program.so`
3. Click **"Download"**
4. Save to your computer (e.g., `~/Downloads/my_program.so`)

**📋 File size:** Typically 50-500 KB

### File 2: Program Keypair (`.json` file) ⚠️ SECRET!

1. In Playground, navigate to: `target/deploy/`
2. Right-click on `my_program-keypair.json`
3. Click **"Download"**
4. Save to your computer (e.g., `~/Downloads/my_program-keypair.json`)

**🔒 CRITICAL:** 
- **KEEP THIS SECURE!**
- **DO NOT commit to GitHub!**
- **This is needed to upgrade the program later**

### File 3: IDL (`.json` file)

1. In Playground, navigate to: `target/idl/`
2. Right-click on `my_program.json`
3. Click **"Download"**
4. Save to your computer (e.g., `~/Downloads/my_program-idl.json`)

**📋 File:** This is your program's Interface Definition Language (IDL)

### File 4: Program ID (Copy from Terminal)

1. Copy the **Program ID** from Playground's deployment output
2. Save in a text file for reference

**Example:**
```
Program ID: AbCdEfGhIjKlMnOpQrStUvWxYz1234567890
```

---

## 🚀 Part 3: Deploy to Analos Mainnet via CLI

### Step 1: Prerequisites

**Check Solana CLI is installed:**
```bash
solana --version
```

**Check deployer wallet:**
```bash
solana address
solana balance
```

**Set Analos network (temporary):**
```bash
solana config set --url https://rpc.analos.io
```

**Check balance (need ~3-5 LOS for deployment):**
```bash
solana balance --url https://rpc.analos.io
```

### Step 2: Fund Program Account (IMPORTANT!)

**Before deploying, fund the program account:**

```bash
# Get program address from keypair
solana address -k ~/Downloads/my_program-keypair.json

# Transfer SOL to program account (typically 1-2 SOL)
solana transfer \
  --from ~/.config/solana/id.json \
  --url https://rpc.analos.io \
  <PROGRAM_ADDRESS_FROM_KEYPAIR> \
  2.0 \
  --allow-unfunded-recipient
```

**Why?** The program account needs SOL for rent exemption and deployment costs.

### Step 3: Deploy Using CLI with Proper Flags

**Use the deployment command with `--use-rpc` flag (or similar):**

```bash
solana program deploy \
  ~/Downloads/my_program.so \
  --url https://rpc.analos.io \
  --keypair ~/.config/solana/id.json \
  --program-id ~/Downloads/my_program-keypair.json \
  --use-rpc
```

**If `--use-rpc` doesn't work, try:**

```bash
solana program deploy \
  ~/Downloads/my_program.so \
  --url https://rpc.analos.io \
  --keypair ~/.config/solana/id.json \
  --program-id ~/Downloads/my_program-keypair.json \
  --commitment confirmed
```

**Alternative (if WebSocket issues):**

```bash
# Set RPC URL as environment variable
export SOLANA_URL=https://rpc.analos.io

# Deploy
solana program deploy \
  ~/Downloads/my_program.so \
  --keypair ~/.config/solana/id.json \
  --program-id ~/Downloads/my_program-keypair.json
```

**Expected Output:**
```
Program Id: AbCdEfGhIjKlMnOpQrStUvWxYz1234567890
Deploying...
Upgrade authority: YOUR_WALLET_ADDRESS
Signature: XyZaBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890...
```

**✅ Deployment successful on Analos mainnet!**

### Step 4: Verify Deployment

```bash
solana program show \
  AbCdEfGhIjKlMnOpQrStUvWxYz1234567890 \
  --url https://rpc.analos.io
```

**Should show:**
```
Program Id: AbCdEfGhIjKlMnOpQrStUvWxYz1234567890
Owner: BPFLoaderUpgradeab1e11111111111111111111111
ProgramData Address: ...
Authority: YOUR_WALLET_ADDRESS
Last Deployed In Slot: ...
Data Length: ~500000 bytes
Balance: ~3.5 SOL
```

---

## 🔧 Using the SDK with This Workflow

### Step 1: Estimate Deployment Cost

```typescript
import { estimateDeploymentCost } from "@analos/launch-sdk";

const cost = estimateDeploymentCost("./Downloads/my_program.so");
console.log(`Estimated cost: ~${cost} SOL`);
```

### Step 2: Generate Deployment Command

```typescript
import { getDeploymentCommand, loadKeypair } from "@analos/launch-sdk";

const command = getDeploymentCommand({
  programPath: "./Downloads/my_program.so",
  programKeypairPath: "./Downloads/my_program-keypair.json",
  deployerKeypair: loadKeypair("~/.config/solana/id.json"),
  rpcUrl: "https://rpc.analos.io",
});

console.log("Run this command:");
console.log(command);
```

### Step 3: Verify Deployment

```typescript
import { verifyProgram, getExplorerUrl } from "@analos/launch-sdk";

const programId = "AbCdEfGhIjKlMnOpQrStUvWxYz1234567890";

const info = await verifyProgram(programId, "https://rpc.analos.io");

if (info.isDeployed && info.isExecutable) {
  console.log("✅ Deployment verified!");
  console.log("Balance:", info.balance, "SOL");
  console.log("Explorer:", getExplorerUrl(programId));
} else {
  console.error("❌ Deployment verification failed");
}
```

---

## 📋 Complete Checklist

### Playground Setup
- [ ] Created project in Solana Playground
- [ ] Copied all program files
- [ ] Generated program ID
- [ ] Updated program ID in code
- [ ] Built program successfully
- [ ] Deployed to devnet

### Download Artifacts
- [ ] Downloaded program binary (`.so` file)
- [ ] Downloaded program keypair (`.json` file) ⚠️ SECRET
- [ ] Downloaded IDL (`.json` file)
- [ ] Copied program ID for reference

### Analos Deployment
- [ ] Funded deployer wallet (need ~3-5 LOS)
- [ ] Funded program account (need ~2 SOL)
- [ ] Generated deployment command (via SDK)
- [ ] Ran deployment command with proper flags
- [ ] Verified deployment on Analos
- [ ] Updated frontend with program ID

---

## 🔧 Troubleshooting

### Issue: "Account has insufficient funds"

**Solution:**
```bash
# Check program account balance
solana balance <PROGRAM_ADDRESS> --url https://rpc.analos.io

# Fund program account
solana transfer \
  --from ~/.config/solana/id.json \
  --url https://rpc.analos.io \
  <PROGRAM_ADDRESS> \
  2.0 \
  --allow-unfunded-recipient
```

### Issue: "WebSocket connection failed"

**Solution:**
Use `--use-rpc` flag or set RPC URL as environment variable:

```bash
export SOLANA_URL=https://rpc.analos.io
solana program deploy ...
```

### Issue: "Program ID mismatch"

**Solution:**
Ensure the program ID in your source code matches the keypair:
```bash
solana address -k ~/Downloads/my_program-keypair.json
```

Then update your source files with this ID.

---

## 🎯 Key Points

1. **Always test on devnet first** - Catch issues before mainnet
2. **Download all artifacts** - Binary, keypair, and IDL are all needed
3. **Fund the program account** - Before deployment
4. **Use proper flags** - `--use-rpc` or environment variables for Analos
5. **Verify deployment** - Always check after deploying
6. **Keep keypair secure** - Never commit to GitHub

---

## 🔄 Updating a Deployed Program

### Option 1: Upgrade Existing Program

If you need to update a deployed program:

```bash
# 1. Build new version in Playground
# 2. Download new .so file
# 3. Deploy using same program ID keypair

solana program deploy \
  my_program_v2.so \
  --url https://rpc.analos.io \
  --keypair ~/.config/solana/id.json \
  --program-id ~/Downloads/my_program-keypair.json \
  --use-rpc
```

**Note:** This upgrades the existing program - the program ID stays the same!

### Option 2: Deploy New Version

If you want to deploy a completely new version with a new ID:

```bash
# 1. Generate new program ID in Playground
# 2. Download new artifacts
# 3. Deploy as new program

solana program deploy \
  my_program_v2.so \
  --url https://rpc.analos.io \
  --keypair ~/.config/solana/id.json \
  --program-id ~/Downloads/my_program_v2-keypair.json \
  --use-rpc
```

**Note:** This creates a new program - you'll need to update all references!

---

## 🔗 Related Guides

- **Solana Playground Guide:** See your project's deployment guides
- **SDK Usage:** See `README.md` for SDK examples
- **Verification:** See `PRODUCTION-DEPLOYMENT-STATUS.md`
- **Enabling Updates:** See `.github/ENABLE-UPDATES-GUIDE.md`

---

**This workflow works for all Analos deployments!** ✅

