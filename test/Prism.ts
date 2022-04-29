import { ethers } from 'hardhat'
import chai, { expect } from 'chai'
import { Prism1155, Prism1155__factory } from '../typechain'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signer-with-address'
import { BigNumber } from 'ethers'


let baseURI = 'https://api.fantomflamingos.co'
let collectionMaxInnovcation = BigInt(3)
let collectionPrice = ethers.utils.parseEther('1')
let ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'
let stakeAmount = 100

describe('Prism', () => {
  let nftContract: Prism1155
  let admin: SignerWithAddress
  let firstbuyer: SignerWithAddress
  let secondBuyer: SignerWithAddress

  
  beforeEach(async () => {
    const signers = await ethers.getSigners()
    admin = signers[0]
    firstbuyer = signers[1]
    secondBuyer = signers[2]

    const PrismFactory = (await ethers.getContractFactory(
      'Prism1155',
      admin,
    )) as Prism1155__factory
    nftContract = (await PrismFactory.deploy(
    )) as Prism1155
    
    await nftContract.deployed()
  
  })

  it('query', async () => {
    const tokens = await nftContract.viewTokensOfAddress(admin.address)
    console.log(tokens)

  });


  // it('create collection & token', async () => {
  //   await nftContract.addCollection("Cyberfrens: Cyberpass",collectionPrice,20,1)
  //   await nftContract.addCollection("Cyberfrens: Traits",collectionPrice,55,1)
  //   await nftContract.addCollection("Cyberfrens: Master Avatar",collectionPrice,collectionMaxInnovcation,1)
  //   await nftContract.addTokenToCollection(2,1,[5,15])
  
  //   const collection1 = await nftContract.viewCollectionDetails(1)

  //   expect(collection1.maxInvocations).equal(20) 
  //   expect(await nftContract.viewTokenMaxSupply(1)).equal(5) 
  //   expect(await nftContract.viewTokenMaxSupply(2)).equal(15) 
  // });

  // it('mint Token', async () => {
  //   await nftContract.addCollection("Cyberfrens: Cyberpass",collectionPrice,20,1)
  //   await nftContract.addCollection("Cyberfrens: Traits",collectionPrice,55,1)
  //   await nftContract.addCollection("Cyberfrens: Master Avatar",collectionPrice,collectionMaxInnovcation,1)
  //   await nftContract.addTokenToCollection(1,1,[10])

  //   const collection1 = await nftContract.viewCollectionDetails(1)

  //   expect(collection1.maxInvocations).equal(20) 
  //   expect(await nftContract.viewTokenMaxSupply(1)).equal(10) 

  //   await nftContract.mintTo(admin.address,1,2,1)

  //   expect(await nftContract.totalSupply(1)).equal(2)
  //   expect(await nftContract.balanceOf(admin.address,1)).equal(2)

  // });



})
