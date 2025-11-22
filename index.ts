/**
 * Analos Launch SDK
 * 
 * TypeScript SDK for deploying and launching programs on Analos blockchain
 * 
 * Features:
 * - Program deployment utilities
 * - Network configuration helpers
 * - RPC connection management
 * - Deployment verification
 * - Common deployment patterns
 */

import {
  Connection,
  PublicKey,
  Keypair,
  Transaction,
  SystemProgram,
  SYSVAR_RENT_PUBKEY,
  LAMPORTS_PER_SOL,
  sendAndConfirmTransaction,
  TransactionInstruction,
} from "@solana/web3.js";
import {
  AnchorProvider,
  Program,
  BN,
  Wallet,
} from "@coral-xyz/anchor";
import * as fs from "fs";
import * as path from "path";

// ===== ANALOS NETWORK CONFIGURATION =====

/**
 * Analos Network Configuration
 */
export const ANALOS_NETWORK = {
  /** Mainnet RPC URL */
  MAINNET_RPC: "https://rpc.analos.io",
  
  /** Mainnet WebSocket URL */
  MAINNET_WS: "wss://rpc.analos.io",
  
  /** Devnet RPC URL (if available) */
  DEVNET_RPC: "https://devnet-rpc.analos.io",
  
  /** Localnet RPC URL */
  LOCALNET_RPC: "http://localhost:8899",
  
  /** Network explorer URLs */
  EXPLORER_MAINNET: "https://explorer.analos.io",
  EXPLORER_SOLANA: "https://explorer.solana.com",
} as const;

/**
 * Default network configuration for Analos
 */
export const DEFAULT_NETWORK = ANALOS_NETWORK.MAINNET_RPC;

/**
 * Create a connection to Analos network
 * 
 * @param rpcUrl - RPC URL (defaults to Analos mainnet)
 * @param commitment - Commitment level (default: "confirmed")
 * @returns Connection instance
 */
export function createAnalosConnection(
  rpcUrl: string = DEFAULT_NETWORK,
  commitment: "processed" | "confirmed" | "finalized" = "confirmed"
): Connection {
  return new Connection(rpcUrl, {
    commitment,
    confirmTransactionInitialTimeout: 60000, // 60 seconds for Analos
  });
}

// ===== PROGRAM DEPLOYMENT =====

/**
 * Deployment configuration
 */
export interface DeploymentConfig {
  /** Program binary file path (.so file) */
  programPath: string;
  
  /** Program keypair file path */
  programKeypairPath: string;
  
  /** Deployer wallet keypair */
  deployerKeypair: Keypair;
  
  /** RPC URL (defaults to Analos mainnet) */
  rpcUrl?: string;
  
  /** Commitment level */
  commitment?: "processed" | "confirmed" | "finalized";
  
  /** Maximum number of retries */
  maxRetries?: number;
  
  /** Use RPC flag (for custom RPCs) */
  useRpc?: boolean;
}

/**
 * Deployment result
 */
export interface DeploymentResult {
  /** Program ID */
  programId: PublicKey;
  
  /** Transaction signature */
  signature: string;
  
  /** Program data account */
  programDataAddress: PublicKey;
  
  /** Program authority */
  authority: PublicKey;
  
  /** Deployment slot */
  slot: number;
  
  /** Explorer URL */
  explorerUrl: string;
}

/**
 * Get deployment command for deploying via Solana CLI
 * 
 * Note: Program deployment is best done via Solana CLI:
 * ```bash
 * solana program deploy <program.so> \
 *   --url https://rpc.analos.io \
 *   --keypair <deployer-keypair.json> \
 *   --program-id <program-keypair.json>
 * ```
 * 
 * This function generates the command string and validates configuration.
 * 
 * @param config - Deployment configuration
 * @returns Deployment command string
 */
export function getDeploymentCommand(config: DeploymentConfig): string {
  const {
    programPath,
    programKeypairPath,
    rpcUrl = DEFAULT_NETWORK,
  } = config;

  if (!fs.existsSync(programPath)) {
    throw new Error(`Program binary not found: ${programPath}`);
  }
  
  if (!fs.existsSync(programKeypairPath)) {
    throw new Error(`Program keypair not found: ${programKeypairPath}`);
  }

  const command = [
    "solana program deploy",
    `"${programPath}"`,
    `--url ${rpcUrl}`,
    `--keypair "${config.deployerKeypair}"`, // Expects path or skip if already configured
    `--program-id "${programKeypairPath}"`,
  ].join(" \\\n  ");

  return command;
}

