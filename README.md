# YONO-Chain Liquidity Protocol

**Reference Architecture & Prototype**

> ⚠️ **Important Notice**  
> This repository contains an **educational, non-production prototype** intended to demonstrate the architectural building blocks of a multi-chain, gasless decentralized exchange (DEX).  
> The codebase **has not been audited** and **must not be deployed to mainnet** without extensive security reviews, hardened implementations, and production-grade dependencies (e.g. OpenZeppelin, audited AMMs, secure bridge messaging).

---

## Why still build / explore this in 2026?

In 2026, chain abstraction and intent-centric execution (via solvers, fillers, and networks like 1inch Fusion, CoW Swap, Across, or NEAR Intents) have become dominant for real user-facing cross-chain DeFi UX. Native account abstraction on major L2s has made gas sponsorship common and cheap.

Yet this prototype remains valuable as:

- A **teaching tool** to deeply understand modular DEX internals (factories, routers, pools, wrappers) before treating them as black boxes.
- A **reference playground** for experimenting with AMM curves, fee mechanisms, or composability patterns in a controlled EVM environment.
- A starting point for teams building chain-specific forks, app-chains, or hybrid systems that still need on-chain execution primitives.

It bridges classic DeFi building blocks (Uniswap V2/V3 DNA + stable swaps + meta-tx) with modern concepts — while being explicit about where it diverges from today's solver-heavy reality.

---

## Overview

The DeFi ecosystem remains fragmented across chains, despite major progress in interoperability and abstraction. Users still face wallet/chain management friction in many contexts, and liquidity providers deal with inefficient capital allocation across isolated pools.

**YONO-Chain Liquidity Protocol** is an educational exploration of a unified, modular DEX architecture that combines:

- **A Universal Router** for flexible multi-hop execution (on-chain reference implementation)
- **Cross-chain liquidity abstraction** via wrapped assets and basic bridging
- **Gasless transactions** using meta-transactions and account abstraction (EIP-2771 + ERC-4337 stubs)

The goal is purely **technical reference, learning, and experimentation** — not a production protocol or competitor to intent/solver networks.

---

## Key Concepts

### Multi-Chain Liquidity

- EVM-focused chains (expandable)
- Lock & Mint / Burn & Unlock bridging model (prototype skeleton)
- Wrapped asset representations (e.g. wETH, wBTC)
- Cross-chain pools routed through a single interface (on-chain router focus for education)

### Universal Routing

- Central Router contract as execution hub
- Routes across multiple pool types (constant-product, stable)
- Emits events for potential cross-chain hooks
- Extensible design — intentionally on-chain to teach composition (contrast with 2026 off-chain solver dominance)

### Gasless Transactions

- EIP-2771 Trusted Forwarder for meta-transactions
- ERC-4337 Paymaster stub for sponsored execution
- Relayer compatibility (Gelato, Biconomy, OpenGSN patterns)
- Users sign messages — educational demo (note: many L2s now offer native/cheap gasless natively)

---

## High-Level Architecture

```mermaid
graph TD
    A[User Wallet<br>(any chain)] --> B[Frontend / dApp]
    B --> C[Signs UserOp / Meta-Tx]
    C --> D[Universal Router on Source Chain]
    D --> E[Local AMM Pools<br>(Constant Product / Stable)]
    D --> F[BridgeLocker: Lock Tokens<br>+ Emit Event]
    F --> G[Off-chain Relayers / Validators<br>(trusted in prototype)]
    G --> H[Destination Chain: Mint Wrapped Assets]
    H --> I[Router on Dest Chain: Execute Swap / Hook]
    I --> J[User receives result]
