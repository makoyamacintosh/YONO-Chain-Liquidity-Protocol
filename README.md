YONO-Chain Liquidity Protocol — Reference Prototype

A reference/prototype implementation and technical blueprint for the YONO-Chain Liquidity Protocol: a multi‑chain DEX architecture combining a Universal Router, gasless transaction infrastructure (meta‑transactions / account abstraction), and cross‑chain bridging. This repository contains an educational Hardhat-based Solidity prototype that demonstrates the core building blocks: Factory / Pair AMM, StableSwap-like pool, wrapped token factory, router with cross‑chain hooks, a bridge locker skeleton, and minimal gasless forwarder/paymaster primitives.

> WARNING: This codebase is an educational prototype — NOT production-ready. Do NOT deploy to mainnet without audits, gas optimizations, and production-grade libraries (OpenZeppelin, audited AMM implementations, audited paymaster & account abstraction logic, secure bridge validator set, etc).

Table of contents
- Project overview
- Key features (prototype)
- High-level architecture
- Contracts included
- Quickstart — Run locally
- Development workflow
- Roadmap & Milestones (what we leave to implement step-by-step)
- Security & audit checklist
- Contribution guide
- License & contact

Project overview
YONO aims to reduce liquidity fragmentation and UX friction by:
- Unifying liquidity across chains via wrapped assets and bridge hooks
- Lowering UX friction with gasless meta‑transactions (Trusted Forwarder + Paymaster stubs)
- Supporting multiple pool types (constant‑product and stable pools)
- Providing a Universal Router capable of multi-hop and cross‑chain swap orchestration (prototype single‑chain with cross‑chain event hooks)

This repository is intentionally modular so each piece (AMM, router, bridge, paymaster) can be iterated independently and replaced with production-grade implementations later.

Key features (prototype)
- UniswapV2-style constant-product pair (YonoPair) with LP tokens
- Simplified Curve-style StableSwap pool (StableSwapPool) demonstrating amplification concept
- YonoFactory for pair/pool creation
- YonoRouter (universal router) for routing single‑chain swaps and emitting cross‑chain bridge events
- WrappedTokenFactory and WrappedToken for cross-chain asset representations
- BridgeLocker skeleton implementing Lock & Mint primitives (events for off‑chain validators)
- Minimal TrustedForwarder and Paymaster stubs to prototype gasless flows
- FeeCollector and simple Staking/LP staking skeleton
- Hardhat project skeleton with deploy script & example relayer snippet

High-level architecture
- User Layer: wallets (MetaMask, Phantom, WalletConnect), gasless UX option
- Frontend: builds swap/bridge/meta-tx payloads; aggregates oracles
- Smart Contracts (EVM prototype): Registry, Factory, Pairs, Pools, Router, Wrapped Token Factory, BridgeLocker, Trusted Forwarder, Paymaster, FeeCollector, Staking
- Cross‑Chain Layer (off‑chain): validator/relayer network that watches Lock events and mints wrapped tokens on destination chains (this repo emits the events — validator infra is out of scope here)
- External Services: oracles (Chainlink/Pyth), indexing (The Graph), relayers (Gelato/Biconomy/OpenGSN) — integration examples and adapters are left to the roadmap

Contracts included (brief)
- contracts/ERC20Mock.sol — test/dev token
- contracts/WrappedToken.sol — mintable/burnable wrapped asset
- contracts/WrappedTokenFactory.sol — creates wrapped tokens
- contracts/MultiCurrencyRegistry.sol — token metadata registry
- contracts/YonoFactory.sol — pair/pool factory
- contracts/YonoPair.sol — UniswapV2-style pair AMM (prototype)
- contracts/StableSwapPool.sol — simplified Curve-like stable pool
- contracts/YonoRouter.sol — universal router with cross-chain hook
- contracts/BridgeLocker.sol — lock & mint skeleton (events)
- contracts/TrustedForwarder.sol — minimal EIP-2771 forwarder
- contracts/Paymaster.sol — simplified paymaster skeleton
- contracts/FeeCollector.sol — protocol fee collection & gas subsidy interface
- contracts/Staking.sol — LP staking skeleton

Quickstart — run prototype locally
Prerequisites
- Node.js >= 16
- npm or yarn
- npx (Hardhat shipped via devDependency)

Install
1. Clone this repository
   git clone <repo-url>
   cd yono-protocol

2. Install dependencies
   npm install

Compile & run local node
1. Start Hardhat node (separate terminal)
   npx hardhat node

2. Deploy contracts locally
   npx hardhat run scripts/deploy.ts --network localhost

Run tests
- Add tests to the `test/` folder and run:
  npm test
  or
  npx hardhat test