/**
 * Estimate deployment cost
 * 
 * @param programPath - Path to program binary (.so file)
 * @returns Estimated cost in SOL
 */
export function estimateDeploymentCost(programPath: string): number {
  if (!fs.existsSync(programPath)) {
    throw new Error(`Program binary not found: ${programPath}`);
  }

  const programSize = fs.statSync(programPath).size;
  // ~2 SOL per MB of program size + ~0.5 SOL for rent exemption
  const costPerMB = 2;
  const baseCost = 0.5;
  const sizeInMB = programSize / 1024 / 1024;
  const estimatedCost = (sizeInMB * costPerMB) + baseCost;

  return estimatedCost;
}

// ===== PROGRAM VERIFICATION =====

/**
 * Verify a program is deployed on Analos
 * 
 * @param programId - Program ID to verify
 * @param rpcUrl - RPC URL (defaults to Analos mainnet)
 * @returns Program verification info
 */
export async function verifyProgram(
  programId: PublicKey | string,
  rpcUrl: string = DEFAULT_NETWORK
): Promise<{
  isDeployed: boolean;
  isExecutable: boolean;
  balance: number;
  programDataAddress: PublicKey | null;
  authority: PublicKey | null;
  slot: number | null;
}> {
  const connection = createAnalosConnection(rpcUrl);
  const programPubkey = typeof programId === "string" 
    ? new PublicKey(programId) 
    : programId;

  try {
    const accountInfo = await connection.getAccountInfo(programPubkey);
    
    if (!accountInfo) {
      return {
        isDeployed: false,
        isExecutable: false,
        balance: 0,
        programDataAddress: null,
        authority: null,
        slot: null,
      };
    }

    // For upgradeable programs, get program data address
    let programDataAddress: PublicKey | null = null;
    let authority: PublicKey | null = null;

    if (accountInfo.owner.toString() === "BPFLoaderUpgradeab1e11111111111111111111111") {
      const [programData] = PublicKey.findProgramAddressSync(
        [programPubkey.toBuffer()],
        new PublicKey("BPFLoaderUpgradeab1e11111111111111111111111")
      );
      programDataAddress = programData;
      
      // Try to get authority from program data account
      try {
        const programDataInfo = await connection.getAccountInfo(programData);
        if (programDataInfo) {
          // Authority is typically at bytes 41-73
          const authorityBytes = programDataInfo.data.slice(41, 73);
          authority = new PublicKey(authorityBytes);
        }
      } catch {
        // Ignore errors
      }
    }

    // Get recent blockhash for slot info
    const recentBlockhash = await connection.getLatestBlockhash();
    const slot = recentBlockhash.context.slot;

    return {
      isDeployed: true,
      isExecutable: accountInfo.executable,
      balance: accountInfo.lamports / LAMPORTS_PER_SOL,
      programDataAddress,
      authority,
      slot,
    };
  } catch (error) {
    throw new Error(`Failed to verify program: ${error}`);
  }
}

// ===== PROGRAM UPGRADE =====

/**
 * Get upgrade command for upgrading via Solana CLI
 * 
 * Upgrading uses the same command as deployment:
 * ```bash
 * solana program deploy <program.so> \
 *   --url https://rpc.analos.io \
 *   --keypair <deployer-keypair.json> \
 *   --program-id <program-keypair.json>
 * ```
 * 
 * @param config - Deployment configuration
 * @param currentProgramId - Current program ID (for verification)
 * @returns Upgrade command string
 */
export async function getUpgradeCommand(
  config: DeploymentConfig,
  currentProgramId: PublicKey | string
): Promise<string> {
  const programId = typeof currentProgramId === "string"
    ? new PublicKey(currentProgramId)
    : currentProgramId;

  // Verify program exists and is upgradeable
  const verification = await verifyProgram(programId, config.rpcUrl);
  
  if (!verification.isDeployed) {
    throw new Error("Program not found. Use getDeploymentCommand() for initial deployment.");
  }

  if (!verification.isExecutable) {
    throw new Error("Program is not executable. Cannot upgrade.");
  }

  // Same command as deployment
  return getDeploymentCommand(config);
}

// ===== NETWORK HELPERS =====

/**
 * Get Analos network status
 * 
 * @param rpcUrl - RPC URL (defaults to Analos mainnet)
 * @returns Network status
 */
