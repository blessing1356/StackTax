# StackTax Smart Contract

A Clarity smart contract for the Stacks blockchain that implements FIFO-based capital gains tax calculations for token transactions.

## Overview

StackTax provides a decentralized solution for tracking and calculating capital gains taxes on cryptocurrency transactions using the First-In-First-Out (FIFO) accounting method.

## Features

- Transaction recording with FIFO ordering
- Configurable tax rate with admin controls
- Automated capital gains calculations
- Tax reporting functionality
- Transaction history tracking

## Contract Functions

### Administrative Functions

```clarity
(define-public (set-tax-rate (new-rate uint))
```
- Sets the tax rate percentage (restricted to contract owner)
- Returns: (ok uint) with new rate or (err uint) if unauthorized

### Transaction Management

```clarity
(define-public (record-transaction (tx-type (string-ascii 8)) (amount uint) (price uint))
```
- Records buy/sell/transfer transactions
- Parameters:
  - tx-type: "buy", "sell", or "transfer"
  - amount: number of tokens
  - price: price per token in microSTX
- Returns: (ok uint) with transaction ID

### Read-Only Functions

```clarity
(define-read-only (get-transaction (user principal) (tx-id uint))
(define-read-only (calculate-capital-gains (user principal))
(define-read-only (get-tax-owed (user principal))
(define-read-only (generate-report (user principal))
```

## Data Structures

### Transactions Map
```clarity
{
  type: (string-ascii 10),    
  amount: uint,               
  price: uint,                
  timestamp: uint             
}
```



## Usage Example

```clarity
;; Set tax rate (15%)
(contract-call? .stack-tax set-tax-rate u15)

;; Record a buy transaction
(contract-call? .stack-tax record-transaction "buy" u100 u1000)

;; Generate tax report
(contract-call? .stack-tax generate-report tx-sender)
```

## Testing

Run the test suite using Clarinet:
```bash
clarinet test
```
