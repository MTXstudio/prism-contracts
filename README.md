## Architecture 

Polygon enables the decentralised storage of ownership records for traits (ERC1155 - semi-fungible tokens) as well as the parent NFT. The parent NFT inherits the metadata from the combination of traits. The metadata connected to the traits and parent NFT are stored in tableland. Tableland enables imutable storage for trait metadata and mutable storage of parent NFT metadata. The images for all traits are stored on IPFS.


## Components

Prism is using a number of open source and commercial projects to enable the service

/// DLT & Testing Compontents
- Polygon - Decentralised Ledger for storing fungible and non-fungible tokens 
- ERC-1155 - Token Standard combining fungible and non-fungible tokens
- Hardhat - Ethereum development environment.
- Typescript - Strongly Typed JS
- Typechain - TS Types for Solidity Smart Contracts
- Node - JS runtime

/// Data Querying and Availability 
- Tableland - Mutable and Immutable Metadata storage in SQL Tables  
- TheGraph - Accessing blockchain events (To be build and added to Repo)
- IPFS - Decentralised storage network used of artworks and trait images

/// Front-end components
- Next JS
- React JS
- Tailwind CSS
- Web3 modal





## Tech

Cyberfrens  uses a number of open source projects to work properly:

- Hardhat - Ethereum development environment.
- Typescript - Strongly Typed JS
- Typechain - TS Types for Solidity Smart Contracts
- Node - JS runtime


## Installation

Cyberfrens Smart Contracts requires [Node.js](https://nodejs.org/) v10+ to run.

Install the dependencies and devDependencies and start the server.

yarn install


## Deployed Contracts

| Contract Name | Chain | Address |

| Prism Contract | Polygon Mumbai Testnet | 0xEb8A104180CF136c28E89928510c56Ca4909510c


## Development
Running All tests
```sh
npx hardhat test
```

Running Specific tests with network
```sh
npx hardhat test ./test/contract --network
```
#### Comiling Contracts 
```sh
npx hardhat compile
```

### Extra Hardhat features 
```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.ts
TS_NODE_FILES=true npx ts-node scripts/deploy.ts
npx eslint '**/*.{js,ts}'
npx eslint '**/*.{js,ts}' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```
[//]: # 
   [node.js]: <http://nodejs.org>

