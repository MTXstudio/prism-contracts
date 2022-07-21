import { ethers } from 'hardhat'
import chai, { expect } from 'chai'
import { PrismProjects, PrismProjects__factory } from '../typechain'
import { PrismToken, PrismToken__factory } from '../typechain'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signer-with-address'
import { BigNumber } from 'ethers'
import { arrayify } from 'ethers/lib/utils'


let baseURI = 'https://api.fantomflamingos.co'
let collectionMaxInnovcation = BigInt(3)
let tokenPrice = ethers.utils.parseEther('1')
let maxInvocations = 900
let royalties = 5
let customRoyalties = 10
let ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'
let tokenName = ["Original Head 1","Original Head 1","Original Body 2"]
let tokenCID = ["","",""]
let tokenDescription = ["D1","D2","D3"]
let tokenPrices = [tokenPrice,tokenPrice,tokenPrice]
let tokenCollection = [1,2,3]
let tokenMaxSupplies = [100,200,300]
let tokenTraits = ["head","head","body"]
let tokenAsset = [0,0,0]
let tokenAttributesName = [["name"], ["name"], ["name"]];
let tokenAttributesValue = [["value"], ["value"], ["value"]];

describe('Prism', () => {
  let nftProjects: PrismProjects
  let nftTokens: PrismToken
  let admin: SignerWithAddress
  let projectChef: SignerWithAddress
  let collectionManager: SignerWithAddress
  let firstbuyer: SignerWithAddress
  let secondBuyer: SignerWithAddress

  
  beforeEach(async () => {
    const signers = await ethers.getSigners()
    admin = signers[0]
    projectChef = signers[1]
    collectionManager = signers[2]
    secondBuyer = signers[3]

    const PrismProjectFactory = (await ethers.getContractFactory(
      'PrismProjects',
      admin,
    )) as PrismProjects__factory
    nftProjects = (await PrismProjectFactory.deploy(
    )) as PrismProjects
    
    await nftProjects.deployed()

    const PrismTokenFactory = (await ethers.getContractFactory(
      'PrismToken',
      admin,
    )) as PrismToken__factory
    nftTokens = (await PrismTokenFactory.deploy(nftProjects.address
    )) as PrismToken
    
    await nftTokens.deployed()
    await nftProjects.setPrismTokenContract(nftTokens.address)

    await nftProjects.createProject("Cyberfrens", "Project Description", projectChef.address,["armor","head","body"])
    await nftProjects.createCollection("Cyberfrens: Original Layers", "Collection Description", maxInvocations,1, collectionManager.address,1, royalties)
    await nftProjects.createCollection("Cyberfrens: Original Canvas", "Collection Description", maxInvocations,1, collectionManager.address,0, royalties)
    await nftTokens.createBatchTokens(tokenName, tokenDescription, tokenPrices, tokenCID, tokenAttributesName, tokenAttributesValue, tokenCollection,tokenMaxSupplies,tokenTraits,tokenAsset)
    await nftTokens.createToken("tokenName", "tokenDescription", 1, 'tokenCID', ["name", "name", "name", "name", "name", "name"], ["value", "value", "value", "value", "value", "value"], 1,1,"head",0)
  })

  it('check project, collection & token setup', async () => {
    
    const project1 = await nftProjects.projects(1)
    const cyberpass = await nftProjects.collections(1)

    expect(project1.chef).equal(projectChef.address)
    expect(project1.name).equal("Cyberfrens")
    
    expect(cyberpass.projectId).equal(1)
    expect(cyberpass.assetType).equal(2)
    expect(cyberpass.manager).equal(collectionManager.address)
    expect(cyberpass.maxInvocations).equal(maxInvocations)
    expect(cyberpass.invocations).equal(0)

  });


  it('mint Token', async () => {
    
    await nftTokens.mintBatch([1,2,3],[100,200,300],collectionManager.address,[])
    
    expect(await nftTokens.balanceOf(collectionManager.address,2)).equal(200) 
    expect(await nftTokens.balanceOf(collectionManager.address,3)).equal(300)
    expect(await nftProjects.viewInvocations(2)).equal(200)
    expect(await nftTokens.totalSupply(2)).equal(200)
    expect(await nftTokens.totalSupply(3)).equal(300)

  });

  it('equip to MasterNFT', async () => {
    
    await nftTokens.mintBatch([1,2,3],[1,3,1],collectionManager.address,[])
    await (await nftTokens.connect(collectionManager).editCanvas(3,[2,2,2]))
    
    expect(await nftTokens.balanceOf(collectionManager.address,2)).equal(3) 
    expect(await nftTokens.balanceOf(collectionManager.address,3)).equal(1)

    expect((await nftTokens.layersOfCanvas(3))[0].eq(2))
    expect((await nftTokens.layersOfCanvas(3))[1].eq(2))
    expect((await nftTokens.layersOfCanvas(3))[2].eq(2))
  });

  it('unequip trait from MasterNFT', async () => {
    
    await nftTokens.mintBatch([1,2,3],[1,3,1],collectionManager.address,[])
    await (await nftTokens.connect(collectionManager).editCanvas(3,[2,2,2]))
    await (await nftTokens.connect(collectionManager).editCanvas(3,[2,2]))
    
    expect((await nftTokens.layersOfCanvas(3))[0].eq(2))
    expect((await nftTokens.layersOfCanvas(3))[1].eq(2))
    expect((await nftTokens.layersOfCanvas(3))[2]).equal(undefined)
  });



  it('unpause collection and token', async () => {
    
    expect(await nftProjects.viewPausedStatus(1)).equal(true)
    await nftProjects.editCollection(1,1,"Cyberfrens: Cyberpass", "Description", maxInvocations,collectionManager.address,royalties,2,false)
    expect(await nftProjects.viewPausedStatus(1)).equal(false)

    expect(await nftProjects.viewPausedStatus(2)).equal(true)
    await nftProjects.pauseCollection(2)
    expect(await nftProjects.viewPausedStatus(2)).equal(false)


    expect(await (await nftTokens.tokens(1)).paused).equal(true)
    await nftTokens.editToken(1, "Cyberpass", "Description", 100, 1)
    expect(await (await nftTokens.tokens(1)).paused).equal(true)
    await nftTokens.pauseToken(1)
    expect(await (await nftTokens.tokens(1)).paused).equal(false)

    expect(await (await nftTokens.tokens(2)).paused).equal(true)
    await nftTokens.pauseToken(2)
    expect(await (await nftTokens.tokens(2)).paused).equal(false)


  });


  it('edit project check ', async () => {
    
    expect(await (await nftProjects.projects(1)).id).equal(1)
    expect(await (await nftProjects.projects(1)).chef).equal(projectChef.address)
    expect(await (await nftProjects.projects(1)).name).equal("Cyberfrens")
    expect(await (await nftProjects.viewProjectLayerTypes(1))[0]).equal('armor')
    expect(await (await nftProjects.viewProjectLayerTypes(1))[1]).equal('head')
    expect(await (await nftProjects.viewProjectLayerTypes(1))[2]).equal('body')

    await nftProjects.editProject(1,"Cyberfrenz", "Description", collectionManager.address,["armor","feet","jewelery"])

    expect(await (await nftProjects.projects(1)).id).equal(1)
    expect(await (await nftProjects.projects(1)).chef).equal(collectionManager.address)
    expect(await (await nftProjects.projects(1)).name).equal("Cyberfrenz")
    expect(await (await nftProjects.viewProjectLayerTypes(1))[0]).equal('armor')
    expect(await (await nftProjects.viewProjectLayerTypes(1))[1]).equal('feet')
    expect(await (await nftProjects.viewProjectLayerTypes(1))[2]).equal('jewelery')
    
  });


  it('edit collection check ', async () => {
    
    expect(await (await nftProjects.collections(1)).id).equal(1)
    expect(await (await nftProjects.collections(1)).invocations).equal(0)
    expect(await (await nftProjects.collections(1)).name).equal("Cyberfrens: Cyberpass")
    expect(await (await nftProjects.collections(1)).assetType).equal(2)
    expect(await (await nftProjects.collections(1)).manager).equal(collectionManager.address)
    expect(await (await nftProjects.collections(1)).maxInvocations).equal(900)
    expect(await (await nftProjects.collections(1)).royalties).equal(royalties*100)
    expect(await (await nftProjects.collections(1)).projectId).equal(1)
    expect(await (await nftProjects.collections(1)).paused).equal(true)

    await nftProjects.editCollection(1,1,"Cyber", "Description", 1,projectChef.address,1,1,false)

    expect(await (await nftProjects.collections(1)).id).equal(1)
    expect(await (await nftProjects.collections(1)).invocations).equal(0)
    expect(await (await nftProjects.collections(1)).name).equal("Cyber")
    expect(await (await nftProjects.collections(1)).assetType).equal(1)
    expect(await (await nftProjects.collections(1)).manager).equal(projectChef.address)
    expect(await (await nftProjects.collections(1)).maxInvocations).equal(1)
    expect(await (await nftProjects.collections(1)).royalties).equal(100)
    expect(await (await nftProjects.collections(1)).projectId).equal(1)
    expect(await (await nftProjects.collections(1)).paused).equal(false)
  });

})
