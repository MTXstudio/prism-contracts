import { ethers } from 'hardhat'
import chai, { expect } from 'chai'
import chaiAsPromised from 'chai-as-promised'
import { PinkFlamingoSocialClub, PinkFlamingoSocialClub__factory } from '../typechain'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signer-with-address'

describe('Pink Flamingo Social Club', () => {
  let contract: PinkFlamingoSocialClub
  let admin: SignerWithAddress
  let buyer: SignerWithAddress
  let secondBuyer: SignerWithAddress
  let router: SignerWithAddress
  let collectionPrice = ethers.utils.parseEther('50')
  let maxMint = 2
  let baseURI = 'https://api.fantomglamingos.co'

  beforeEach(async () => {
    const signers = await ethers.getSigners()
    admin = signers[0]
    buyer = signers[1]
    secondBuyer = signers[2]
    router = signers[3]

    const contractFactory = (await ethers.getContractFactory(
      'PinkFlamingoSocialClub',
      admin,
    )) as PinkFlamingoSocialClub__factory
    contract = (await contractFactory.deploy(
      'PinkFlamingoSocialClub',
      'PFSC',
      router.address,
      maxMint,
      collectionPrice,
    )) as PinkFlamingoSocialClub
  })

  it('can mint flamingo', async () => {
    await contract.pauseMint({ from: admin.address })
    await contract.mintFalmingoTo(buyer.address, { value: collectionPrice })
    const balanceOfBuyer = await contract.balanceOf(buyer.address)
    expect(balanceOfBuyer.toNumber()).equal(1)
  })

  it('should get correct token URI', async () => {
    await contract.addBaseURI(baseURI)
    await contract.pauseMint({ from: admin.address })
    await contract.mintFalmingoTo(buyer.address, { value: collectionPrice })
    const expectedURI = baseURI + '/nfts/' + '1'
    const tokenURI = await contract.tokenURI(1)
    expect(tokenURI).equal(expectedURI)
  })

  it('should be able to bridge from router', async () => {
    await contract.pauseMint({ from: admin.address })
    await contract.mintFalmingoTo(buyer.address, { value: collectionPrice })
    await contract.mintFalmingoTo(buyer.address, { value: collectionPrice })
    await contract
      .connect(router)
      ['safeTransferFrom(address,address,uint256)'](router.address, buyer.address, 3)
    await contract
      .connect(router)
      ['safeTransferFrom(address,address,uint256)'](router.address, buyer.address, 4)

    const balanceOfBuyer = await contract.balanceOf(buyer.address)
    expect(balanceOfBuyer.toNumber()).equal(4)
  })

  it('should fail if value is lower than tokenPrice', async () => {
    await contract.pauseMint({ from: admin.address })
    expect(
      contract
        .connect(buyer)
        .mintFalmingoTo(buyer.address, { value: ethers.utils.parseEther('49') }),
    ).to.revertedWith('Must send at least current price for token')
  })

  it('should fail if over maxMint', async () => {
    await contract.pauseMint({ from: admin.address })
    await contract.mintFalmingoTo(buyer.address, { value: collectionPrice })
    await contract.mintFalmingoTo(buyer.address, { value: collectionPrice })
    expect(contract.mintFalmingoTo(buyer.address, { value: collectionPrice })).to.revertedWith(
      'Must not exceed maximum mint on Fantom',
    )
  })
  it('should fail if paused', async () => {
    expect(contract.mintFalmingoTo(buyer.address, { value: collectionPrice })).to.revertedWith(
      'Purchases must not be paused',
    )
  })
})
