// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

interface IPrismTokens{
    function mintBatch(uint256[] memory _ids, uint256[] memory _amounts, address _to, bytes memory _data) external; 
}

contract PrismMinting is VRFConsumerBaseV2 {

  /**
  @dev global
  */
  address public prismTokensContract;
   //projectId => bundles
  mapping (uint256 => uint256[][]) private projectIdToBundles;
  //requestId => MintRequest
  mapping (uint256 => MintRequest) public requestIdToMintRequest;
  //address => RandomBundle
  mapping (uint256 => RandomBundle) public addressToRandomBundle;

  /**
  @dev vrf
  */
  VRFCoordinatorV2Interface COORDINATOR;
  // Your subscription ID.
  uint64 s_subscriptionId;
  // Mumbai settings.
  address vrfCoordinator = 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed;
  bytes32 keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
  uint32 callbackGasLimit = 2500000;
  
  // The default is 3.
  uint16 requestConfirmations = 3;
  // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
  uint32 numWords =  2;
  uint256[] public s_randomWords;
  uint256 public s_requestId;
  address s_owner;

  /**
  @dev structs
  */

  struct MintRequest {
    address sender;
    uint256 projectId;
  }

  struct RandomBundle {
    uint256 projectId;
    uint256 index;
  }

  constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_owner = msg.sender;
    s_subscriptionId = subscriptionId;
  }

  function setPrismTokensContract(address _prismTokensContract) public onlyOwner {
    prismTokensContract = _prismTokensContract;
  }

  function setProjectIdToBundles(uint256 _projectId, uint256[][] memory _bundles) public onlyOwner {
      projectIdToBundles[_projectId] = _bundles;
  }

  //1. request random bundle (index)
  function selectRandomBundle(uint64 projectId) external {
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );

    requestIdToMintRequest[s_requestId] = MintRequest(msg.sender, projectId);
  }
  
  //2. callback triggered by VRFCoordinatorV2Interface
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {

    uint256 randomIndex = (randomWords[0] % projectIdToBundles[requestIdToMintRequest[s_requestId].projectId].length) + 1;
    addressToRandomBundle[projectIdToBundles[requestIdToMintRequest[s_requestId].sender] = RandomBundle(requestIdToMintRequest[s_requestId].projectId, randomIndex);
    
    delete requestIdToMintRequest[s_requestId]
  }

  //3. prompt user to mint tokens - must be called from the frontend.
  function mintRandomBundle() external onlyBundleOwner {
    //generate array of 1 for amounts to be minted for each token in the bundle
    uint256[] memory amountsToMintPerTokenId = new uint256[](projectIdToBundles[addressToRandomBundle[msg.sender].projectId][addressToRandomBundle[msg.sender].index].length);
    for (uint32 i = 0; i < amountsToMintPerTokenId.length; i++) {
      amountsToMintPerTokenId[i] = 1;
    }
    //call mintBatch of tokens from the Prism tokens contract
    IPrismTokens(prismTokensContract).mintBatch(
      projectIdToBundles[addressToRandomBundle[msg.sender].projectId][addressToRandomBundle[msg.sender].index],
      amountsToMintPerTokenId,
      msg.sender,
      abi.encode(0)
    );

    delete projectIdToBundles[requestIdToMintRequest[s_requestId].projectId][randomIndex];
    delete addressToRandomBundle[msg.sender];
  }

  modifier onlyBundleOwner {
    require(addressToRandomBundle[msg.sender] != 0);
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == s_owner);
    _;
  }
}
