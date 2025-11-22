#!/bin/bash

# Analos Deployment Helper Script (Bash)
# This script helps deploy programs to Analos with comprehensive error checking

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
RPC_URL="https://rpc.analos.io"
FUND_AMOUNT=3.6
SKIP_FUNDING=false
DRY_RUN=false
VERIFY_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --binary)
            BINARY_PATH="$2"
            shift 2
            ;;
        --program-keypair)
            PROGRAM_KEYPAIR="$2"
            shift 2
            ;;
        --deployer-keypair)
            DEPLOYER_KEYPAIR="$2"
            shift 2
            ;;
        --rpc-url)
            RPC_URL="$2"
            shift 2
            ;;
        --fund-amount)
            FUND_AMOUNT="$2"
            shift 2
            ;;
        --skip-funding)
            SKIP_FUNDING=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verify-only)
            VERIFY_ONLY=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Usage: $0 --binary <path> --program-keypair <path> --deployer-keypair <path> [options]"
            exit 1
            ;;
    esac
done

# Check required arguments
if [ -z "$BINARY_PATH" ] || [ -z "$PROGRAM_KEYPAIR" ] || [ -z "$DEPLOYER_KEYPAIR" ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo "Usage: $0 --binary <path> --program-keypair <path> --deployer-keypair <path> [options]"
    echo ""
    echo "Required:"
    echo "  --binary <path>              Path to program .so file"
    echo "  --program-keypair <path>     Path to program keypair JSON file"
    echo "  --deployer-keypair <path>    Path to deployer keypair JSON file"
    echo ""
    echo "Optional:"
    echo "  --rpc-url <url>              RPC URL (default: https://rpc.analos.io)"
    echo "  --fund-amount <amount>       Amount to fund program account (default: 3.6)"
    echo "  --skip-funding               Skip automatic funding"
    echo "  --dry-run                    Show what would be done without executing"
    echo "  --verify-only                Only verify files and configuration"
    exit 1
fi

echo -e "${CYAN}🚀 Analos Program Deployment Helper${NC}"
echo -e "${CYAN}===================================${NC}"
echo ""

# Step 1: Verify files exist
echo -e "${CYAN}🔍 Step 1: Verifying files...${NC}"

if [ ! -f "$BINARY_PATH" ]; then
    echo -e "${RED}  ❌ Binary not found: $BINARY_PATH${NC}"
    exit 1
fi
BINARY_SIZE=$(wc -c < "$BINARY_PATH")
echo -e "${GREEN}  ✅ Binary: $BINARY_PATH (${BINARY_SIZE} bytes)${NC}"

if [ ! -f "$PROGRAM_KEYPAIR" ]; then
    echo -e "${RED}  ❌ Program keypair not found: $PROGRAM_KEYPAIR${NC}"
    exit 1
fi
echo -e "${GREEN}  ✅ Program keypair: $PROGRAM_KEYPAIR${NC}"

if [ ! -f "$DEPLOYER_KEYPAIR" ]; then
    echo -e "${RED}  ❌ Deployer keypair not found: $DEPLOYER_KEYPAIR${NC}"
    exit 1
fi
echo -e "${GREEN}  ✅ Deployer keypair: $DEPLOYER_KEYPAIR${NC}"

echo ""

# Step 2: Get program ID
echo -e "${CYAN}🔍 Step 2: Getting Program ID...${NC}"
if ! PROGRAM_ID=$(solana address -k "$PROGRAM_KEYPAIR" 2>&1); then
    echo -e "${RED}  ❌ Failed to get Program ID from keypair${NC}"
    exit 1
fi
PROGRAM_ID=$(echo "$PROGRAM_ID" | tr -d '\n\r')
echo -e "${GREEN}  ✅ Program ID: $PROGRAM_ID${NC}"
echo ""

# Step 3: Check Solana CLI
echo -e "${CYAN}🔍 Step 3: Checking Solana CLI...${NC}"
if ! SOLANA_VERSION=$(solana --version 2>&1); then
    echo -e "${RED}  ❌ Solana CLI not found!${NC}"
    echo -e "${YELLOW}  Install: https://docs.solana.com/cli/install-solana-cli-tools${NC}"
    exit 1
fi
echo -e "${GREEN}  ✅ Solana CLI: $SOLANA_VERSION${NC}"

# Set RPC URL
echo "  Setting RPC URL to: $RPC_URL"
solana config set --url "$RPC_URL" > /dev/null 2>&1
echo ""

# Step 4: Check deployer balance
echo -e "${CYAN}🔍 Step 4: Checking Deployer Balance...${NC}"
DEPLOYER_ADDRESS=$(solana address -k "$DEPLOYER_KEYPAIR" 2>&1 | tr -d '\n\r')
echo "  Deployer Address: $DEPLOYER_ADDRESS"

BALANCE_OUTPUT=$(solana balance --url "$RPC_URL" --keypair "$DEPLOYER_KEYPAIR" 2>&1 || echo "Error")
if echo "$BALANCE_OUTPUT" | grep -qE "[0-9]+\.[0-9]* SOL"; then
    BALANCE=$(echo "$BALANCE_OUTPUT" | grep -oE "[0-9]+\.[0-9]*" | head -1)
    echo "  Balance: $BALANCE SOL"
    
    # Check if balance is sufficient (basic check)
    BALANCE_INT=$(echo "$BALANCE" | cut -d. -f1)
    if [ "$BALANCE_INT" -lt 2 ]; then
        echo -e "${YELLOW}  ⚠️  Warning: Balance may be insufficient (< 2 LOS)${NC}"
        echo -e "${YELLOW}  Recommended: 5-10 LOS for deployment${NC}"
        if [ "$DRY_RUN" = false ]; then
            read -p "  Continue anyway? (y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        echo -e "${GREEN}  ✅ Balance sufficient${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠️  Could not parse balance, but continuing...${NC}"
fi
echo ""

# Step 5: Check program account
echo -e "${CYAN}🔍 Step 5: Checking Program Account...${NC}"
if ACCOUNT_INFO=$(solana account "$PROGRAM_ID" --url "$RPC_URL" 2>&1); then
    if echo "$ACCOUNT_INFO" | grep -q "Balance:"; then
        LAMPORTS=$(echo "$ACCOUNT_INFO" | grep -oE "Balance: [0-9]+" | grep -oE "[0-9]+")
        BALANCE_SOL=$(echo "scale=9; $LAMPORTS / 1000000000" | bc)
        echo -e "${GREEN}  ✅ Program account exists${NC}"
        echo "  Balance: $BALANCE_SOL SOL ($LAMPORTS lamports)"
        
        # Check if balance is sufficient
        BALANCE_INT=$(echo "$BALANCE_SOL" | cut -d. -f1)
        if [ "$BALANCE_INT" -lt 2 ] && [ "$SKIP_FUNDING" = false ]; then
            echo -e "${YELLOW}  ⚠️  Program account needs funding${NC}"
            echo ""
            
            if [ "$DRY_RUN" = false ] && [ "$VERIFY_ONLY" = false ]; then
                echo -e "${CYAN}💰 Funding Program Account...${NC}"
                echo "  Transferring $FUND_AMOUNT LOS to $PROGRAM_ID..."
                
                if solana transfer "$PROGRAM_ID" "$FUND_AMOUNT" \
                    --url "$RPC_URL" \
                    --keypair "$DEPLOYER_KEYPAIR" \
                    --allow-unfunded-recipient > /dev/null 2>&1; then
                    
                    echo -e "${GREEN}  ✅ Transfer successful!${NC}"
                    echo -e "${YELLOW}  Waiting 5 seconds for confirmation...${NC}"
                    sleep 5
                    
                    # Verify new balance
                    if NEW_ACCOUNT_INFO=$(solana account "$PROGRAM_ID" --url "$RPC_URL" 2>&1); then
                        if echo "$NEW_ACCOUNT_INFO" | grep -q "Balance:"; then
                            NEW_LAMPORTS=$(echo "$NEW_ACCOUNT_INFO" | grep -oE "Balance: [0-9]+" | grep -oE "[0-9]+")
                            NEW_BALANCE_SOL=$(echo "scale=9; $NEW_LAMPORTS / 1000000000" | bc)
                            echo -e "${GREEN}  New Balance: $NEW_BALANCE_SOL SOL${NC}"
                        fi
                    fi
                else
                    echo -e "${RED}  ❌ Transfer failed${NC}"
                    echo -e "${YELLOW}  Please fund manually: solana transfer $PROGRAM_ID $FUND_AMOUNT --url $RPC_URL --keypair $DEPLOYER_KEYPAIR --allow-unfunded-recipient${NC}"
                    exit 1
                fi
            else
                echo -e "${YELLOW}  (Skipped - DryRun or VerifyOnly mode)${NC}"
                echo -e "${YELLOW}  Manual command:${NC}"
                echo "  solana transfer $PROGRAM_ID $FUND_AMOUNT --url $RPC_URL --keypair $DEPLOYER_KEYPAIR --allow-unfunded-recipient"
            fi
        else
            echo -e "${GREEN}  ✅ Program account has sufficient funds${NC}"
        fi
    fi
else
    echo -e "${CYAN}  ℹ️  Program account doesn't exist yet (will be created during deployment)${NC}"
fi
echo ""

# Step 6: Verify keypair addresses match
echo -e "${CYAN}🔍 Step 6: Verifying Keypair Addresses...${NC}"
PROGRAM_KEYPAIR_ADDRESS=$(solana address -k "$PROGRAM_KEYPAIR" 2>&1 | tr -d '\n\r')
if [ "$PROGRAM_KEYPAIR_ADDRESS" = "$PROGRAM_ID" ]; then
    echo -e "${GREEN}  ✅ Program ID matches keypair address${NC}"
else
    echo -e "${RED}  ❌ Mismatch detected!${NC}"
    echo -e "${RED}  Program ID: $PROGRAM_ID${NC}"
    echo -e "${RED}  Keypair Address: $PROGRAM_KEYPAIR_ADDRESS${NC}"
    echo -e "${RED}  These should match!${NC}"
    exit 1
fi
echo ""

# Verify only mode
if [ "$VERIFY_ONLY" = true ]; then
    echo -e "${GREEN}✅ Verification Complete!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Deployment Command:${NC}"
    echo "solana program deploy \"$BINARY_PATH\" \\"
    echo "  --url $RPC_URL \\"
    echo "  --keypair \"$DEPLOYER_KEYPAIR\" \\"
    echo "  --program-id \"$PROGRAM_KEYPAIR\" \\"
    echo "  --use-rpc \\"
    echo "  --max-sign-attempts 100 \\"
    echo "  --with-compute-unit-price 1000"
    exit 0
fi

# Dry run mode
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No deployment will occur${NC}"
    echo ""
    echo -e "${CYAN}📋 Would execute:${NC}"
    echo "solana program deploy \"$BINARY_PATH\" \\"
    echo "  --url $RPC_URL \\"
    echo "  --keypair \"$DEPLOYER_KEYPAIR\" \\"
    echo "  --program-id \"$PROGRAM_KEYPAIR\" \\"
    echo "  --use-rpc \\"
    echo "  --max-sign-attempts 100 \\"
    echo "  --with-compute-unit-price 1000 \\"
    echo "  --commitment confirmed"
    exit 0
fi

# Step 7: Deploy
echo -e "${CYAN}🚀 Step 7: Deploying Program...${NC}"
echo "  Program ID: $PROGRAM_ID"
echo "  Network: Analos Mainnet"
echo "  Binary: $BINARY_PATH"
echo ""

read -p "⚠️  DEPLOY TO ANALOS MAINNET? (type 'yes' to confirm): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}  ❌ Deployment cancelled${NC}"
    exit 0
fi

echo ""
echo -e "${CYAN}🚀 Deploying...${NC}"
echo -e "${YELLOW}  This may take 1-2 minutes...${NC}"
echo ""

# Deploy command
if solana program deploy "$BINARY_PATH" \
    --url "$RPC_URL" \
    --keypair "$DEPLOYER_KEYPAIR" \
    --program-id "$PROGRAM_KEYPAIR" \
    --use-rpc \
    --max-sign-attempts 100 \
    --with-compute-unit-price 1000 \
    --commitment confirmed; then
    
    echo ""
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo ""
    
    # Verify deployment
    echo -e "${CYAN}🔍 Verifying deployment...${NC}"
    solana program show "$PROGRAM_ID" --url "$RPC_URL"
    
    echo ""
    echo -e "${GREEN}✅ Program deployed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Program Details:${NC}"
    echo "  Program ID: $PROGRAM_ID"
    echo "  Explorer: https://explorer.analos.io/address/$PROGRAM_ID"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Deployment failed!${NC}"
    echo -e "${YELLOW}  Check the error messages above${NC}"
    echo ""
    echo -e "${YELLOW}📋 Troubleshooting:${NC}"
    echo "  1. Check program account balance (may need funding)"
    echo "  2. Verify deployer has sufficient LOS"
    echo "  3. Ensure program ID matches keypair"
    echo "  4. See TROUBLESHOOTING-ANALOS-DEPLOYMENT.md for more help"
    exit 1
fi

