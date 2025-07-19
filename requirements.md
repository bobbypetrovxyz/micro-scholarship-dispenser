## Micro‑Scholarship Dispenser

The university wants to distribute tiny “pocket‑money” scholarships - about 5 USD worth of ETH - to every verified student in a department. An admin factory deploys a lightweight ScholarshipDispenser clone for each department. The director uploads a Merkle root of approved student wallets for every department instance.. Each student may claim their one‑off stipend by submitting a Merkle proof. When a claim is made, the clone queries the Chainlink ETH/USD feed to convert the USD stipend into the exact amount of wei and transfers it. Claim amounts are deliberately small, so live Sepolia demos cost < 0.002 ETH per transaction.

### Project Structure
Students may use Foundry only, or Foundry + Hardhat project setup. OpenZeppelin or similar libraries are allowed.

## Detailed Business and Technical Requirements

### System Overview
-	ScholarshipFactory stores the implementation address and exposes createDispenser(...) which returns a freshly cloned proxy.
-	ScholarshipDispenser holds:
-	director – department director who funds and can withdraw leftover ETH.
-	merkleRoot – immutable allow‑list root.
-	usdStipendCents – stipend expressed in USD cents (e.g. 500 = $5.00).
-	priceFeed – Chainlink AggregatorV3Interface (ETH/USD).
-	tracks if a wallet has taken its stipend.

### Lifecycle & User Journeys
1.	Factory Deployment
-	Admin deploys factory
-	 The implementation address is set once.
2.	Create ScholarshipDispenser proxy instance
-	 Director calls createDispenser(root, stipendCents, feed) on factory.
-	 Clone is initialised
3.	Funding
-	Director transfers enough ETH to the clone to cover all stipends.
4.	Stipend Issuance (off-chain)
-	Director generates the Merkle tree, including all students eligible for the scholarship off-chain.
5.	Stipend Claim
-	Student submits merke proof.
-	Contract verifies proof.
-	Calculates weiAmount based on latest ETH/USD price.
-	Transfer Wei amount to the student’s address

### Roles & Permissions
1.	Director – Creates and funds the dispenser, can withdraw the leftover.
2.	Student – Any address included in the Merkle tree; can claim once.
3.	Factory admin – Deploys the factory and sets the director address

### Key Business Rules
-	Single claim per address – enforced via claimed mapping.
-	Price freshness – Contract trusts the latest round; no staleness check required for exam.
-	Small value – USD stipend must be ≤ 5 USD so one claim costs under 0.002 ETH on Sepolia.
-	Transparency – Emit events for dispenser creation and every scholarship payment

### Simplified Assumptions
1.	One‑time claim – Each address may withdraw its stipend once; no recurring periods.
2.	Fixed stipend – USD amount per department is set during clone initialize() and never changes.
3.	Immutable allow‑list – The Merkle root cannot be updated after deployment.
4.	ETH/USD feed – Default to the canonical Sepolia ETH/USD feed.
5.	No refund logic – Excess ETH left in a clone can be withdrawn by the department director. (You can dedicate a method for this)

## General Requirements

### Authorization (Merkle tree)
Use a Merkle-tree allow-list to restrict who can claim the stipend.
A script for generating the Merkle tree and proofs must be included in the project submission.
The script should generate a merkle_data.json file containing:
The Merkle root
An array of test students, each with their corresponding Merkle proof
The merkle_data.json file must be included in the final submission.
Use this data to test the contract on Sepolia.

### Proxies
Minimal-proxy factory creating independent ScholarshipDispenser instances.

### Oracles
Chainlink price feed queried inside each stipend claim.
Proper Implementation of Key Business Requirements & Roles
Your solution must fully adhere to the described business logic and roles

## Other Requirements
### Manual testing on Sepolia
Proof you’ve manually tested all key steps of the process by adding deployment addresses and executed transaction info in the README.md file (More info in the Project Submission section).
Security and Gas Optimization
Apply the security principles and gas optimization techniques covered in the course.
Project Submission
Submit a .zip of the entire Foundry/Hardhat project, excluding node_modules, coverage, artifacts, cache, out, and the lib folder. If libraries (in lib folder as submodules)  other than:
- forge-std
- OpenZeppelin/openzeppelin-contracts-upgradeable
- Openzeppelin/openzeppelin-contracts
- smartcontractkit/chainlink-brownie-contracts
have to be installed, specify in the README.md under the Additional Packages category.
Include a README.md in the root project directory explaining:
●	How to install and run tests (if any)
●	The deployment and verification steps
●	The verified contract links on Etherscan, together with Etherscan links for at least one transaction for every important business step.

### Assessment Criteria
1. General Requirements (70%)
2. Other Requirements (30%)

Deliver a clone‑based Micro‑Scholarship system that lets each whitelisted student redeem a USD‑pegged stipend in ETH, converted live via Chainlink. Keep payments tiny, prove it with a Foundry test and a Sepolia demo, and write clear, secure code. Good luck!

### Hints
If you want to test your contract locally, use a mocked Data Feed implementation to simulate Chainlink DataFeed behavior.
