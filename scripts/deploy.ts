import { ethers } from 'hardhat'
import { PrismMinting, PrismMinting__factory, PrismProjects, PrismProjects__factory } from '../typechain'
import { PrismToken, PrismToken__factory } from '../typechain'
import { writeFileSync } from 'fs';
import { join } from 'path';

async function main() {

  let contractProjects: PrismProjects
  let contractTokens: PrismToken
  let contractMinting: PrismMinting

  let tokenPrice = ethers.utils.parseEther('1')
  let maxInvocations = 900
  let royalties = 5
  let tokenName = ["LayerName1", "LayerName2"]
  let tokenCID = ["", ""]
  let tokenDescription = ["D1", "D2"]
  let tokenPrices = [tokenPrice, tokenPrice]
  let tokenCollection = [1, 2]
  let tokenMaxSupplies = [100, 200]
  let layerCategory = ["Category1", "Category2"]
  let assetType = [0, 1]
  let tokenAttributesName = [["name"], ["name"]];
  let tokenAttributesValue = [["value"], ["value"]];

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

  // Create 1 Project
  await contractProjects.createProject("Cyberfrens", "Project Description", deployer.address, ["Category1", "Category2", "Category2"])
  // Create Canvas collection
  await contractProjects.createCollection("Cyberfrens: Original Canvas", "Collection Description", maxInvocations, 1, deployer.address, 0, royalties)
  // Create Layer collection
  await contractProjects.createCollection("Cyberfrens: Original Layers", "Collection Description", maxInvocations, 1, deployer.address, 1, royalties)
  // Create 1 Layer Token in Layer collection
  await contractTokens.createToken("tokenName", "tokenDescription", 1, 'tokenCID', ["name", "name", "name", "name", "name", "name"], ["value", "value", "value", "value", "value", "value"], 1, 1, "head", 0, { gasLimit: 10000000 })
  // Create batch of Layer tokens + Canvas tokens in Canvas and Layer collections
  await contractTokens.createBatchTokens(tokenName, tokenDescription, tokenPrices, tokenCID, tokenAttributesName, tokenAttributesValue, tokenCollection, tokenMaxSupplies, layerCategory, assetType, { gasLimit: 10000000 })
  //Add token bundles to Minting contract
  await contractMinting.setProjectIdToBundles(1, [[1, 2, 3], [2, 2, 3], [3, 3, 3, 3]], { gasLimit: 10000000, gasPrice: 40000000000 })
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
