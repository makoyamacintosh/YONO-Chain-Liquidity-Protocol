# YONO-Chain Liquidity Protocol

> ⚠️ Educational prototype only. Not audited. Do not custody real funds.

## Overview

YONO-Chain is a modular, multi-chain educational DEX architecture with:

- AMM pools (x*y=k)
- Composable router
- FeeCollector & treasury
- Gasless UX via Paymaster
- Lock/Mint Bridge with off-chain relayer events

This repo is **testnet-ready** using Hardhat.

---

## Getting Started

### Requirements

- Node.js 20+
- npm 10+
- Hardhat 2.14+
- Ethers.js 6+
- OpenZeppelin Contracts 5+

### Installation

```bash
git clone <repo-url>
cd yono-chain-protocol
npm install
npx hardhat compile
