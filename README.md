Crowdfunding Smart Contract (Foundry)

A simple Ethereum crowdfunding smart contract built with Foundry, using OpenZeppelin for security primitives and forge-std for testing.

This repository uses git submodules to manage Solidity dependencies.

Requirements

Make sure you have the following installed:

Git

Foundry (forge, cast, anvil)

Install Foundry if needed:

curl -L https://foundry.paradigm.xyz | bash
foundryup

Getting Started
1️⃣ Clone the repository (IMPORTANT)

This project uses git submodules, so you must clone with:

git clone --recurse-submodules <REPO_URL>


If you already cloned without submodules, run:

git submodule update --init --recursive

2️⃣ Build the project
forge build

3️⃣ Run tests
forge test


For verbose output:

forge test -vv

Project Structure
.
├── src/            # Smart contracts
├── test/           # Foundry tests
├── script/         # Deployment / scripts
├── lib/            # Dependencies (git submodules)
│   ├── forge-std/
│   └── openzeppelin-contracts/
├── foundry.toml
├── foundry.lock
└── README.md

Dependencies

Dependencies are managed via git submodules:

forge-std – Foundry standard library for testing

openzeppelin-contracts – battle-tested security contracts

They are not vendored — the repository tracks exact commit hashes for deterministic builds.

To update dependencies intentionally:

forge install <dependency>


Then commit the updated submodule pointer.

Import Examples

Example OpenZeppelin import (Foundry style):

import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

Development Notes

Solidity version: ^0.8.x

ETH transfers use call

Reentrancy protection via ReentrancyGuard

Follows Checks → Effects → Interactions (CEI) pattern

Common Issues
❌ Compilation error: submodule not found

Make sure submodules are initialized:

git submodule update --init --recursive

Team Workflow (Recommended)

Pull latest changes:

git pull
git submodule update --init --recursive


Build & test locally:

forge build
forge test


When updating dependencies:

Update submodule

Commit .gitmodules, foundry.lock, and submodule pointer

License

MIT