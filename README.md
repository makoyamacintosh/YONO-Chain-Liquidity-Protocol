# YONO-Chain Liquidity Protocol

**Reference Architecture & Educational Prototype**

> ⚠️ **Important Notice**
> This repository contains an **educational, non-production prototype** intended to demonstrate the architectural building blocks of a multi-chain, gasless decentralized exchange (DEX).
>
> The codebase **has not been audited** and **must not be deployed to mainnet** without extensive security reviews, hardened implementations, and production-grade dependencies (e.g. OpenZeppelin, audited AMMs, secure bridge messaging).

---

## Overview

The decentralized finance (DeFi) ecosystem is fragmented across multiple blockchains, liquidity pools, and user experiences. Users must manage different wallets, gas tokens, and bridges, while liquidity providers face capital inefficiency and poor routing across isolated markets.

**YONO-Chain Liquidity Protocol** explores a unified, modular DEX architecture that addresses these challenges by combining:

* **A Universal Router** for flexible, multi-hop execution
* **Cross-chain liquidity abstraction** via wrapped assets
* **Gasless transactions** using meta-transactions and account abstraction

The goal of this repository is to act as a **technical reference and experimentation platform**, not a finished product.

---

## Key Concepts

### Multi-Chain Liquidity

* Support for multiple blockchains (initially EVM-focused)
* Lock & Mint / Burn & Unlock bridging model
* Wrapped asset representations (e.g. wETH, wBTC)
* Cross-chain liquidity pools routed through a single interface

### Universal Routing

* A central Router contract acts as the execution hub
* Routes swaps across multiple pool types
* Emits structured events for cross-chain execution hooks
* Designed to be extensible rather than tightly coupled

### Gasless Transactions

* **EIP-2771 Trusted Forwarder** for meta-transactions
* **ERC-4337 Paymaster** for sponsored gas execution
* Relayer integrations (Gelato, Biconomy, OpenGSN)
* Users sign messages instead of sending on-chain transactions

---

## High-Level Architecture

```
User Wallets
     ↓
Frontend / dApp
     ↓
Universal Router
 ┌───────────────┐
 │ AMM Pools     │
 │ Stable Pools  │
 │ Staking       │
 └───────────────┘
     ↓
Bridge Locker ──► Off-chain Validators / Relayers
     ↓
Wrapped Assets on Destination Chain
```

The system intentionally separates:

* **Execution logic** (on-chain)
* **Routing and composition** (Router)
* **Cross-chain messaging and validation** (off-chain, prototype)

---

## Repository Structure

This repository contains modular Solidity contracts and supporting tooling:

* `contracts/YonoFactory.sol` — Pool and pair creation
* `contracts/YonoPair.sol` — Constant-product AMM (prototype)
* `contracts/StableSwapPool.sol` — Simplified Curve-style pool
* `contracts/YonoRouter.sol` — Universal router with cross-chain hooks
* `contracts/WrappedToken.sol` — Mintable/burnable wrapped asset
* `contracts/WrappedTokenFactory.sol` — Wrapped token deployment
* `contracts/BridgeLocker.sol` — Lock & Mint bridge custody skeleton
* `contracts/TrustedForwarder.sol` — Minimal EIP-2771 forwarder
* `contracts/Paymaster.sol` — Simplified ERC-4337 paymaster stub
* `contracts/FeeCollector.sol` — Protocol fee accounting
* `contracts/Staking.sol` — LP staking skeleton

---

## Trust Model (Prototype)

This codebase makes **explicit trust assumptions** for educational purposes:

* Bridge unlocks are authorized by a trusted admin or validator set
* Off-chain relayers and validators are assumed to be honest
* No cryptographic proof verification is implemented
* Gas sponsorship is centralized

These assumptions are **intentional and documented**, and are planned to be refined in later phases.

---

## Development Phases

### Phase 1 — Research & Architecture (Prototype)

* System design and architectural exploration
* AMM models (constant product, stable swap)

### Phase 2 — Core Smart Contracts (Prototype)

* Factory, pools, and router
* Fee collection and staking logic

### Phase 3 — Cross-Chain & Gasless Infrastructure (Planned)

* Bridge validator design
* Meta-transaction and Paymaster hardening

### Phase 4 — Frontend & Multi-Chain UX (Planned)

* Multi-wallet integration
* Analytics and portfolio views

### Phase 5 — Security & Testnet (Planned)

* External audits
* Fuzzing and invariant testing

### Phase 6 — Mainnet & Governance (Planned)

* Liquidity bootstrapping
* DAO governance transition

---

## Security First

Security-critical primitives are prioritized over UX features. Planned work includes:

* Formal threat modeling
* Adversarial testing (replay, griefing, invariant violations)
* Contract-level audit checklists
* External third-party audits before any production deployment

See:

* [`SECURITY.md`](./SECURITY.md)
* [`THREAT_MODEL.md`](./THREAT_MODEL.md)

---

## Documentation

* [`WHITEPAPER.md`](./WHITEPAPER.md) — Technical architecture and design rationale
* `/docs/architecture.md` — Architecture diagrams and sequence flows (planned)

---

## Disclaimer

This repository is **not investment advice**, **not production software**, and **not a live protocol**. It is a reference implementation intended for learning, experimentation, and collaborative design.

---

## License

MIT License
