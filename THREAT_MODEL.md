# YONO-Chain Liquidity Protocol — Threat Model

**Status:** Draft v1.0 (STRIDE-style, DeFi-adapted)

This document defines the formal threat model for the YONO-Chain Liquidity Protocol. It identifies assets, trust assumptions, adversaries, attack surfaces, and mitigations across on-chain and off-chain components, with a focus on cross-chain bridging and gasless execution.

---

## 1. Scope & Methodology

**In Scope**

* Universal Router
* AMM Pools (V2, V3-style, StableSwap)
* Cross-Chain Bridge (Lock & Mint / Burn & Unlock)
* Wrapped Token Factory
* Gasless Infrastructure (Trusted Forwarder, Paymaster, Relayers)
* Validator / Relayer off-chain services

**Out of Scope (Explicit)**

* Underlying L1/L2 consensus failures
* Wallet provider compromises (MetaMask, Phantom, etc.)
* Oracle provider insolvency (assumed honest-but-failable)

**Methodology**

* STRIDE categories adapted for DeFi:

  * Spoofing → Identity / authority forgery
  * Tampering → State or value manipulation
  * Repudiation → Dispute of actions / replay ambiguity
  * Information Disclosure → Leakage of sensitive operational data
  * Denial of Service → Liveness and griefing attacks
  * Elevation of Privilege → Unauthorized control of protocol actions

---

## 2. Assets to Protect

| Asset                 | Description                              | Impact if Compromised   |
| --------------------- | ---------------------------------------- | ----------------------- |
| User Funds            | Tokens in pools, bridge vaults, gas tank | Catastrophic            |
| Wrapped Tokens        | Cross-chain representations              | Systemic insolvency     |
| Router Authority      | Routing + execution logic                | Arbitrary fund movement |
| Bridge Validator Keys | Mint/burn authority                      | Infinite mint / theft   |
| Paymaster Funds       | Gas subsidy pool                         | Protocol insolvency     |
| Protocol State        | Pool reserves, accounting                | Market manipulation     |

---

## 3. Trust Assumptions

1. **Validators** are threshold-secured (m-of-n) and economically incentivized.
2. **Relayers** are permissionless but rate-limited and economically bounded.
3. **Oracles** may fail or lag but cannot arbitrarily lie without detection.
4. **Users** may be malicious, adversarial, or automated.
5. **Smart contracts** are immutable post-deployment (unless explicitly upgradeable).

Violations of these assumptions define catastrophic failure modes.

---

## 4. Adversary Model

### 4.1 Adversary Classes

* **External Attacker**: No privileges, arbitrary contract interaction.
* **Malicious User**: Valid signer attempting griefing, replay, or extraction.
* **Compromised Relayer**: Can censor, reorder, or spam meta-txs.
* **Malicious Validator Subset**: < threshold attempting equivocation.
* **Fully Compromised Validator Set**: Worst-case bridge failure.
* **MEV Searcher / Block Builder**: Reordering, sandwiching, censorship.

### 4.2 Capabilities

* Unlimited transaction submission
* Front-running / back-running
* Cross-chain message replay
* Signature harvesting
* Partial key compromise

---

## 5. System Decomposition & Attack Surfaces

### 5.1 Universal Router

**Attack Surface**

* External call composition
* Slippage and path manipulation
* Reentrancy via pool hooks

**STRIDE Analysis**

* Spoofing: Fake caller via forwarder misconfiguration
* Tampering: Malicious pool address injection
* DoS: Path explosion / gas exhaustion
* Elevation: Bypassing access checks in delegated calls

**Mitigations**

* Strict allowlists for pools and bridges
* Reentrancy guards
* Deterministic call ordering
* Explicit calldata size limits

---

### 5.2 AMM Pools

**Attack Surface**

* Reserve accounting
* Price oracle dependency
* Flash loan composability

**STRIDE Analysis**

* Tampering: Reserve skew via flash loans
* Information Disclosure: Oracle leakage enabling MEV
* DoS: Pool imbalance griefing

**Mitigations**

* TWAP enforcement
* Virtual reserves / amplification factors
* Flash-loan-aware pricing

---

### 5.3 Cross-Chain Bridge

**Attack Surface**

* Lock contracts
* Mint authority
* Message verification
* Deposit ID generation

**STRIDE Analysis**

* Spoofing: Forged validator signatures
* Tampering: Double-mint via replayed messages
* Repudiation: Ambiguous deposit finality
* Elevation: Validator key compromise

**Mitigations**

* Domain-separated EIP-712 signed messages
* Unique, monotonic deposit nonces
* On-chain replay protection (consumed deposit IDs)
* Threshold signatures + time-delay minting

**Catastrophic Failure Mode**

* ≥ threshold validator compromise ⇒ bridge insolvency

---

### 5.4 Wrapped Token Factory

**Attack Surface**

* Mint / burn logic
* Metadata binding to canonical asset

**STRIDE Analysis**

* Tampering: Mismatched asset mapping
* Elevation: Unauthorized mint/burn

**Mitigations**

* Immutable canonical asset registry
* Bridge-only mint/burn modifiers
* Supply invariant checks

---

### 5.5 Gasless Infrastructure

#### Trusted Forwarder (EIP-2771)

**Threats**

* Spoofing: Fake forwarder injection
* Replay: Reused signed meta-transactions

**Mitigations**

* Single trusted forwarder address
* Per-user nonce tracking
* Domain-separated signatures

#### Paymaster (ERC-4337)

**Threats**

* DoS: Gas tank draining
* Tampering: Sponsored call abuse
* Elevation: Arbitrary call sponsorship

**Mitigations**

* Per-user and per-function gas caps
* Allowlisted target contracts
* Rate limiting + budget epochs

---

### 5.6 Relayer Network (Off-chain)

**Threats**

* Censorship
* Reordering for MEV
* Spam amplification

**Mitigations**

* Multiple relayer providers
* User fallback to direct tx
* Deterministic request hashing

---

## 6. Cross-Cutting Threats

### Replay Attacks

* Cross-chain message reuse
* Meta-tx signature reuse

**Mitigation**: Nonces, chain IDs, domain separation

### Griefing Attacks

* Forcing protocol to pay gas
* Pool imbalance without profit

**Mitigation**: Economic bounds, revert-on-loss logic

### MEV Extraction

* Sandwiching swaps
* Cross-chain latency arbitrage

**Mitigation**: Slippage bounds, batch auctions (future)

---

## 7. Residual Risk & Open Problems

* Trust-minimized bridges remain unsolved at scale
* Validator collusion risk cannot be eliminated
* Gas sponsorship creates unavoidable griefing surface
* Cross-chain finality mismatches introduce latency risk

These risks are acknowledged and accepted at this stage.

---

## 8. Security Invariants (Audit Checklist Seed)

* Total wrapped supply ≤ locked canonical assets
* Each deposit ID is consumed exactly once
* Router cannot transfer funds without explicit user intent
* Paymaster cannot sponsor arbitrary external calls
* No state-changing external calls before validation

---

## 9. Conclusion

This threat model frames YONO as a **high-composability, high-responsibility** DeFi system. The protocol prioritizes explicit trust boundaries, layered mitigations, and auditability over implicit security assumptions. All future implementations and audits MUST reference this document as a baseline.
