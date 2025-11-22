# Analos Deployment Helper Script (PowerShell)
# This script helps deploy programs to Analos with comprehensive error checking

param(
    [Parameter(Mandatory=$true)]
    [string]$ProgramBinaryPath,
    
    [Parameter(Mandatory=$true)]
    [string]$ProgramKeypairPath,
    
    [Parameter(Mandatory=$true)]
    [string]$DeployerKeypairPath,
    
    [string]$RpcUrl = "https://rpc.analos.io",
    
    [decimal]$FundAmount = 3.6,
    
    [switch]$SkipFunding,
    
    [switch]$DryRun,
    
    [switch]$VerifyOnly
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Analos Program Deployment Helper" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$RPC_URL = $RpcUrl
$BINARY_PATH = $ProgramBinaryPath
$PROGRAM_KEYPAIR = $ProgramKeypairPath
$DEPLOYER_KEYPAIR = $DeployerKeypairPath

Write-Host "📋 Configuration:" -ForegroundColor Yellow
Write-Host "  Binary: $BINARY_PATH" -ForegroundColor White
Write-Host "  Program Keypair: $PROGRAM_KEYPAIR" -ForegroundColor White
Write-Host "  Deployer Keypair: $DEPLOYER_KEYPAIR" -ForegroundColor White
Write-Host "  RPC URL: $RPC_URL" -ForegroundColor White
Write-Host ""

# Step 1: Verify files exist
Write-Host "🔍 Step 1: Verifying files..." -ForegroundColor Cyan

if (-not (Test-Path $BINARY_PATH)) {
    Write-Host "  ❌ Binary not found: $BINARY_PATH" -ForegroundColor Red
    exit 1
}
$binarySize = (Get-Item $BINARY_PATH).Length
Write-Host "  ✅ Binary: $BINARY_PATH (${binarySize} bytes)" -ForegroundColor Green

if (-not (Test-Path $PROGRAM_KEYPAIR)) {
    Write-Host "  ❌ Program keypair not found: $PROGRAM_KEYPAIR" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Program keypair: $PROGRAM_KEYPAIR" -ForegroundColor Green

if (-not (Test-Path $DEPLOYER_KEYPAIR)) {
    Write-Host "  ❌ Deployer keypair not found: $DEPLOYER_KEYPAIR" -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Deployer keypair: $DEPLOYER_KEYPAIR" -ForegroundColor Green

Write-Host ""

# Step 2: Get program ID
Write-Host "🔍 Step 2: Getting Program ID..." -ForegroundColor Cyan
try {
    $PROGRAM_ID = solana address -k $PROGRAM_KEYPAIR 2>&1 | Out-String
    $PROGRAM_ID = $PROGRAM_ID.Trim()
    Write-Host "  ✅ Program ID: $PROGRAM_ID" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Failed to get Program ID from keypair" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Check Solana CLI
Write-Host "🔍 Step 3: Checking Solana CLI..." -ForegroundColor Cyan
try {
    $solanaVersion = solana --version 2>&1 | Out-String
    Write-Host "  ✅ Solana CLI: $solanaVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Solana CLI not found!" -ForegroundColor Red
    Write-Host "  Install: https://docs.solana.com/cli/install-solana-cli-tools" -ForegroundColor Yellow
    exit 1
}

# Set RPC URL
Write-Host "  Setting RPC URL to: $RPC_URL" -ForegroundColor White
solana config set --url $RPC_URL 2>&1 | Out-Null
Write-Host ""

# Step 4: Check deployer balance
Write-Host "🔍 Step 4: Checking Deployer Balance..." -ForegroundColor Cyan
try {
    $deployerAddress = solana address -k $DEPLOYER_KEYPAIR 2>&1 | Out-String
    $deployerAddress = $deployerAddress.Trim()
    
    $balanceOutput = solana balance --url $RPC_URL --keypair $DEPLOYER_KEYPAIR 2>&1 | Out-String
    Write-Host "  Deployer Address: $deployerAddress" -ForegroundColor White
    
    if ($balanceOutput -match "(\d+\.?\d*)\s*SOL") {
        $balance = [decimal]$matches[1]
        Write-Host "  Balance: $balance SOL" -ForegroundColor White
        
        if ($balance -lt 2.0) {
            Write-Host "  ⚠️  Warning: Balance may be insufficient (< 2 LOS)" -ForegroundColor Yellow
            Write-Host "  Recommended: 5-10 LOS for deployment" -ForegroundColor Yellow
            if (-not $DryRun) {
                $continue = Read-Host "  Continue anyway? (y/n)"
                if ($continue -ne "y" -and $continue -ne "Y") {
                    exit 1
                }
            }
        } else {
            Write-Host "  ✅ Balance sufficient" -ForegroundColor Green
        }
    } else {
        Write-Host "  ⚠️  Could not parse balance, but continuing..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  Could not check deployer balance: $_" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Check program account
Write-Host "🔍 Step 5: Checking Program Account..." -ForegroundColor Cyan
try {
    $accountInfo = solana account $PROGRAM_ID --url $RPC_URL 2>&1 | Out-String
    
    if ($accountInfo -match "Balance:\s*(\d+)\s*lamports") {
        $lamports = [decimal]$matches[1]
        $balanceSOL = $lamports / 1_000_000_000
        Write-Host "  ✅ Program account exists" -ForegroundColor Green
        Write-Host "  Balance: $balanceSOL SOL ($lamports lamports)" -ForegroundColor White
        
        if ($balanceSOL -lt 2.0 -and -not $SkipFunding) {
            Write-Host "  ⚠️  Program account needs funding" -ForegroundColor Yellow
            Write-Host ""
            
            if (-not $DryRun -and -not $VerifyOnly) {
                Write-Host "💰 Funding Program Account..." -ForegroundColor Cyan
                Write-Host "  Transferring $FundAmount LOS to $PROGRAM_ID..." -ForegroundColor White
                
                try {
                    solana transfer $PROGRAM_ID $FundAmount `
                        --url $RPC_URL `
                        --keypair $DEPLOYER_KEYPAIR `
                        --allow-unfunded-recipient 2>&1 | Out-Null
                    
                    Write-Host "  ✅ Transfer successful!" -ForegroundColor Green
                    Write-Host "  Waiting 5 seconds for confirmation..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 5
                    
                    # Verify new balance
                    $accountInfo = solana account $PROGRAM_ID --url $RPC_URL 2>&1 | Out-String
                    if ($accountInfo -match "Balance:\s*(\d+)\s*lamports") {
                        $newLamports = [decimal]$matches[1]
                        $newBalanceSOL = $newLamports / 1_000_000_000
                        Write-Host "  New Balance: $newBalanceSOL SOL" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "  ❌ Transfer failed: $_" -ForegroundColor Red
                    Write-Host "  Please fund manually: solana transfer $PROGRAM_ID $FundAmount --url $RPC_URL --keypair $DEPLOYER_KEYPAIR --allow-unfunded-recipient" -ForegroundColor Yellow
                    exit 1
                }
            } else {
                Write-Host "  (Skipped - DryRun or VerifyOnly mode)" -ForegroundColor Yellow
                Write-Host "  Manual command:" -ForegroundColor Yellow
                Write-Host "  solana transfer $PROGRAM_ID $FundAmount --url $RPC_URL --keypair $DEPLOYER_KEYPAIR --allow-unfunded-recipient" -ForegroundColor White
            }
        } else {
            Write-Host "  ✅ Program account has sufficient funds" -ForegroundColor Green
        }
    } else {
        Write-Host "  ℹ️  Program account doesn't exist yet (will be created during deployment)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "  ℹ️  Program account doesn't exist yet (will be created during deployment)" -ForegroundColor Cyan
}
Write-Host ""

# Step 6: Verify keypair addresses match
Write-Host "🔍 Step 6: Verifying Keypair Addresses..." -ForegroundColor Cyan
try {
    $programKeypairAddress = solana address -k $PROGRAM_KEYPAIR 2>&1 | Out-String
    $programKeypairAddress = $programKeypairAddress.Trim()
    
    if ($programKeypairAddress -eq $PROGRAM_ID) {
        Write-Host "  ✅ Program ID matches keypair address" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Mismatch detected!" -ForegroundColor Red
        Write-Host "  Program ID: $PROGRAM_ID" -ForegroundColor Red
        Write-Host "  Keypair Address: $programKeypairAddress" -ForegroundColor Red
        Write-Host "  These should match!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "  ⚠️  Could not verify keypair address: $_" -ForegroundColor Yellow
}
Write-Host ""

# Verify only mode
if ($VerifyOnly) {
    Write-Host "✅ Verification Complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Deployment Command:" -ForegroundColor Yellow
    Write-Host "solana program deploy `"$BINARY_PATH`" `" -ForegroundColor White
    Write-Host "  --url $RPC_URL `" -ForegroundColor White
    Write-Host "  --keypair `"$DEPLOYER_KEYPAIR`" `" -ForegroundColor White
    Write-Host "  --program-id `"$PROGRAM_KEYPAIR`" `" -ForegroundColor White
    Write-Host "  --use-rpc `" -ForegroundColor White
    Write-Host "  --max-sign-attempts 100 `" -ForegroundColor White
    Write-Host "  --with-compute-unit-price 1000" -ForegroundColor White
    exit 0
}

# Dry run mode
if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No deployment will occur" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Would execute:" -ForegroundColor Cyan
    Write-Host "solana program deploy `"$BINARY_PATH`" `" -ForegroundColor White
    Write-Host "  --url $RPC_URL `" -ForegroundColor White
    Write-Host "  --keypair `"$DEPLOYER_KEYPAIR`" `" -ForegroundColor White
    Write-Host "  --program-id `"$PROGRAM_KEYPAIR`" `" -ForegroundColor White
    Write-Host "  --use-rpc `" -ForegroundColor White
    Write-Host "  --max-sign-attempts 100 `" -ForegroundColor White
    Write-Host "  --with-compute-unit-price 1000 `" -ForegroundColor White
    Write-Host "  --commitment confirmed" -ForegroundColor White
    exit 0
}

# Step 7: Deploy
Write-Host "🚀 Step 7: Deploying Program..." -ForegroundColor Cyan
Write-Host "  Program ID: $PROGRAM_ID" -ForegroundColor White
Write-Host "  Network: Analos Mainnet" -ForegroundColor White
Write-Host "  Binary: $BINARY_PATH" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "⚠️  DEPLOY TO ANALOS MAINNET? (type 'yes' to confirm)"
if ($confirm -ne "yes") {
    Write-Host "  ❌ Deployment cancelled" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "🚀 Deploying..." -ForegroundColor Cyan
Write-Host "  This may take 1-2 minutes..." -ForegroundColor Yellow
Write-Host ""

# Deploy command
try {
    solana program deploy $BINARY_PATH `
        --url $RPC_URL `
        --keypair $DEPLOYER_KEYPAIR `
        --program-id $PROGRAM_KEYPAIR `
        --use-rpc `
        --max-sign-attempts 100 `
        --with-compute-unit-price 1000 `
        --commitment confirmed

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Deployment successful!" -ForegroundColor Green
        Write-Host ""
        
        # Verify deployment
        Write-Host "🔍 Verifying deployment..." -ForegroundColor Cyan
        solana program show $PROGRAM_ID --url $RPC_URL
        
        Write-Host ""
        Write-Host "✅ Program deployed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Program Details:" -ForegroundColor Yellow
        Write-Host "  Program ID: $PROGRAM_ID" -ForegroundColor White
        Write-Host "  Explorer: https://explorer.analos.io/address/$PROGRAM_ID" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ Deployment failed!" -ForegroundColor Red
        Write-Host "  Check the error messages above" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 Troubleshooting:" -ForegroundColor Yellow
        Write-Host "  1. Check program account balance (may need funding)" -ForegroundColor White
        Write-Host "  2. Verify deployer has sufficient LOS" -ForegroundColor White
        Write-Host "  3. Ensure program ID matches keypair" -ForegroundColor White
        Write-Host "  4. See TROUBLESHOOTING-ANALOS-DEPLOYMENT.md for more help" -ForegroundColor White
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "❌ Deployment error: $_" -ForegroundColor Red
    exit 1
}