Development workflow
- Branching: feature branches per milestone (e.g., feat/paymaster, feat/bridge-validator)
- Tests: write unit tests for every contract, integration tests for router+pair+fee flows
- Linting & formatting: use prettier / solidity-linter as added later
- CI: configure GitHub Actions to run solidity-coverage, unit tests, slither/static analysis (in roadmap)

Example relayer (meta-tx)
- A short TypeScript relayer snippet is provided under `relayer/` demonstrating a TrustedForwarder.forward() invocation.
- In practice integrate Biconomy/Gelato/OpenGSN or implement an authenticated relayer set with replay protection & signature verification.

Roadmap & Milestones (planned — we will treat these as the development plan)
We keep the full high-level roadmap here and we will convert each milestone into issues and tasks as we proceed. The initial prototype covers Phase 1 and Phase 2 basics. The remaining items are left as milestones to achieve iteratively.

Phase 1 — Research & Core Architecture (Done / prototype)
- Finalize whitepaper & system design (completed as v1.0 spec)
- Select initial chains for PoC (EVM chains first)
- Prototype AMM algorithms (constant-product and simplified stable swap)

Phase 2 — Core Smart Contract Development (Prototype present; extend)
- Harden and complete Factory & Pair contracts
- Router: implement multi-hop routing, path parsing, multi‑pool routing logic
- Staking & Yield Farming: add reward distribution & governance token stubs
- Deliverables:
  - Complete unit tests for pair/pool functionality
  - Documentation/specs for Router path format and fee model

Phase 3 — Cross‑Chain & Gasless Infrastructure (Milestone)
- Implement Lock & Mint bridge with validator design (multi-sig / threshold signatures)
- Integrate LayerZero/Wormhole or design custom messaging for proofs
- Full EIP‑2771 TrustedForwarder (OpenZeppelin) integration
- ERC‑4337 Paymaster implementation & UserOperation flows
- Deliverables:
  - Validator relay service prototype (watcher + signer)
  - Paymaster economic model & tests
  - Meta‑tx UX examples

Phase 4 — Frontend & Multi‑Chain Integration (Milestone)
- Build React + TypeScript dApp with:
  - Multi‑chain wallet connectors (MetaMask, WalletConnect, Phantom)
  - Gasless UX option (signature flow + relayer integration)
  - Price aggregator (Chainlink/Pyth fallback)
  - Analytics dashboard & TheGraph integration
- Deliverables:
  - Frontend integration tests (e2e) and UI/UX polish

Phase 5 — Security, Audits & Testnet Launch (Milestone)
- External security audits (CertiK / OpenZeppelin)
- Extensive fuzzing & formal checks (Slither, Echidna where applicable)
- Public testnet launch with incentivized bug bounty
- Deliverables:
  - Audit reports & post-audit remediation
  - Production deployment checklist

Phase 6 — Mainnet Launch & Liquidity Bootstrapping (Milestone)
- Gradual chain rollout (Ethereum L1 → selected Layer2 → other EVM chains → non-EVM)
- Liquidity bootstrapping & initial incentives
- Governance DAO transition (multi-sig / timelock)
- Deliverables:
  - Governance contracts & proposal flow
  - Liquidity incentives & staking emissions schedule

Security & audit checklist (high-level)
- Replace prototype ERC20/transfer patterns with OpenZeppelin SafeERC20
- Add reentrancy protection (ReentrancyGuard) for all external state-changing functions
- Input validation on all public functions (slippage checks, amount > 0, path sanity)
- Use deterministic deployments where needed (create2 / proxies)
- Harden bridge: multi-sig validator set, slashing conditions, monitoring & circuit breakers
- Paymaster safety: deposit/reimburse proofs, replay protection, per-account allowance limits
- Thorough unit, integration, and fuzz testing of AMM invariant properties
- Third‑party external security audit before any production deployment

How we will manage milestones (high level)
- Convert each Phase into GitHub Milestones and Issues
- Each Milestone contains:
  - Architecture design tasks (diagrams, sequence flows)
  - Contract implementation tasks
  - Unit & integration tests
  - CI & release tasks
  - Docs & deployment scripts
- Prioritization principle: security-critical primitives first (Factory/Pair/Router correctness), then UX and cross‑chain integrations.

Contribution guide
- Fork → branch → open PR to `main`
- Signed commits encouraged
- Add unit tests for any new contract behavior
- Follow the repository's code style (to be added: prettier, solidity fmt)
- Open issues for design discussions before implementing large changes

Issue/PR templates & labels (to add)
- bug, enhancement, design-discussion, security, audit, docs, test
- Each PR should reference the milestone and include test coverage details

License
- This prototype is released under the MIT License. (Add license file to the repo)

Contact & governance
- Lead architect / maintainer: makoyamacintosh (GitHub: @makoyamacintosh)
- Security disclosures: create a security@ yono domain / or use GitHub private security advisories (to be configured)
- For enterprise / auditor engagement, please open an issue labeled `security` or `audit` with contact details.

