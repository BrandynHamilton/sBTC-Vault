# Multi-Signature Wallet Smart Contract

This smart contract is a secure multi-signature wallet implemented in the Clarity programming language for the Stacks blockchain. It allows multiple owners to collaboratively approve and execute transactions, ensuring enhanced security and shared control over funds.

---

## Features

- **Multi-Signature Support**: Requires a minimum number of owner approvals before executing a transaction.
- **Proposals**: Owners can propose transactions specifying the recipient and the amount.
- **Signatures**: Owners can sign proposals, ensuring consensus is reached before funds are transferred.
- **Execution**: Automatically executes the transaction once the required number of signatures is collected.
- **Security**: Includes checks to prevent unauthorized access, duplicate signatures, or re-execution of transactions.

---

## Smart Contract Structure

### Constants
Error codes used for assertions and validations:
- `ERR-NOT-OWNER (u1)`: The caller is not an authorized owner.
- `ERR-INSUFFICIENT-SIGNATURES (u2)`: Proposal lacks the required number of signatures.
- `ERR-PROPOSAL-NOT-FOUND (u3)`: The specified proposal does not exist.
- `ERR-ALREADY-SIGNED (u4)`: The owner has already signed the proposal.
- `ERR-TRANSACTION-ALREADY-EXECUTED (u5)`: The transaction has already been executed.
- `ERR-TRANSACTION-FAILED (u6)`: The STX transfer failed.

### Data Structures
- **Owners**: A map of wallet owners (`principal -> bool`).
- **Proposals**: A map storing proposals with:
  - `signatures`: List of owner signatures.
  - `executed`: Boolean indicating if the transaction is executed.
  - `to`: Recipient of the transaction.
  - `amount`: Amount of STX to transfer.

### Variables
- `next-proposal-id`: Counter for unique proposal IDs.
- `required-signatures`: Number of owner signatures required to execute a transaction.

---

## Public Functions

### `initialize-wallet (wallet-owners (list 10 principal), min-signatures uint) -> (response bool uint)`
Initializes the wallet by:
1. Adding the specified owners.
2. Setting the minimum required signatures.

### `propose-transaction (to principal, amount uint) -> (response uint uint)`
Creates a new transaction proposal. Only wallet owners can propose.

### `sign-proposal (proposal-id uint) -> (response bool uint)`
Allows owners to sign a proposal. If the required signatures are met, the transaction is executed.

---

## Private Functions

### `set-owner (owner principal) -> bool`
Adds an owner to the owners' map.

### `is-owner (sender principal) -> bool`
Checks if the caller is a wallet owner.

### `execute-transaction (proposal-id uint) -> bool`
Executes the transaction once it has sufficient signatures.

---

## Read-Only Functions

### `get-proposal-recipient (proposal-id uint) -> (optional principal)`
Returns the recipient of the specified proposal.

### `get-proposal-amount (proposal-id uint) -> (optional uint)`
Returns the amount specified in the proposal.

### `get-proposal-signatures (proposal-id uint) -> (optional (list 10 principal))`
Returns the list of signatures for a proposal.

### `get-proposal-executed-status (proposal-id uint) -> (optional bool)`
Checks if a proposal has been executed.

---

## How It Works

1. **Initialize the Wallet**: Use `initialize-wallet` to set up the wallet owners and the minimum signatures required for transaction approval.
2. **Propose a Transaction**: Owners can propose transactions by specifying the recipient and the amount using `propose-transaction`.
3. **Sign a Proposal**: Other owners review and sign the proposal using `sign-proposal`.
4. **Execute the Transaction**: Once the required number of signatures is collected, the contract automatically executes the transaction and transfers STX to the recipient.

---

## Error Handling
The contract ensures robustness with various error checks, such as verifying ownership, preventing duplicate signatures, and ensuring proposals exist before execution.

---

## Limitations
- A maximum of 10 owners is supported (`list 10 principal`).
- Signatures are capped at 10 per proposal.

---

## Deployment and Usage

### Prerequisites
- Clarity development environment (e.g., Stacks CLI or a Clarity IDE).
- Wallet for deploying the contract and funding transactions.

### Steps
1. Deploy the contract using your preferred Clarity tool.
2. Call `initialize-wallet` to set up the wallet.
3. Use the provided public functions to propose, sign, and execute transactions.

---

## License
This project is open-source and available under the [MIT License](LICENSE).
