import { ethers } from 'hardhat'
import { PrismMinting, PrismProjects } from '../typechain'
import { PrismToken } from '../typechain'
import { readFileSync } from 'fs';
import { join } from 'path';

async function main() {

    let contractProjects: PrismProjects
    let contractTokens: PrismToken
    let contractMinting: PrismMinting

    const [deployer] = await ethers.getSigners();
    console.log("Account balance:", (await deployer.getBalance()).toString());

    const contents = readFileSync(join(__dirname, './address/contractAddresses.json'), 'utf-8');
    console.log(JSON.parse(contents));
    const contractAddresses = JSON.parse(contents)

    // contractProjects = await ethers.getContractAt("PrismProjects", contractAddresses.PrismProjects, deployer) as PrismProjects
    // contractTokens = await ethers.getContractAt("PrismToken", contractAddresses.PrismTokens, deployer) as PrismToken
    contractMinting = await ethers.getContractAt("PrismMinting", contractAddresses.PrismMinting, deployer) as PrismMinting

    await contractMinting.mintRandomBundle(1, { gasLimit: 10000000, gasPrice: 40000000000 })
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
