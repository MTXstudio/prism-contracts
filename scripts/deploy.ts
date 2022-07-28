import { ethers } from 'hardhat'
import { PrismMinting, PrismMinting__factory, PrismProjects, PrismProjects__factory } from '../typechain'
import { PrismToken, PrismToken__factory } from '../typechain'
import { writeFileSync } from 'fs';
import { join } from 'path';

async function main() {

  let contractProjects: PrismProjects
  let contractTokens: PrismToken
  let contractMinting: PrismMinting

  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const PrismProjectFactory = (await ethers.getContractFactory(
    'PrismProjects',
    deployer,
  )) as PrismProjects__factory
  contractProjects = (await PrismProjectFactory.deploy({ gasPrice: 40000000000 }
  )) as PrismProjects
  console.log("Project address:", contractProjects.address);


  // TOKEN contract
  const PrismTokenFactory = (await ethers.getContractFactory(
    'PrismToken',
    deployer,
  )) as PrismToken__factory
  contractTokens = (await PrismTokenFactory.deploy(contractProjects.address, { gasPrice: 40000000000, gasLimit: 10000000 })) as PrismToken
  console.log("Token address:", contractTokens.address);
  await contractTokens.deployed()


  // Minting contract
  const PrismMintingFactory = (await ethers.getContractFactory(
    'PrismMinting',
    deployer,
  )) as PrismMinting__factory
  contractMinting = (await PrismMintingFactory.deploy(1100, { gasPrice: 40000000000 })) as PrismMinting
  console.log("Minting address:", contractMinting.address);
  await contractMinting.deployed()


  const data = {
    "PrismProjects": contractProjects.address,
    "PrismTokens": contractTokens.address,
    "PrismMinting": contractMinting.address
  }
  writeFileSync(join(__dirname, './address/contractAddresses.json'), JSON.stringify(data), {
    flag: 'w',
  });

  // Link Project to Token
  await contractProjects.setPrismTokenContract(contractTokens.address)
  // Link Minting to Token
  await contractMinting.setPrismTokensContract(contractTokens.address)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
