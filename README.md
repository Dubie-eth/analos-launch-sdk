# @analos/launch-sdk

[![npm version](https://img.shields.io/npm/v/@analos/launch-sdk.svg)](https://www.npmjs.com/package/@analos/launch-sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://www.typescriptlang.org/)

TypeScript SDK for deploying and launching programs on Analos blockchain.

## 🚀 Features

- ✅ **Network Configuration** - Pre-configured Analos network settings
- ✅ **Connection Management** - Optimized connections for Analos RPC
- ✅ **Deployment Commands** - Generate Solana CLI deployment commands
- ✅ **Program Verification** - Verify program deployment status
- ✅ **Cost Estimation** - Estimate deployment costs before deploying
- ✅ **Network Monitoring** - Check network health and status
- ✅ **Explorer Integration** - Generate explorer URLs easily
- ✅ **Balance Checking** - Get account balances
- ✅ **Utility Functions** - Helper functions for common tasks

## Installation

```bash
npm install @analos/launch-sdk
```

---

## 🔧 Troubleshooting Deployment Issues

Having trouble deploying to Analos? Check out our comprehensive troubleshooting guide:

- **[TROUBLESHOOTING-ANALOS-DEPLOYMENT.md](./TROUBLESHOOTING-ANALOS-DEPLOYMENT.md)** - Common errors and solutions
- **[QUICK-DEPLOY-GUIDE.md](./QUICK-DEPLOY-GUIDE.md)** - Step-by-step deployment instructions

**Quick Helper Scripts:**
- **Windows PowerShell:** `deploy-to-analos.ps1`
- **Linux/Mac Bash:** `deploy-to-analos.sh`

These scripts automatically:
- ✅ Verify all files exist and are valid
- ✅ Check deployer and program account balances
- ✅ Fund program account if needed
- ✅ Verify program ID matches keypair
- ✅ Deploy with correct flags for Analos

**Usage Example:**
```powershell
# Windows PowerShell
.\deploy-to-analos.ps1 `
  -ProgramBinaryPath "C:\path\to\program.so" `
  -ProgramKeypairPath "C:\path\to\program-keypair.json" `
  -DeployerKeypairPath "C:\path\to\deployer-keypair.json" `
  -FundAmount 3.6

# Linux/Mac Bash
./deploy-to-analos.sh \
  --binary /path/to/program.so \
  --program-keypair /path/to/program-keypair.json \
  --deployer-keypair /path/to/deployer-keypair.json \
  --fund-amount 3.6
```

**Verify-only mode (test without deploying):**
```powershell
# Windows
.\deploy-to-analos.ps1 -ProgramBinaryPath "..." -ProgramKeypairPath "..." -DeployerKeypairPath "..." -VerifyOnly

# Linux/Mac
./deploy-to-analos.sh --binary "..." --program-keypair "..." --deployer-keypair "..." --verify-only
```

---

## Quick Start

### Get Deployment Command

```typescript
import { getDeploymentCommand, estimateDeploymentCost } from "@analos/launch-sdk";

// Estimate deployment cost
const cost = estimateDeploymentCost("./target/deploy/my_program.so");
console.log("Estimated cost:", cost, "SOL");

// Generate deployment command for Solana CLI
const command = getDeploymentCommand({
  programPath: "./target/deploy/my_program.so",
  programKeypairPath: "./target/deploy/my_program-keypair.json",
  deployerKeypair: loadKeypair("./deployer-keypair.json"),
  rpcUrl: "https://rpc.analos.io",
});

console.log("Deployment command:");
console.log(command);

// Then run the command in your terminal:
// solana program deploy "./target/deploy/my_program.so" \
//   --url https://rpc.analos.io \
//   --keypair "./deployer-keypair.json" \
//   --program-id "./target/deploy/my_program-keypair.json"
```

### Verify Program

```typescript
import { verifyProgram } from "@analos/launch-sdk";

const info = await verifyProgram(
  "45zq1B5o8PC2gYzyy5iX14cQMA5NpmQK8poNLKx8owVA"
);

console.log("Deployed:", info.isDeployed);
console.log("Balance:", info.balance, "SOL");
```

### Create Connection

```typescript
import { createAnalosConnection } from "@analos/launch-sdk";

const connection = createAnalosConnection("https://rpc.analos.io");
```

### Check Network Status

```typescript
import { getNetworkStatus } from "@analos/launch-sdk";

const status = await getNetworkStatus();
console.log("Network health:", status.health);
console.log("Current slot:", status.slot);
```

## Features

- ✅ **Program Deployment** - Deploy Anchor/Solana programs to Analos
- ✅ **Program Verification** - Verify program deployment status
- ✅ **Program Upgrade** - Upgrade existing programs
- ✅ **Network Configuration** - Pre-configured Analos network settings
- ✅ **Connection Management** - Optimized connections for Analos
- ✅ **Explorer Integration** - Generate explorer URLs
- ✅ **Balance Checking** - Check account balances
- ✅ **Network Status** - Monitor network health

## API Reference

### Network Configuration

#### `ANALOS_NETWORK`

Analos network constants:

```typescript
import { ANALOS_NETWORK } from "@analos/launch-sdk";

console.log(ANALOS_NETWORK.MAINNET_RPC);
// "https://rpc.analos.io"

console.log(ANALOS_NETWORK.EXPLORER_MAINNET);
// "https://explorer.analos.io"
```

#### `createAnalosConnection(rpcUrl?, commitment?)`

Create a connection optimized for Analos:

```typescript
import { createAnalosConnection } from "@analos/launch-sdk";

const connection = createAnalosConnection();
// Uses https://rpc.analos.io by default

const connection2 = createAnalosConnection(
  "https://custom-rpc.analos.io",
  "confirmed"
);
```

### Program Deployment

#### `getDeploymentCommand(config)`

Generate deployment command for Solana CLI:

```typescript
import { getDeploymentCommand, DeploymentConfig } from "@analos/launch-sdk";
import { loadKeypair } from "@analos/launch-sdk";

const config: DeploymentConfig = {
  programPath: "./target/deploy/my_program.so",
  programKeypairPath: "./target/deploy/my_program-keypair.json",
  deployerKeypair: loadKeypair("./deployer-keypair.json"),
  rpcUrl: "https://rpc.analos.io",
};

const command = getDeploymentCommand(config);
console.log("Run this command:");
console.log(command);
```

**Returns:** Deployment command string for Solana CLI

#### `estimateDeploymentCost(programPath)`

Estimate deployment cost:

```typescript
import { estimateDeploymentCost } from "@analos/launch-sdk";

const cost = estimateDeploymentCost("./target/deploy/my_program.so");
console.log("Estimated cost:", cost, "SOL");
// Output: Estimated cost: 2.5 SOL
```

#### `getUpgradeCommand(config, currentProgramId)`

Get upgrade command (same as deployment, but verifies program exists):

### Program Verification

#### `verifyProgram(programId, rpcUrl?)`

Verify a program's deployment status:

```typescript
import { verifyProgram } from "@analos/launch-sdk";

const info = await verifyProgram(
  "45zq1B5o8PC2gYzyy5iX14cQMA5NpmQK8poNLKx8owVA"
);

if (info.isDeployed && info.isExecutable) {
  console.log("Program is deployed and executable");
  console.log("Balance:", info.balance, "SOL");
  console.log("Authority:", info.authority?.toString());
}
```

**Returns:**
- `isDeployed` - Whether program account exists
- `isExecutable` - Whether program is executable
- `balance` - Program balance in SOL
- `programDataAddress` - Program data account (if upgradeable)
- `authority` - Program authority
- `slot` - Last known slot

### Network Utilities

#### `getNetworkStatus(rpcUrl?)`

Get network status:

```typescript
import { getNetworkStatus } from "@analos/launch-sdk";

const status = await getNetworkStatus();

console.log("Health:", status.health); // "ok" | "degraded" | "error"
console.log("Slot:", status.slot);
console.log("Version:", status.version);
```

#### `getBalance(address, rpcUrl?)`

Get account balance:

```typescript
import { getBalance } from "@analos/launch-sdk";

const balance = await getBalance(
  "86oK6fa5mKWEAQuZpR6W1wVKajKu7ZpDBa7L2M3RMhpW"
);

console.log("Balance:", balance, "SOL");
```

#### `requestAirdrop(address, amount?, rpcUrl?)`

Request airdrop (devnet/testnet only):

```typescript
import { requestAirdrop } from "@analos/launch-sdk";

const signature = await requestAirdrop(
  keypair.publicKey,
  1 // 1 SOL
);
```

### Explorer Helpers

#### `getExplorerUrl(address, useSolanaExplorer?)`

Get explorer URL for an address:

```typescript
import { getExplorerUrl } from "@analos/launch-sdk";

const url = getExplorerUrl(
  "45zq1B5o8PC2gYzyy5iX14cQMA5NpmQK8poNLKx8owVA"
);
// https://explorer.analos.io/address/45zq1B5o8PC2gYzyy5iX14cQMA5NpmQK8poNLKx8owVA

const solanaUrl = getExplorerUrl(address, true);
// https://explorer.solana.com/address/...?cluster=custom&customUrl=https://rpc.analos.io
```

#### `getTransactionExplorerUrl(signature, useSolanaExplorer?)`

Get explorer URL for a transaction:

```typescript
import { getTransactionExplorerUrl } from "@analos/launch-sdk";

const url = getTransactionExplorerUrl(signature);
// https://explorer.analos.io/tx/...
```

### Utility Functions

#### `loadKeypair(keypairPath)`

Load keypair from JSON file:

```typescript
import { loadKeypair } from "@analos/launch-sdk";

const keypair = loadKeypair("./deployer-keypair.json");
```

#### `sleep(ms)`

Sleep utility:

```typescript
import { sleep } from "@analos/launch-sdk";

await sleep(5000); // Wait 5 seconds
```

## Examples

### Complete Deployment Flow

```typescript
import {
  getDeploymentCommand,
  estimateDeploymentCost,
  verifyProgram,
  getBalance,
  getExplorerUrl,
  loadKeypair,
} from "@analos/launch-sdk";
import { execSync } from "child_process";

async function deployMyProgram() {
  // 1. Load deployer keypair
  const deployerKeypair = loadKeypair("./deployer-keypair.json");
  
  // 2. Estimate cost
  const cost = estimateDeploymentCost("./target/deploy/my_program.so");
  console.log("Estimated cost:", cost, "SOL");
  
  // 3. Check balance
  const balance = await getBalance(deployerKeypair.publicKey);
  console.log("Deployer balance:", balance, "SOL");
  
  if (balance < cost) {
    throw new Error(`Insufficient balance. Need ~${cost} SOL, have ${balance} SOL`);
  }
  
  // 4. Get deployment command
  const command = getDeploymentCommand({
    programPath: "./target/deploy/my_program.so",
    programKeypairPath: "./target/deploy/my_program-keypair.json",
    deployerKeypair,
    rpcUrl: "https://rpc.analos.io",
  });
  
  console.log("Deployment command:");
  console.log(command);
  
  // 5. Deploy via Solana CLI (optional - can also run manually)
  console.log("Deploying program...");
  const output = execSync(command, { encoding: "utf-8" });
  console.log(output);
  
  // 6. Extract program ID from output (or get from keypair)
  const programKeypair = loadKeypair("./target/deploy/my_program-keypair.json");
  const programId = programKeypair.publicKey;
  
  // 7. Verify deployment
  console.log("Verifying deployment...");
  const verification = await verifyProgram(programId);
  
  if (verification.isDeployed && verification.isExecutable) {
    console.log("✅ Deployment successful!");
    console.log("Program ID:", programId.toString());
    console.log("Explorer:", getExplorerUrl(programId));
    console.log("Balance:", verification.balance, "SOL");
  } else {
    throw new Error("Deployment verification failed");
  }
  
  return { programId, verification };
}
```

### Monitor Program Deployment

```typescript
import { verifyProgram, sleep } from "@analos/launch-sdk";

async function waitForDeployment(programId: string, maxAttempts = 10) {
  for (let i = 0; i < maxAttempts; i++) {
    const info = await verifyProgram(programId);
    
    if (info.isDeployed && info.isExecutable) {
      console.log("✅ Program is deployed!");
      return true;
    }
    
    console.log(`Attempt ${i + 1}/${maxAttempts}: Waiting for deployment...`);
    await sleep(5000); // Wait 5 seconds
  }
  
  throw new Error("Deployment timeout");
}
```

## Network Information

### Analos Mainnet

- **RPC URL:** `https://rpc.analos.io`
- **Explorer:** `https://explorer.analos.io`
- **Chain ID:** Analos
- **Native Token:** LOS

### Common Program IDs

- **NFT Escrow:** `45zq1B5o8PC2gYzyy5iX14cQMA5NpmQK8poNLKx8owVA`
- **NFT Launchpad Core:** `H423wLPdU2ut7JBJmq7Y9V6whXVTtHyRY3wvqypwfgfm`

## Troubleshooting

### Deployment Fails

1. **Check RPC endpoint** - Ensure `https://rpc.analos.io` is accessible
2. **Verify balance** - Need ~2 SOL per MB of program size
3. **Check keypair** - Ensure keypair file is valid JSON
4. **Network issues** - Try increasing `maxRetries` in config

### Program Not Found

- Verify program ID is correct
- Check network (mainnet vs devnet)
- Ensure program was deployed to Analos (not Solana mainnet)

### Connection Timeout

- Increase `confirmTransactionInitialTimeout` in connection config
- Use `commitment: "confirmed"` instead of `"finalized"`
- Check RPC endpoint health

## 📜 License

MIT - See [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## 🔗 Links

- **GitHub Repository:** [github.com/analos/analos-launch-sdk](https://github.com/analos/analos-launch-sdk)
- **npm Package:** [npmjs.com/package/@analos/launch-sdk](https://www.npmjs.com/package/@analos/launch-sdk)
- **Documentation:** See README.md (this file)
- **Analos Network:** [analos.io](https://analos.io)

## 📧 Support

- **GitHub Issues:** [github.com/analos/analos-launch-sdk/issues](https://github.com/analos/analos-launch-sdk/issues)
- **Discord:** [Analos Community](https://discord.gg/analos)

## ⭐ Star the Repo

If this SDK is helpful, please star the repository on GitHub!

## 🙏 Acknowledgments

Built for the Analos blockchain ecosystem.

## Support

- **GitHub:** https://github.com/analos/analos-nft-launchpad
- **Issues:** https://github.com/analos/analos-nft-launchpad/issues

## 📚 Additional Documentation

### Deployment Workflow

For a complete step-by-step guide on deploying programs to Analos:

**See: [`DEPLOYMENT-WORKFLOW.md`](DEPLOYMENT-WORKFLOW.md)**

This guide covers:
- ✅ Building and testing in Solana Playground (devnet)
- ✅ Downloading artifacts (binary, keypair, IDL)
- ✅ Deploying to Analos mainnet via CLI
- ✅ Using proper flags (`--use-rpc`) that work for Analos
- ✅ Verification and troubleshooting

### Quick Deployment Workflow

**1. Build in Playground:**
- Upload code to https://beta.solpg.io
- Generate program ID
- Build and deploy to devnet

**2. Download Artifacts:**
- Download `.so` file (binary)
- Download `-keypair.json` file (program keypair) ⚠️ SECRET
- Download IDL `.json` file

**3. Deploy to Analos:**
```bash
solana program deploy \
  my_program.so \
  --url https://rpc.analos.io \
  --keypair ~/.config/solana/id.json \
  --program-id my_program-keypair.json \
  --use-rpc
```

**4. Verify:**
```typescript
import { verifyProgram } from "@analos/launch-sdk";
const info = await verifyProgram(programId, "https://rpc.analos.io");
```

## Related Packages

- `@analos/nft-escrow-sdk` - NFT Escrow program SDK
- `@analos/dynamic-bonding-curve-sdk` - Dynamic bonding curve SDK

