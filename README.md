For project requirements see `requirements.md`

## How to install

```
forge install Openzeppelin/openzeppelin-contracts
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
forge install smartcontractkit/chainlink-brownie-contracts
```

## Deployment steps

1. Add the following in `.env` file
```
ADMIN_ADDRESS=
DIRECTOR_ADDRESS=
SEPOLIA_RPC_URL=
ETHERSCAN_API_KEY=
```

2. Add the following in `foundry.toml` file
```
[rpc_endpoints]
sepolia = "${SEPOLIA_RPC_URL}"

[etherscan]
sepolia = { key = "${ETHERSCAN_API_KEY}" }
```

3. Run deploy script

```
$ forge script script/deploy.s.sol:DeployScript --broadcast --verify -vvvv --rpc-url sepolia --private-key <> --etherscan-api-key "${ETHERSCAN_API_KEY}"
```

3. Run verify script if needed

```
$ forge verify-contract <address>  ./src/ScholarshipDispenser.sol:ScholarshipDispenser --chain-id 11155111 --api-key "${ETHERSCAN_API_KEY}"
```

## Generate merkle proofs

```
cd ./js_scripts
npm init --yes
npm i @openzeppelin/merkle-tree
node generateMerkle.js 
```

## Links to contracts

- Factory - 0x54d0Cf6446F282c4E2f22148f7c4B0fBA26DDECb
- Implementation - 0xCE061BfD63d50dD9726278a9e9CE2e9f29AB2c3a
- Proxy clone - 0xe028626acC5E7d8159F95A6a50f3Afe97Bc6ebB5

## Proof of execution
- created dispenser: https://sepolia.etherscan.io/tx/0x517ea3f0ef3794a75c839d09bb95a82d8a8d01a88b0355ce85645c28167f35a2
- director funded dispenser: https://sepolia.etherscan.io/tx/0x970bc25fecde5f0bc3ed8d8cec31164e33c784b9c650140fec4c759f1c820479
- student1 claimed stipend: https://sepolia.etherscan.io/tx/0x893eabb90dfc0c4c7c67d77c6ce8a23f65b5d5b89ec8d2cd9c654420ffd64fd5
- student2 claimed stipend: https://sepolia.etherscan.io/tx/0x0e580f2f535c740e3a9293e9c55574774537d2441be5e72dea76aafa5852b7b7
- director withdrawn leftover balance from dispenser: https://sepolia.etherscan.io/tx/0x6bc0788b66d03f8ebe37691011917fff45dd896910661fbf939b13cd50252294