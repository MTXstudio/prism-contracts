
## Tech

Cyberfrens  uses a number of open source projects to work properly:

- Hardhat - Ethereum development environment.
- Typescript - Strongly Typed JS
- Typechain - TS Types for Solidity Smart Contracts
- Node - JS runtime


## Installation

Cyberfrens Smart Contracts requires [Node.js](https://nodejs.org/) v10+ to run.

Install the dependencies and devDependencies and start the server.

```sh
cd Redacted-Smart-Contracts
yarn install
```


## Deployed Contracts

| Contract Name | Address |



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