export async function getNetworkStatus(
  rpcUrl: string = DEFAULT_NETWORK
): Promise<{
  version: string;
  slot: number;
  blockHeight: number;
  health: "ok" | "degraded" | "error";
}> {
  const connection = createAnalosConnection(rpcUrl);
  
  try {
    const version = await connection.getVersion();
    const slot = await connection.getSlot();
    const blockHeight = await connection.getBlockHeight();
    const health = await connection.getHealth();

    return {
      version: version["solana-core"] || "unknown",
      slot,
      blockHeight,
      health: health || "ok",
    };
  } catch (error) {
    return {
      version: "unknown",
      slot: 0,
      blockHeight: 0,
      health: "error",
    };
  }
}

/**
 * Get account balance on Analos
 * 
 * @param address - Account address
 * @param rpcUrl - RPC URL (defaults to Analos mainnet)
 * @returns Balance in SOL
 */
export async function getBalance(
  address: PublicKey | string,
  rpcUrl: string = DEFAULT_NETWORK
): Promise<number> {
  const connection = createAnalosConnection(rpcUrl);
  const pubkey = typeof address === "string" ? new PublicKey(address) : address;
  
  const balance = await connection.getBalance(pubkey);
  return balance / LAMPORTS_PER_SOL;
}

/**
 * Request airdrop on Analos (if devnet/testnet)
 * 
 * @param address - Address to receive airdrop
 * @param amount - Amount in SOL (default: 1)
 * @param rpcUrl - RPC URL
 * @returns Transaction signature
 */
export async function requestAirdrop(
  address: PublicKey | string,
  amount: number = 1,
  rpcUrl: string = DEFAULT_NETWORK
): Promise<string> {
  const connection = createAnalosConnection(rpcUrl);
  const pubkey = typeof address === "string" ? new PublicKey(address) : address;
  
  const amountLamports = amount * LAMPORTS_PER_SOL;
  const signature = await connection.requestAirdrop(pubkey, amountLamports);
  
  await connection.confirmTransaction(signature, "confirmed");
  return signature;
}

// ===== EXPLORER HELPERS =====

/**
 * Get explorer URL for an address on Analos
 * 
 * @param address - Address to view
 * @param useSolanaExplorer - Use Solana Explorer instead of Analos Explorer
 * @returns Explorer URL
 */
export function getExplorerUrl(
  address: PublicKey | string,
  useSolanaExplorer: boolean = false
): string {
  const addressStr = typeof address === "string" ? address : address.toString();
  const baseUrl = useSolanaExplorer
    ? ANALOS_NETWORK.EXPLORER_SOLANA
    : ANALOS_NETWORK.EXPLORER_MAINNET;
  
  return `${baseUrl}/address/${addressStr}`;
}

/**
 * Get transaction explorer URL
 * 
 * @param signature - Transaction signature
 * @param useSolanaExplorer - Use Solana Explorer instead of Analos Explorer
 * @returns Explorer URL
 */
export function getTransactionExplorerUrl(
  signature: string,
  useSolanaExplorer: boolean = false
): string {
  const baseUrl = useSolanaExplorer
    ? ANALOS_NETWORK.EXPLORER_SOLANA
    : ANALOS_NETWORK.EXPLORER_MAINNET;
  
  return `${baseUrl}/tx/${signature}`;
}

// ===== COMMON UTILITIES =====

/**
 * Load keypair from file
 * 
 * @param keypairPath - Path to keypair JSON file
 * @returns Keypair instance
 */
export function loadKeypair(keypairPath: string): Keypair {
  if (!fs.existsSync(keypairPath)) {
    throw new Error(`Keypair file not found: ${keypairPath}`);
  }
  
  const keypairData = JSON.parse(fs.readFileSync(keypairPath, "utf-8"));
  return Keypair.fromSecretKey(Uint8Array.from(keypairData));
}

/**
 * Sleep utility for async operations
 * 
 * @param ms - Milliseconds to sleep
 */
export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// ===== EXPORTS =====

export {
  ANALOS_NETWORK,
  DEFAULT_NETWORK,
  createAnalosConnection,
  getDeploymentCommand,
  getUpgradeCommand,
  estimateDeploymentCost,
  verifyProgram,
  getNetworkStatus,
  getBalance,
  requestAirdrop,
  getExplorerUrl,
  getTransactionExplorerUrl,
  loadKeypair,
  sleep,
};

export default {
  ANALOS_NETWORK,
  DEFAULT_NETWORK,
  createAnalosConnection,
  getDeploymentCommand,
  getUpgradeCommand,
  estimateDeploymentCost,
  verifyProgram,
  getNetworkStatus,
  getBalance,
  requestAirdrop,
  getExplorerUrl,
  getTransactionExplorerUrl,
  loadKeypair,
  sleep,
};

